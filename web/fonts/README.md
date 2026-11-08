# Website fonts

The website bundles two unmodified variable font files and serves them from its own origin.

| Family | Local file | Variable weight range | License |
| --- | --- | ---: | --- |
| Manrope | `manrope-variable.ttf` | 200–800 | SIL Open Font License 1.1 |
| Outfit | `outfit-variable.ttf` | 100–900 | SIL Open Font License 1.1 |

## Sources

- Manrope: [Google Fonts source directory](https://github.com/google/fonts/tree/main/ofl/manrope), originally distributed as `Manrope[wght].ttf`.
- Outfit: [Google Fonts source directory](https://github.com/google/fonts/tree/main/ofl/outfit), originally distributed as `Outfit[wght].ttf`.

The original font files are redistributed without modification. The corresponding full SIL Open Font License 1.1 texts are included as `OFL-Manrope.txt` and `OFL-Outfit.txt`.

The CSS declares the variable weight ranges and uses `font-display: swap`. The browser loads the files from this website's own domain; no external font stylesheet or font binary is requested at runtime.
