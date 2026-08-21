# Glassmorphism — Modern UI v2

A modernisation layer for this OutFox theme, a fork of **Infinitesimal** by
dj505 & SheepyChris. The goal is to look and feel newer than stock Pump It Up
(Infinity / Prime / Phoenix) while keeping the Infinity identity and **all**
existing theme features intact.

Everything is gated behind a single style switch: `Style = "classic"`
restores the original look on every screen.

## Identity

Keep these in priority order when adding anything:

1. **Glassmorphism** — translucent frosted panels, layered depth, hairline
   highlights, the background still visible through the chrome.
2. **Modern UI** — design tokens instead of hard-coded values, restrained
   motion, generous spacing, light typography.
3. **Phoenix flavour** — accent hue, the diagonal shear, level and grade tiers.

Phoenix is the *inspiration*, not the target. This is a glassmorphism theme for
Project OutFox, not a Phoenix reskin. **If a Phoenix cue ever fights the
frosted-glass look, the glass wins.** Two consequences that already follow from
that rule:

* Panel bodies must stay **translucent and palette-tinted**. An opaque plate is
  a regression, no matter how accurate its colour is.
* The shear is deliberately small (`0.03`). It is a garnish; the frosted
  translucency is the headline effect.

## Assets

`Graphics/Glass` holds the theme's UI textures. They are **generated**, not
hand-drawn or AI-generated, by:

```
python3 Other/gen_glass_assets.py
```

| File | Purpose |
| --- | --- |
| `Corner.png` | One rounded corner, drawn four times per panel at 0/90/180/270 degrees |
| `Corner (doubleres).png` | High-DPI variant; OutFox picks it automatically, keep both |
| `Shadow.png` | Pre-blurred ambient shadow for elevation |
| `Sheen.png` | Diagonal specular streak, the cue that reads as glass |
| `GradePlate.png` | Rounded, sheared backing plate for a grade badge |
| `Ring.png` | Thin rounded outline for focus rings and avatar frames |

Three rules for these files:

1. **Every file is pure white plus alpha and carries no colour.** The theme
   tints each sprite at runtime from `ModernUI.Tokens`, so one set serves every
   palette and accent. Recolouring them by hand breaks palette switching.
2. **The folder is optional.** `ModernUI.HasGlassArt` is probed at load time; if
   the art is missing, `ModernUI.Radius()` returns 0 and every panel falls back
   to square-cornered quads. The theme still runs on a fresh checkout.
3. **They are geometry, so regenerate rather than retouch.** The corner radius
   and alpha edges are mathematically exact because they are drawn from
   equations and supersampled 4x. Edit the constants in the script and rerun it.

The PNGs themselves are not committed — run the script to produce them.

## Design reference

The visual reference is **Pump It Up Phoenix 2**, released in July 2026 as the
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

### Phase 4 — Phoenix flavour and glass hardening

| Area | Before | Now |
| --- | --- | --- |
| Palette | Single violet-leaning set of tokens | Swappable palettes; the default **phoenix** palette is near-black navy with pure white type, `infinity` keeps the violet set |
| Accent | `cyan` default | **phoenix2** (electric green) is the default; `phoenix` keeps the near-white cyan of the 2023 generation |
| Glass body | Gradient edges hard-coded as raw violet numbers, ignoring the palette | Edges derived from `Tokens.SurfaceHi` and `Tokens.Base` via `ModernUI.Tint()`, plus a dedicated `Glass` token |
| Geometry | Upright panels only | Subtle shared **diagonal shear** (`Config.Skew = 0.03`) |

### Phase 5 — real glass geometry

| Area | Before | Now |
| --- | --- | --- |
| Corners | Square, because quads cannot be rounded | **Nine-slice** panels: quad edges plus four rotated copies of one rounded-corner sprite |
| Shadow | Hard-edged offset quad | Pre-blurred `Shadow.png` sprite, much softer falloff |
| Sheen | None | Optional additive `Sheen.png` streak across each panel |
| Shear | Applied per piece | Applied to the card's own `ActorFrame`, keeping the nine slices aligned |
| Focus rings | None | `ModernUI.FocusRing()` |

### Phase 6 — levels and grades wired up

| Area | Before | Now |
| --- | --- | --- |
| Chart list levels | Infinity difficulty colours on the ball, plain white numbers | Difficulty numbers tinted by `LevelColor()`, with a shadow so a tinted number stays readable on a tinted ball |
| Grade thresholds | `GradeTier()` invented its own cutoffs, six of which contradicted the theme's real scoring | Thresholds mirror `Modules/PIU/Score.Grading.lua` exactly |
| Grade names | No link to the theme's own grade codes | `GradeName()` translates `Pass3PS` → `SSS+`, so colour follows the *real* grade |
| Failed runs | A failed run with a good letter still coloured as a good grade | Any `Fail*` grade reads as a fail, which is how PIU treats it |
| Score plate | Personal best always accent-tinted | Personal and machine bests tinted by their actual grade |

#### The grade scale, and why it was wrong

This theme already had a grade scale before the modern layer existed:
`Modules/PIU/Score.Grading.lua` works in **points out of 1,000,000** and
returns codes such as `Pass3PS` or `Fail2A`, where a leading digit is a repeat
count and `P` means "plus" — so `3PS` is `SSS+` and `2A` is `AA`.

`ModernUI.GradeTier()` was written independently, in percentages, and the two
disagreed below `AA`:

| Grade | Score module | Old `GradeTier` |
| --- | --- | --- |
| A+ (`PA`) | 82.5% | 87.5% |
| A | 75% | 85% |
| B | 65% | 80% |
| C | 55% | 70% |
| D | 45% | 60% |

A play worth 800,000 points is an `A+` to the scoring module but was a plain
`B` to `GradeTier`. The thresholds are now derived from that table (its score
cutoffs divided by 10,000) and **must be kept in sync with it**. If you retune
one, retune the other.

Prefer `GradeName()` over `GradeTier()` whenever the theme has already computed
a grade: `GradeName` translates the real result, while `GradeTier` re-derives a
guess from a percentage.

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
    Skew       = 0.03,        -- 0 = upright panels, clamped to +/-0.25
    Radius     = 14,          -- corner radius in px; needs Graphics/Glass
    Sheen      = true,        -- diagonal specular streak on glass panels
}
```

`Scripts/07 ModernUI.Options.lua` loads after that file and overrides any of
those values with what the player saved in `Save/OutFoxPrefs.ini`
(`ModernStyle`, `ModernPalette`, `ModernAccent`, `ModernMotion`,
`ModernGlass`, `ModernGrain`, `ModernVignette`, `ModernScanlines`,
`ModernGlowBlobs`, `ModernSkew`). Invalid or missing values silently fall back
to the defaults above, so a hand-edited prefs file can never break the theme.

### Palette tokens

| Token | Used for |
| --- | --- |
| `Base` | Deepest background, and the shaded bottom edge of glass |
| `BaseAlt` | Background tint variation |
| `Surface` | Opaque panels and fallback for glass |
| `SurfaceHi` | The lit top edge of glass, raised surfaces |
| `Glass` | Frosted panel body, tuned independently of opaque surfaces |
| `Text` / `TextDim` | Primary and secondary type |
| `Hairline` | 1px separators; carries its own alpha |
| `Good` / `Warn` / `Bad` | Status colours, shared by all palettes |

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

* `Palette`, `Skew`, `Radius`, `Sheen`, `Grain`, `Vignette`, `Scanlines` and
  `GlowBlobs` are read from `OutFoxPrefs.ini` or the config table but have **no
  option row yet**, so they can only be changed by editing
  `Scripts/06 ModernUI.lua` or the prefs file. Adding a row also means adding
  strings to all five language files.
* The per-choice labels (`Aurora` / `Video` / `Classic`, `Phoenix 2` /
  `Phoenix` / …) are still hard-coded English in
  `Scripts/07 ModernUI.Options.lua`; only the row titles and explanations are
  translated.

## Still to do

This is a glassmorphism interface with a Phoenix 2 palette and geometry, not a
Phoenix 2 reproduction.

**Needs code only:**

* Horizontal Phoenix-style song select (banner strip along the bottom, vertical
  difficulty chips) instead of the current vertical Infinity wheel. This is the
  largest and riskiest remaining change: it touches the music wheel, its
  metrics and the chart list. Weigh it against the identity rule above — it is
  a Phoenix layout, not a glassmorphism requirement.
* A Pumbility-style player rating. The scale exists in `GradeTier`, but nothing
  aggregates a profile's best charts yet.
* `GradePlate.png` ships but no screen consumes it yet.

**Still blocked on art or engine features:**

* **A real blur.** True frosted glass blurs what is behind it. Without a
  render-to-texture pass the theme approximates it with translucency,
  gradients, the sheen and grain. This is now the biggest remaining gap.
* **The italic condensed display font** Phoenix uses. The theme currently ships
  Montserrat and VCR OSD Mono.
* **Noteskins and judgement art** in the Phoenix style.

## Implementation notes / gotchas

* **Two grade scales must not drift.** `GradeTiers` in `Scripts/06` mirrors the
  score cutoffs in `Modules/PIU/Score.Grading.lua`. They are separate tables in
  separate files, so changing one silently contradicts the other.
* **The chart list is addressed by index, not by name.**
  `ChartDisplay.lua` reaches its slots through `GetChild("")[i]` and the scroll
  arrows through `GetChild("")[ItemAmount+1]`. Adding **any** top-level actor to
  that file shifts every index and breaks the whole difficulty row. Modify the
  existing slots instead.
* **The evaluation screen keeps its own grades on purpose.** Those are official
  PIU sprites from `Graphics/LetterGrades`, selected by
  `Modules/PIU/Score.GradingEval.lua`. Replacing them with `GradeTier()` text
  would throw away authentic art. The same applies to the grade sprite on the
  song-select score plate: the modern layer tints the *numbers* next to it and
  leaves the sprite alone.
* **`diffuse()` resets the edge colours.** When tinting a gradient readout, call
  `diffuse()` first and `diffusetopedge()` after, never the other way round.
* **Level 99 is not a level.** Co-op charts report a meter of 99, which the
  chart list displays as `??`. Anything colouring a level must handle a
  non-numeric value — `LevelColor` coerces with `tonumber`, and the chart list
  falls back to the plain text token.
* **Never hard-code colour numbers in gradients.** `diffusetopedge` and friends
  take a colour, and raw numbers there silently ignore the active palette — the
  glass body carried a violet cast for exactly this reason. Use
  `ModernUI.Tint(token, alpha)` to rebuild a palette token at a given alpha.
* **Shear the frame, not the slices.** A nine-slice panel must be sheared via
  its own `ActorFrame`. Skewing each piece separately shifts them by different
  amounts and tears the corners away from the edges.
* **A full-bleed bar must not be rounded.** `ModernUI.ChromeBar` passes
  `radius = 0`, because its left and right edges deliberately run off-screen and
  rounding them would put a visible notch at the screen edge.
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
* **`Ring.png` is square.** Stretching it to a strongly non-square size
  distorts the corner radius. Use `FocusRing` where width and height are close.
* **Contrast.** Wherever the original art was a light plate with
  `Color.Black` text, modern mode dims the plate *and* switches the type to
  `ModernUI.Tokens.Text`; never change one without the other.
* **Text attribute lengths.** `AddAttribute` counts characters including the
  newline, so derive the length from the string (`#ThemeName`) instead of
  hard-coding it, or the tint bleeds onto the next line.

## Performance notes

* The generated textures are tiny (all six under 15 KB) and every panel reuses
  the same handful, so they cost one texture bind rather than new memory per
  screen.
* A nine-slice panel is 9 actors instead of 2. That is still trivial next to the
  background, but do not build them inside a per-frame `Update`.
* Glow blobs animate with engine-side `bob()` / `pulse()` effects instead of
  Lua `Update` callbacks, so there is no per-frame Lua cost.
* Dropping the MP4 background (`Style = "aurora"`) removes an H.264 decode
  from every menu screen.
* Recommended for weak hardware: `Motion = "reduced"`, `GlowBlobs = 2`,
  `Grain = false`, `Sheen = false`.

## API for further work

```lua
ModernUI.Accent(1)                     -- bright accent colour
ModernUI.Accent(2)                     -- deep accent colour
ModernUI.Tokens.Text / .TextDim / ...  -- colour tokens
ModernUI.Tint(token, 0.4)              -- palette token at a given alpha
ModernUI.ApplyPalette("phoenix")       -- swap palette at runtime
ModernUI.IsModern() / .UseGlass()      -- feature gates
ModernUI.HasGlassArt                   -- is Graphics/Glass installed?
ModernUI.MotionScale()                 -- 0 | 0.55 | 1
ModernUI.T(0.5)                        -- duration scaled by motion setting
ModernUI.Skew()                        -- shared horizontal shear
ModernUI.Radius(w, h)                  -- clamped corner radius, 0 without art
ModernUI.EaseIn(actor, 0.5)            -- signature easing
ModernUI.LevelColor(21)                -- Phoenix colour for a chart level
ModernUI.GradeName("Pass3PS")          -- "SSS+", plus a failed flag
ModernUI.GradeTier(0.9912)             -- "SSS" derived from a percentage
ModernUI.GradeColor("Pass3PS")         -- colour for a grade code or name
ModernUI.Hairline{ w = 200, y = 0 }    -- 1px separator
ModernUI.SoftGlow{ zoom = 3, ... }     -- additive radial glow
ModernUI.FocusRing{ w = 96, h = 96 }   -- rounded outline
ModernUI.GlassCard{ w = 420, h = 160 } -- frosted rounded panel
ModernUI.ChromeBar{ h = 92 }           -- full-width frosted bar
LoadModule("UI.GlassCard.lua"){ ... }  -- same card from any screen
```

Remaining ideas: glass treatment for the group wheel, a modern
`ScreenSelectMode`, and animated grade reveals on the evaluation screen.
