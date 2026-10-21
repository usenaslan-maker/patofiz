# Daily update of the site

The site (https://usenaslan-maker.github.io/patofiz/) shows pages from the user's claude.ai "Патогенез" project
in three tabs. Everything listed is in `library.json`: tabs → sections → items `{"id", "t", "sub"?, "ru"?}`.

| tab key | folder | what goes there |
|---|---|---|
| `t` | `t/NN.html` | pathogenesis chains / schemes: interactive maps built by JS (usually 3 `<svg>`, no `data:image` pictures, hint "Түйінді басыңыз") |
| `k` | `k/NN.html` | pathophysiology konspekts: text notes, High-Yield summaries (marked "Патофизиология", "БАСТЫ ТІЗБЕК / ҚОСЫМША / ҚАУІП" labels) |
| `c` | `c/NN.html` | practical tasks: situational problems, clinical cases, case studies (ситуациялық есеп, кейс, клиникалық жағдай, задача) |

Not for the site (mark `skip`): Slides or Design type artifacts, pathological anatomy (патанатомия, "Жалпы патологиялық
анатомия"), pharmacology, surgery, topography, philosophy, personal or unrelated pages, this viewer itself.

`tools/sources.json` (local only) records every artifact already looked at: `scheme` (t id), `page` ("k/01", "c/01")
or `skip`, plus `updated` = the artifact's date when taken.

## Steps

1. `Artifact` action `list`, limit 200. Take the artifacts that are not in `tools/sources.json`.
2. Download each with `Artifact` action `read`, `path: "index.html"` (it saves a file; do not read whole files into
   context; inspect with PowerShell: `<title>`, `<h1>`, counts of `<svg` and `data:image`, first ~400 characters of text).
   Decide: scheme (t), konspekt (k), practical task (c) or skip. If two new artifacts carry the same title, take the newer.
3. Copy each new page to `<key>/NN.html`, NN = highest id in that tab + 1 (two digits). Add an item to `library.json`
   in the matching section of that tab (reuse section names across tabs: Ісіну; Су-электролит алмасуы бұзылыстары;
   Ион ауытқулары; Қышқыл-сілті бұзылыстары; Гипоксия; Шеткері қанайналым бұзылыстары; Көмірсулар алмасуы бұзылыстары;
   …) or add a new section with a short Kazakh topic name. `t` = clear title from the page, `sub` = short Kazakh line on
   what it covers, `"ru": true` when the page is in Russian (Kazakh version first). Keep `library.json` valid UTF-8 JSON.
4. Artifacts already taken (`scheme`/`page`) whose list date is newer than `updated`: download again and overwrite
   the file (the build puts the zoom bridge back), update the date.
5. Record every looked-at artifact in `tools/sources.json`.
6. If anything changed: `powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\boyk7\patofiz\tools\publish.ps1 -Message "<short English summary>"`
   (builds `sw.js`, commits, pushes; GitHub Pages updates in a few minutes). Nothing changed: do nothing.
7. Report in Kazakh in 1–3 short sentences what was added or updated, or that there was nothing new. If the push fails
   (sign-in needed), say so plainly; never type passwords or tokens.
