# Infinitesimal — Modern UI v2

A modernisation layer for this OutFox theme. The goal is to look and feel
newer than stock Pump It Up (Infinity / Prime / Phoenix) while keeping the
Infinity identity and **all** existing theme features intact.

## What changed

| Area | Before | Now |
| --- | --- | --- |
| Background | Static PNG gradient + squiggles, or a 2 MB pre-rendered MP4 | Procedural **aurora**: gradient base, drifting additive glow blobs, grid depth, animated film grain, corner vignette. Reacts to the current screen and to Basic Mode. |
| HUD chrome | Flat opaque plates, black text | Layered **glassmorphism** bars with accent hairlines, light typography, original plate art kept underneath at low opacity |
| Avatar cards | Flat slot | Elevated card with accent ring and accent-coloured level chip |
| Title screen | Hard 0.96 zoom pulse | Accent halo behind the logo, softer breathing, glass info chip for song count / engine build |
| Corner arrows | Fixed 0.25s glow | Accent-tinted, longer soft glow, motion-token driven easing |
| Design values | Hard-coded per file | Central **design tokens** (colour / motion / elevation) |

## Configuration

Everything lives at the top of `Scripts/06 ModernUI.lua`:

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

* `Style = "classic"` restores the original Infinity chrome and background
  byte-for-byte in behaviour — nothing is lost.
* `Style = "video"` keeps the pre-rendered `_Background.mp4`.
* `Motion = "reduced"` or `"off"` and `GlowBlobs = 2` are the recommended
  settings for low-end cabinets / integrated GPUs.
* Accent ramps drive every highlight in the theme at once, so re-skinning
  the whole UI is a one-line change.

## Performance notes

* No new image or video assets: the aurora background reuses
  `Graphics/Background/circle.png`, `Graphics/Noise.png`,
  `Graphics/Scanline.png` and `Graphics/Grid`.
* Glow blobs animate with engine-side `bob()` effects instead of Lua
  `Update` callbacks, so there is no per-frame Lua cost.
* Dropping the MP4 background (`Style = "aurora"`) removes an H.264 decode
  from every menu screen, which is usually a net win on weak hardware.

## API for further work

```lua
ModernUI.Accent(1)                     -- bright accent colour
ModernUI.Accent(2)                     -- deep accent colour
ModernUI.Tokens.Text / .TextDim / ...  -- colour tokens
ModernUI.T(0.5)                        -- duration scaled by motion setting
ModernUI.EaseIn(actor, 0.5)            -- signature easing
ModernUI.Hairline{ w = 200, y = 0 }    -- 1px separator
ModernUI.SoftGlow{ zoom = 3, ... }     -- additive radial glow
ModernUI.GlassCard{ w = 420, h = 160 } -- frosted panel
ModernUI.ChromeBar{ h = 92 }           -- full-width frosted bar
LoadModule("UI.GlassCard.lua"){ ... }  -- same card from any screen
```

Suggested next steps (not yet implemented): apply `GlassCard` to the
song wheel items, evaluation panels and the options list, and add a
service-menu toggle for `Style` / `Accent` / `Motion` in `metrics.ini`
under `[ScreenInfOptionsUI]`.
