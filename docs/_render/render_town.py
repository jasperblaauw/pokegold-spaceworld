#!/usr/bin/env python3
"""Render Silent Hill (the starter town) straight from the repo's map data,
then re-shade it with the exact rBGP values each time of day produces, under
the palette of each console mode."""

import os
from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(REPO, "docs/img/rtc")

# ---------- source data ----------------------------------------------------
common = open(f"{REPO}/gfx/tilesets/common.2bpp", "rb").read()          # $20 tiles -> vTileset
tset = open(f"{REPO}/gfx/tilesets/silent_hill.common.2bpp", "rb").read()  # $40 tiles -> vExteriorTileset
meta = open(f"{REPO}/data/tilesets/silent_hill_metatiles.bin", "rb").read()
blk = open(f"{REPO}/maps/SilentHill.blk", "rb").read()

MAP_W, MAP_H = 10, 9  # blocks, from constants/map_constants.asm

vram = common + tset  # tile ids 0-$1f common, $20-$5f tileset


def decode_tile(data, idx):
    """2bpp -> 8x8 list of colour numbers 0-3."""
    base = idx * 16
    rows = []
    for y in range(8):
        lo, hi = data[base + y * 2], data[base + y * 2 + 1]
        rows.append([(((hi >> (7 - x)) & 1) << 1) | ((lo >> (7 - x)) & 1) for x in range(8)])
    return rows


TILES = [decode_tile(vram, i) for i in range(len(vram) // 16)]

# ---------- compose the map as colour numbers ------------------------------
W, H = MAP_W * 4 * 8, MAP_H * 4 * 8  # 4x4 tiles per block, 8px per tile
canvas = [[0] * W for _ in range(H)]

for by in range(MAP_H):
    for bx in range(MAP_W):
        block = blk[by * MAP_W + bx]
        for ty in range(4):
            for tx in range(4):
                tile = meta[block * 16 + ty * 4 + tx]
                if tile >= len(TILES):
                    continue
                px = TILES[tile]
                ox, oy = (bx * 4 + tx) * 8, (by * 4 + ty) * 8
                for y in range(8):
                    canvas[oy + y][ox: ox + 8] = px[y]

# ---------- palettes -------------------------------------------------------
# rBGP at rest, per time of day, for a TOWN map (palset %11100100).
BGP = {"day": 0xE4, "morn": 0xE8, "nite": 0xE9, "dark": 0xF9}

# DMG: the classic green LCD, matching the wiki's own --screen-* tokens.
DMG = [(0x9B, 0xBC, 0x0F), (0x8B, 0xAC, 0x0F), (0x30, 0x62, 0x30), (0x0F, 0x38, 0x0F)]


def sgb(*rgb5):
    return [(r * 255 // 31, g * 255 // 31, b * 255 // 31) for r, g, b in rgb5]


# data/sgb/super_palettes.asm — PAL_TOWN_SILENTHILL and PAL_NIGHTTIME
SGB_SILENTHILL = sgb((28, 28, 28), (12, 28, 22), (15, 20, 20), (4, 4, 4))
SGB_NIGHTTIME = sgb((28, 28, 28), (12, 28, 22), (15, 20, 20), (4, 4, 4))

# Game Boy Color boot ROM default for a DMG title it doesn't recognise.
CGB = [(0xFF, 0xFF, 0xFF), (0xFF, 0xAD, 0x63), (0x84, 0x31, 0x00), (0x00, 0x00, 0x00)]

MODES = {
    "dmg": lambda band: DMG,
    "sgb": lambda band: SGB_NIGHTTIME if band in ("nite", "dark") else SGB_SILENTHILL,
    "cgb": lambda band: CGB,
}

os.makedirs(OUT, exist_ok=True)

for mode, pal_for in MODES.items():
    for band, bgp in BGP.items():
        shades = [(bgp >> (n * 2)) & 3 for n in range(4)]  # colour number -> shade
        pal = pal_for(band)
        im = Image.new("RGB", (W, H))
        im.putdata([pal[shades[c]] for row in canvas for c in row])
        path = f"{OUT}/silenthill-{mode}-{band}.png"
        im.save(path, optimize=True)
        print(f"{path}  {os.path.getsize(path)} bytes  BGP=${bgp:02x} shades={shades}")
