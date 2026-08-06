# Text Glossary generator

Source for the static site under [`docs/glossary/`](../glossary/) — a Japanese ↔
English glossary of **every** text string in the Space World 1997 prototype
(names, Pokédex entries, move/item descriptions, map dialogue, and all
battle/menu/system text).

This is **documentation only**: it reads the repo's `.asm` data and emits HTML.
It never touches the ROM build, so `make compare` is unaffected.

## Regenerating

```sh
python3 docs/_glossary/build_descs.py   # (re)writes desc_generated.py
python3 docs/_glossary/gen_site.py       # writes docs/glossary/*.html
```

Both scripts locate the repo root relative to their own location, so they can be
run from anywhere. Override with the `GLOSSARY_REPO` env var if needed.
`gen_site.py` prints per-section coverage and, on a partial run, leaves a
`missing.json` (git-ignored) listing untranslated keys.

## Layout

| File | Role |
|------|------|
| `gen_site.py` | Main generator. Extracts every Japanese string from `data/`, `engine/`, `home/`, `maps/`, pairs it with English, writes the multi-page site, and reports coverage. |
| `translations.py` | Hand English for Pokédex entries/categories and map dialogue; re-exports the move/item/system tables. |
| `system_data.py` | English for the ~733 engine/battle/menu/system strings, keyed `basename.asm:Label` (`#n` for repeats; colliding basenames get a `parentdir/` prefix). |
| `build_descs.py` | Builds the numeric-keyed move & item descriptions (patterns + overrides) and emits `desc_generated.py`. |
| `desc_generated.py` | Generated. Move/item description tables. Do not hand-edit. |
| `names_data.py`, `newcomers.py` | Name-table data: official Gen-1 names, the 100 newcomers (rōmaji, typings, etymology, final-game fate), locations, trainers, types. |

## Extraction contract

Coverage is measured against strings pulled straight from source, so nothing is
silently dropped: any string without an English entry renders as a visible
`— pending —` marker and is counted against the section total. Today every
section is at 100%.

Fragment note: many battle/menu strings are pieces the engine concatenates
around an inline name or number buffer. Those are translated as fragments, and
`<USER>` / `<TARGET>` / `<PLAYER>` / `<RIVAL>` etc. are engine placeholders kept
verbatim.
