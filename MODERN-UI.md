# Infinitesimal — Modern UI v2

A modernisation layer for this OutFox theme. The goal is to look and feel
newer than stock Pump It Up (Infinity / Prime / Phoenix) while keeping the
Infinity identity and **all** existing theme features intact.

Everything is gated behind a single style switch: `Style = "classic"`
restores the original look on every screen.

## What changed

### Phase 1 — foundation

| Area | Before | Now |
| --- | --- | --- |
| Background | Static PNG gradient + squiggles, or a pre-rendered MP4 | Procedural **aurora**: gradient base, drifting additive glow blobs, grid depth, animated film grain, corner vignette |
| HUD chrome | Flat opaque plates, black text | Layered **glassmorphism** bars with accent hairlines and light typography |
| Avatar cards | Flat slot | Elevated card with accent ring and accent-coloured level chip |
| Title screen | Hard 0.96 zoom pulse | Accent halo behind the logo, softer breathing, glass info chip |
| Corner arrows | Fixed 0.25s glow | Accent-tinted, longer soft glow, motion-token driven easing |
| Design values | Hard-coded per file | Central **design tokens** (colour / motion / elevation) |

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

## Configuration

Defaults live at the top of `Scripts/06 ModernUI.lua`:

```lua
ModernUI.Config = {
    Style      = "aurora",  -- "aurora" | "video" | "classic"
    Accent     = "cyan",    -- cyan | violet | magenta | lime | amber | ice
    Motion     = "full",    -- full | reduced | off
    Glass      = true,
    Grain      = true,
    Vignette   = true,
    Scanlines  = false,
    GlowBlobs  = 5,
}
```

`Scripts/07 ModernUI.Options.lua` loads after that file and overrides any of
those values with what the player saved in `Save/OutFoxPrefs.ini`
(`ModernStyle`, `ModernAccent`, `ModernMotion`, `ModernGlass`, `ModernGrain`,
`ModernVignette`, `ModernScanlines`, `ModernGlowBlobs`). Invalid or missing
values silently fall back to the defaults above, so a hand-edited prefs file
can never break the theme.

### Wiring the option rows (optional)

The rows are built and ready; they are not attached to a screen yet because
that needs matching strings in **every** `Languages/*.ini` (a missing string
shows up as a visible warning in OutFox). To enable them, add to
`metrics.ini`:

```ini
[ScreenInfOptionsUI]
LineModernStyle="lua,ModernUI.OptionRow.Style()"
LineModernAccent="lua,ModernUI.OptionRow.Accent()"
LineModernMotion="lua,ModernUI.OptionRow.Motion()"
LineModernGlass="lua,ModernUI.OptionRow.Glass()"
```

…append those line names to the existing `LineNames` list in that section,
then add to each `Languages/*.ini`:

```ini
[OptionTitles]
ModernStyle=Visual Style
ModernAccent=Accent Colour
ModernMotion=Motion
ModernGlass=Glass Panels

[OptionExplanations]
ModernStyle=Aurora is the modern background, Classic restores the original theme.
ModernAccent=Sets the highlight colour used across the whole interface.
ModernMotion=Reduce or disable animation for low-end hardware.
ModernGlass=Frosted panels behind menus and HUD elements.
```

Style and background changes apply after a theme reload; accent colours
apply as soon as you leave the options screen.

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
  `effectperiod`; it returns ~0 when motion is off, which stalls the engine
  effect. The options list guards this by holding a static accent instead.
* **Square corners are intentional.** OutFox quads cannot be rounded
  without extra textures, so depth comes from gradients, hairlines and
  shadow quads.
* **Contrast.** Wherever the original art was a light plate with
  `Color.Black` text, modern mode dims the plate *and* switches the type to
  `ModernUI.Tokens.Text`; never change one without the other.

## API for further work

```lua
ModernUI.Accent(1)                     -- bright accent colour
ModernUI.Accent(2)                     -- deep accent colour
ModernUI.Tokens.Text / .TextDim / ...  -- colour tokens
ModernUI.IsModern() / .UseGlass()      -- feature gates
ModernUI.MotionScale()                 -- 0 | 0.55 | 1
ModernUI.T(0.5)                        -- duration scaled by motion setting
ModernUI.EaseIn(actor, 0.5)            -- signature easing
ModernUI.Hairline{ w = 200, y = 0 }    -- 1px separator
ModernUI.SoftGlow{ zoom = 3, ... }     -- additive radial glow
ModernUI.GlassCard{ w = 420, h = 160 } -- frosted panel
ModernUI.ChromeBar{ h = 92 }           -- full-width frosted bar
LoadModule("UI.GlassCard.lua"){ ... }  -- same card from any screen
```

Remaining ideas: glass treatment for the group wheel, a modern
`ScreenSelectMode`, and animated grade reveals on the evaluation screen.
