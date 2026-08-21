# Glassmorphism — Modern UI v2

A modernisation layer for this OutFox theme, a fork of **Infinitesimal** by
dj505 & SheepyChris. The goal is to look and feel newer than stock Pump It Up
(Infinity / Prime / Phoenix) while keeping the Infinity identity and **all**
existing theme features intact.

Everything is gated behind a single style switch: `Style = "classic"`
restores the original look on every screen.

## Design target

The visual target is **Pump It Up Phoenix 2**, released in July 2026 as the
18th arcade installment in the series. Notes that matter for theming:

* Phoenix 2 keeps the dark UI of the 2023 Phoenix generation but replaces its
  blue-cyan identity with **electric green**. That is why the default accent is
  `phoenix2` and not `phoenix`.
* It renews **Pumbility**, the player rating built from a player's 50
  highest-rated songs, and shows song titles in real time in the interface.
* Its typography is heavy, condensed and italic, and panels are sheared on a
  diagonal — hence `Config.Skew`.

Do not assume Phoenix 2 is only a version bump of Phoenix; it is a separate
installment with its own identity.

## What changed

### Phase 1 — foundation

| Area | Before | Now |
| --- | --- | --- |
| Background | Static PNG gradient + squiggles, or a pre-rendered MP4 | Procedural **aurora**: gradient base, drifting additive glow blobs, grid depth, animated film grain, corner vignette |
| HUD chrome | Flat opaque plates, black text | Layered **glassmorphism** bars with accent hairlines and light typography |
| Avatar cards | Flat slot | Elevated card with accent ring and accent-coloured level chip |
| Title screen | Hard 0.96 zoom pulse | Accent halo behind the logo, softer breathing, glass info chip |
| Corner arrows | Fixed 0.25s glow | Accent-tinted, longer soft glow, motion-token driven easing |
| Design values | Hard-coded per file | Central **design tokens** (colour / motion / elevation / geometry) |

### Phase 2 — screen surfaces

| Area | Before | Now |
| --- | --- | --- |
| Music wheel | Uniform banners, no focus cue | Accent **halo on the focused banner**; index chip widened with an additive accent underline |
| Chart info | Loose text over the background | Frosted **glass card** behind the radar stats + accent rule under the heading |
| Score display | Flat plate | Accent bloom behind the plate, personal bests graded into the accent ramp |
| Evaluation song info | Light plate with black text | Glass card, plate art dimmed to 32%, light type, accent BPM/length |
| Evaluation score lines | Flat pink/blue separators | Row plates at 45%, additive accent separators, `Accuracy`/`Score` promoted, new-record delta on the "good" token |

### Phase 3 — options & service

| Area | Before | Now |
| --- | --- | --- |
| Options list cursor | Hard-coded purple/black shift | Shifts between the two accent ramp colours, slightly wider glow, static accent when `Motion = "off"` |
| Options list underline | Flat grey bars | Frosted body on the surface tokens with 1px accent hairlines top and bottom |
| Service / options backdrop | Bare grid + scanlines | Aurora base, two drifting accent glows, dimmed accent-tinted grid, optional vignette; scanlines now follow `Config.Scanlines` |
| Service build stamp | Raw text over the grid | Glass chip with an accent bar, theme name highlighted in the accent |
| Settings | Editing `Scripts/06 ModernUI.lua` by hand | Persisted option rows saved to `Save/OutFoxPrefs.ini` |

### Phase 4 — Phoenix direction

| Area | Before | Now |
| --- | --- | --- |
| Palette | Single violet-leaning set of tokens | Swappable palettes; the default **phoenix** palette is near-black navy with pure white type, `infinity` keeps the violet set |
| Accent | `cyan` default | **phoenix2** (electric green) is the default; `phoenix` keeps the near-white cyan of the 2023 generation |
| Geometry | Upright panels only | Shared **diagonal shear** (`Config.Skew`) applied to hairlines, glass cards and chrome bars |
| Chart levels | Infinity difficulty colours | `ModernUI.LevelColor()` — Phoenix-style colour per level tier |
| Grades | Engine grade scale | `ModernUI.GradeTier()` — SSS+ → F scale with `GradeColor()` |

## Configuration

Defaults live at the top of `Scripts/06 ModernUI.lua`:

```lua
ModernUI.Config = {
    Style      = "aurora",    -- "aurora" | "video" | "classic"
    Palette    = "phoenix",   -- phoenix | infinity
    Accent     = "phoenix2",  -- phoenix2 | phoenix | cyan | violet | magenta | lime | amber | ice
    Motion     = "full",      -- full | reduced | off
    Glass      = true,
    Grain      = true,
    Vignette   = true,
    Scanlines  = false,
    GlowBlobs  = 5,
    Skew       = 0.06,        -- 0 = upright panels, clamped to +/-0.25
}
```

`Scripts/07 ModernUI.Options.lua` loads after that file and overrides any of
those values with what the player saved in `Save/OutFoxPrefs.ini`
(`ModernStyle`, `ModernPalette`, `ModernAccent`, `ModernMotion`,
`ModernGlass`, `ModernGrain`, `ModernVignette`, `ModernScanlines`,
`ModernGlowBlobs`, `ModernSkew`). Invalid or missing values silently fall back
to the defaults above, so a hand-edited prefs file can never break the theme.

### Option rows (already wired)

Style, Accent, Motion and Glass are live on the Interface options screen.
`metrics.ini` declares them under `[ScreenInfOptionsUI]`:

```ini
[ScreenInfOptionsUI]
LineNames="ModernStyle,ModernAccent,ModernMotion,ModernGlass,1,2,3,4,5,6,7"
LineModernStyle="lua,ModernUI.OptionRow.Style()"
LineModernAccent="lua,ModernUI.OptionRow.Accent()"
LineModernMotion="lua,ModernUI.OptionRow.Motion()"
LineModernGlass="lua,ModernUI.OptionRow.Glass()"
```

The matching `[OptionTitles]` and `[OptionExplanations]` strings already ship
in **all five** language files (`en`, `pl`, `pt-BR`, `zh-Hans`, `zh-Hant`).
Do not add those keys again — they are present. If you add a **new** language
file, copy the eight keys across, otherwise OutFox shows a visible
missing-string warning on the options screen.

Style, palette and background changes apply after a theme reload; accent
colours apply as soon as you leave the options screen.

### Known gaps

* `Palette`, `Skew`, `Grain`, `Vignette`, `Scanlines` and `GlowBlobs` are read
  from `OutFoxPrefs.ini` but have **no option row yet**, so they can only be
  changed by editing `Scripts/06 ModernUI.lua` or the prefs file. Adding a row
  also means adding strings to all five language files.
* The per-choice labels (`Aurora` / `Video` / `Classic`, `Phoenix 2` /
  `Phoenix` / …) are still hard-coded English in
  `Scripts/07 ModernUI.Options.lua`; only the row titles and explanations are
  translated.

## Still missing for a true Phoenix 2 look

Be realistic about what is done: the layer above is a *modern* interface with a
Phoenix 2 palette and geometry, not a Phoenix 2 reproduction.

**Needs code only (doable next):**

* `ModernUI.LevelColor()` and `ModernUI.GradeTier()` exist but are **not wired
  into any screen yet**. The chart list and the evaluation screen still use the
  Infinity difficulty colours and the engine grade scale.
* The grade thresholds in `GradeTiers` are approximations of the official
  cutoffs. They live in one table and are meant to be tuned.
* Horizontal Phoenix-style song select (banner strip along the bottom, vertical
  difficulty chips) instead of the current vertical Infinity wheel. This is the
  largest and riskiest remaining change: it touches the music wheel, its
  metrics and the chart list.

**Needs new art or fonts (cannot be done in Lua):**

* **Rounded corners.** OutFox quads cannot be rounded; this needs a 9-slice
  texture set.
* **The italic condensed display font** Phoenix uses. The theme currently ships
  Montserrat and VCR OSD Mono.
* **Noteskins, grade plates and judgement art** in the Phoenix style.

## Performance notes

* No new image or video assets: the modern layer reuses
  `Graphics/Background/circle.png`, `Graphics/Noise.png`,
  `Graphics/Scanline.png` and `Graphics/Grid`.
* Glow blobs animate with engine-side `bob()` / `pulse()` effects instead of
  Lua `Update` callbacks, so there is no per-frame Lua cost.
* Dropping the MP4 background (`Style = "aurora"`) removes an H.264 decode
  from every menu screen.
* Recommended for weak hardware: `Motion = "reduced"`, `GlowBlobs = 2`,
  `Grain = false`.

## Implementation notes / gotchas

* **`GetChild("")` in the music wheel.** The scroll handler resolves the
  index label through the *last unnamed child* of the wheel item. Every
  actor the modern layer adds there is explicitly **named** (`Halo`,
  `IndexBar`), otherwise the lookup retargets and the theme crashes.
* **`Motion = "off"` and `effectperiod`.** Never feed `ModernUI.T()` into
  `effectperiod` unless the call is already guarded by
  `ModernUI.MotionScale() > 0`; it returns ~0 when motion is off, which
  stalls the engine effect. The options list guards this by holding a static
  accent instead.
* **`pulse()` overrides `zoom()`.** The pulse effect drives zoom directly,
  so `ModernUI.SoftGlow` expresses its magnitude in *absolute* zoom
  (`baseZoom` → `baseZoom * ratio`). Passing a bare `1` → `1.06` magnitude
  silently throws away `params.zoom` and snaps every glow down to 1x.
  `pulse = true` is accepted as "use the default ratio"; the value is run
  through `tonumber()` so a boolean can never reach `effectmagnitude()`,
  which only takes numbers.
* **Colour tokens carry their own alpha.** `ModernUI.Tokens.Hairline` has an
  alpha baked in, and `diffusealpha()` *replaces* that alpha rather than
  multiplying it. `ModernUI.Hairline` therefore defaults its alpha to the
  token's own value; pass `alpha` explicitly only when you really want a
  brighter line (the glass card top highlight does).
* **`ApplyPalette()` mutates `ModernUI.Tokens` in place.** Never reassign the
  table: other files already hold a reference to it and would keep rendering
  the old palette. `Scripts/07` calls `ApplyPalette()` again after reading the
  saved preferences.
* **A sheared bar needs bleed.** `skewx` pulls the top and bottom edges
  sideways, which would expose a wedge of background at the screen edges.
  `ModernUI.ChromeBar` widens itself by that offset automatically; do the same
  if you shear a full-width panel yourself.
* **Square corners are intentional.** OutFox quads cannot be rounded
  without extra textures, so depth comes from gradients, hairlines, the shear
  and shadow quads.
* **Contrast.** Wherever the original art was a light plate with
  `Color.Black` text, modern mode dims the plate *and* switches the type to
  `ModernUI.Tokens.Text`; never change one without the other.
* **Text attribute lengths.** `AddAttribute` counts characters including the
  newline, so derive the length from the string (`#ThemeName`) instead of
  hard-coding it, or the tint bleeds onto the next line.

## API for further work

```lua
ModernUI.Accent(1)                     -- bright accent colour
ModernUI.Accent(2)                     -- deep accent colour
ModernUI.Tokens.Text / .TextDim / ...  -- colour tokens
ModernUI.ApplyPalette("phoenix")       -- swap palette at runtime
ModernUI.IsModern() / .UseGlass()      -- feature gates
ModernUI.MotionScale()                 -- 0 | 0.55 | 1
ModernUI.T(0.5)                        -- duration scaled by motion setting
ModernUI.Skew()                        -- shared horizontal shear
ModernUI.EaseIn(actor, 0.5)            -- signature easing
ModernUI.LevelColor(21)                -- Phoenix colour for a chart level
ModernUI.GradeTier(0.9912)             -- "SSS", accepts 0-1 or 0-100
ModernUI.GradeColor("SSS")             -- colour for a grade name
ModernUI.Hairline{ w = 200, y = 0 }    -- 1px separator
ModernUI.SoftGlow{ zoom = 3, ... }     -- additive radial glow
ModernUI.GlassCard{ w = 420, h = 160 } -- frosted panel
ModernUI.ChromeBar{ h = 92 }           -- full-width frosted bar
LoadModule("UI.GlassCard.lua"){ ... }  -- same card from any screen
```

Remaining ideas: glass treatment for the group wheel, a modern
`ScreenSelectMode`, and animated grade reveals on the evaluation screen.
