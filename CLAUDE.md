# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A `pret` disassembly of the Pokémon Gold and Silver prototypes demoed at Space World 1997, written in RGBDS Game Boy assembly. The goal is a **byte-perfect reproduction**: the assembled ROMs must match the original prototype dumps exactly (verified against `roms.sha1`). Any change that alters the output bytes breaks the build — this is a preservation project, not active game development.

`docs/index.html` is a standalone contributor wiki (toolchain setup, emulator testing on Apple Silicon, an assembly cheatsheet, and a page per repo section). It's a good orientation reference; keep it in sync when the build steps, tooling, or directory layout change.

## Building

Requires [RGBDS](https://github.com/gbdev/rgbds) **v1.0.3** (see `.rgbds-version`; CI pins the same).

```sh
make              # build all 4 ROMs (+ correct-header variants) and verify SHA1s
make compare      # (re)run the SHA1 check against roms.sha1
make gold         # build a single ROM: also silver / gold_debug / silver_debug
make clean        # remove all generated files (including compiled graphics)
make tidy         # remove generated files but keep compiled graphics
make -jN ...      # parallelize; CI uses -j$(nproc)
```

There are **no tests** beyond the SHA1 comparison — a green `make compare` is the definition of correct. The CI (`.github/workflows/main.yml`) builds with `DEBUG=1`, runs `compare`, then `.github/checkdiff.sh` (which fails if the build left any tracked file dirty, e.g. a modified `roms.sha1`).

### Build variants

The same `.asm` sources compile into four ROMs via `-D` defines set in the `Makefile`: `_GOLD` / `_SILVER` select the game, `_DEBUG` selects the debug build. Guard version-specific code with these symbols. `make DEBUG=1` additionally emits `.sym`/`.map` files (via rgbasm `-E`) for debugging — it does not change the ROM bytes.

### Tools

`tools/` contains C helpers built automatically during the ROM build (`scan_includes` for dependency scanning, `gfx` for post-processing 2bpp/1bpp graphics, `pkmncompress` for `.pic` sprite compression). `make tools` builds them standalone.

## Architecture

RGBDS links object files into a fixed ROM layout defined by `layout.link`. The four top-level `.asm` files each become one object per variant:

- **`home.asm`** → ROM0 (bank 0, always-mapped "home" section). Core routines callable from anywhere: vblank, interrupts, text, map/overworld, menus, predef/farcall dispatch. See `home/`.
- **`main.asm`** → the numbered ROMX banks. This is the master include list mapping engine/data files to banks (`SECTION "bankN", ROMX`). When you need to know which bank code lives in, read `main.asm`.
- **`audio.asm`** → audio engine and sound/music/cry data (`audio/`).
- **`maps.asm`** → map data (`maps/`, one directory tree per map).
- **`ram.asm`** → memory layout only (no code): `ram/vram.asm`, `wram.asm`, `sram.asm`, `hram.asm` declare labeled RAM addresses.

Supporting source trees:

- **`engine/`** — game logic, grouped by system (`battle/`, `overworld/`, `pokemon/`, `menu/`, `items/`, `movie/`, `games/` for minigames, `debug/` for debug menus, etc.).
- **`data/`** — read-only game data tables (base stats, moves, trainers, maps, sprites, text).
- **`constants/`** — symbolic names for everything; all included via `constants/` list in `includes.asm`. `hardware.inc` is the standard gbdev Game Boy hardware register definitions.
- **`macros/`** — assembler macros. `macros/scripts/` defines the DSLs for map/event/text/movement/battle/audio scripting; script data files read like a mini-language built from these macros.
- **`gfx/`** — PNG source art compiled to `.2bpp`/`.1bpp`/`.pic` by the Makefile's catch-all rules. Per-file `tools/gfx` flags (trim/interleave/remove-duplicates/etc.) are set explicitly in the Makefile.
- **`garbage/`** — padding/leftover data present in the original ROMs, preserved verbatim for byte-matching.

### How includes fit together

`includes.asm` is force-included into every translation unit (`rgbasm -P`) and pulls in the charmap, all macros, and all constants — so those names are globally available. Each object's own top-level `.asm` then `INCLUDE`s its section/data files.

## Conventions

- **Preserve exact output.** Reordering data, changing constants, or "cleaning up" can shift bytes and break `make compare`. Verify with `make compare` after any change.
- Builds run with `-Weverything -Wtruncation=1`; keep it warning-clean.
- Labels use RGBDS scoping: `Label::` (exported), `Label:` (file-global), `.local` (local to the parent label). Match the surrounding style.
- Prefer existing constants and macros over magic numbers — recent commit history explicitly favors hardware constants, meaningful register names, and macros like `sin` over hard-coded values.
- Text/script/map data is authored through the macros in `macros/scripts/`; edit the macro-based source, not raw bytes.
