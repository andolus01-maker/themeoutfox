#!/usr/bin/env python3
"""
Generate the Glassmorphism theme's UI textures into Graphics/Glass.

Usage, from the theme's root folder:

    python3 Other/gen_glass_assets.py

Requires Pillow (pip install Pillow).

WHY THESE ARE DRAWN, NOT AI-GENERATED
-------------------------------------
A UI texture needs an exact corner radius and a clean alpha channel. An image
model cannot guarantee either, and a blurry or slightly-off corner is instantly
visible when four copies of it meet straight edge quads. Everything here is
plain geometry, supersampled 4x and downscaled with LANCZOS for antialiasing,
so the output is deterministic and reproducible.

WHY EVERYTHING IS WHITE
-----------------------
Every file is pure white with an alpha channel and carries no colour of its own.
The theme tints each sprite at runtime with diffuse() from ModernUI.Tokens, so
one set of files works for every palette and accent. Baking a colour in here
would break palette switching.
"""

import os
from PIL import Image, ImageDraw, ImageFilter

SS = 4  # supersampling factor

# Resolve Graphics/Glass relative to this script, so it works from anywhere.
THEME_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(THEME_ROOT, "Graphics", "Glass")


def save(mask, name):
    """Write an L-mode mask as a white RGBA PNG using the mask as alpha."""
    rgba = Image.new("RGBA", mask.size, (255, 255, 255, 0))
    rgba.putalpha(mask)
    path = os.path.join(OUT, name)
    rgba.save(path, "PNG", optimize=True)
    print(f"{name:24s} {mask.size[0]:4d}x{mask.size[1]:<4d} {os.path.getsize(path):7d} B")


def corner(size=64):
    """One rounded corner tile.

    For a top-left corner tile of side r, a point belongs to the rounded
    rectangle iff its distance to (r, r) is <= r. That puts the arc exactly
    tangent to the top and left edges, which is what lets the corner sprite
    meet the straight edge quads with no seam. The theme draws this same file
    four times at 0/90/180/270 degrees.
    """
    big = size * SS
    mask = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(mask)
    d.ellipse([0, 0, big * 2, big * 2], fill=255)
    return mask.resize((size, size), Image.LANCZOS)


def shadow(size=256, radius=56, blur=28):
    """Soft ambient shadow. Deliberately very blurred so it survives being
    stretched to any panel size without showing its original corner radius."""
    big, r = size * SS, radius * SS
    pad = blur * SS * 2
    mask = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([pad, pad, big - pad, big - pad], radius=r, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(blur * SS * 0.5))
    return mask.resize((size, size), Image.LANCZOS)


def sheen(w=512, h=256):
    """The diagonal specular streak that reads as glass. Faded at both ends so
    it dissolves instead of terminating in a hard line."""
    bw, bh = w * SS, h * SS
    mask = Image.new("L", (bw, bh), 0)
    d = ImageDraw.Draw(mask)
    band = bw * 0.22
    lean = bh * 0.9
    d.polygon(
        [
            (bw * 0.30, 0),
            (bw * 0.30 + band, 0),
            (bw * 0.30 + band - lean, bh),
            (bw * 0.30 - lean, bh),
        ],
        fill=210,
    )
    mask = mask.filter(ImageFilter.GaussianBlur(bw * 0.05))

    fade = Image.new("L", (bw, 1), 0)
    fd = fade.load()
    for x in range(bw):
        t = x / (bw - 1)
        edge = min(t, 1.0 - t) * 2.0
        fd[x, 0] = int(255 * min(1.0, edge * 1.6) ** 1.5)
    fade = fade.resize((bw, bh))

    mask = Image.composite(mask, Image.new("L", (bw, bh), 0), fade)
    return mask.resize((w, h), Image.LANCZOS)


def grade_plate(w=384, h=256, radius=28, skew=0.18):
    """Backing plate for a grade badge: rounded, sheared to match the theme's
    diagonal, and graded darker towards the bottom."""
    bw, bh, r = w * SS, h * SS, radius * SS
    pad = int(bh * skew) + 8 * SS
    mask = Image.new("L", (bw, bh), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([pad, 8 * SS, bw - pad, bh - 8 * SS], radius=r, fill=255)

    offset = bh * skew * 0.5
    mask = mask.transform(
        (bw, bh), Image.AFFINE, (1, skew, -offset, 0, 1, 0), resample=Image.BICUBIC
    )

    grad = Image.new("L", (1, bh))
    gd = grad.load()
    for y in range(bh):
        gd[0, y] = int(255 * (1.0 - 0.28 * (y / (bh - 1))))
    grad = grad.resize((bw, bh))

    mask = Image.composite(mask, Image.new("L", (bw, bh), 0), grad)
    return mask.resize((w, h), Image.LANCZOS)


def ring(size=128, radius=28, thickness=3):
    """Thin rounded outline for focus rings and avatar frames.

    Note: stretching this to a strongly non-square size distorts the corner
    radius, so use it where width and height are close.
    """
    big, r, t = size * SS, radius * SS, thickness * SS
    mask = Image.new("L", (big, big), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([t, t, big - t, big - t], radius=r, outline=255, width=t)
    return mask.resize((size, size), Image.LANCZOS)


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    save(corner(64), "Corner.png")
    save(corner(128), "Corner (doubleres).png")
    save(shadow(), "Shadow.png")
    save(sheen(), "Sheen.png")
    save(grade_plate(), "GradePlate.png")
    save(ring(), "Ring.png")
    print("\nwrote to", OUT)
