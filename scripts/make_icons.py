"""Draws the LiveHealthy: Know Your Disease icon set (launcher, adaptive
foreground, Play Store 512, feature graphic) so they're reproducible without
an image model. Same family look as LiveHealthy: Vitals: a white mark on the
suite's green gradient. The mark is an open book with a heart above it —
health knowledge.

Run from the repo root:  python3 scripts/make_icons.py
"""
from PIL import Image, ImageDraw, ImageFont
import math

GREEN = (11, 110, 79)
GREEN_DARK = (7, 78, 56)
WHITE = (255, 255, 255)
MINT = (220, 240, 232)
S = 4  # supersampling factor
URDU_FONT = 'app/assets/fonts/NotoNastaliqUrdu-Bold.ttf'


def heart_points(cx, cy, size, n=400):
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        x = 16 * math.sin(t) ** 3
        y = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        pts.append((cx + x * size / 34, cy - y * size / 34))
    return pts


def draw_mark(draw, cx, cy, size, fg=WHITE, bg=GREEN):
    """Open book (two pages meeting at a spine) with a heart above it."""
    u = size / 100
    # Pages: top edges rise from the spine to the outer corners, bottom
    # edges dip back to the spine, like a book lying open.
    def page(sign):
        top = [(cx + sign * (3 + 45 * t) * u, cy + (4 - 12 * t + 5 * math.sin(math.pi * t)) * u)
               for t in (i / 20 for i in range(21))]
        bottom = [(cx + sign * (3 + 45 * t) * u, cy + (40 - 8 * t + 3 * math.sin(math.pi * t)) * u)
                  for t in (i / 20 for i in range(20, -1, -1))]
        return top + bottom
    draw.polygon(page(-1), fill=fg)
    draw.polygon(page(1), fill=fg)
    # page lines
    for k in range(3):
        for sign in (-1, 1):
            y0 = cy + (14 + k * 8) * u
            draw.line([(cx + sign * 11 * u, y0 + 1 * u), (cx + sign * 38 * u, y0 - 3 * u)], fill=bg, width=max(1, int(3.4 * u)))
    # heart above the spine
    draw.polygon(heart_points(cx, cy - 22 * u, 40 * u), fill=fg)


def gradient_bg(w, h=None):
    """Smooth top-left (lighter) to bottom-right (darker) diagonal gradient."""
    h = h or w
    light, dark = (18, 138, 99), GREEN_DARK
    gx = Image.linear_gradient('L').rotate(90).resize((w, h))
    gy = Image.linear_gradient('L').resize((w, h))
    mask = Image.blend(Image.eval(gx, lambda v: 255 - v), gy, 0.5)
    return Image.composite(Image.new('RGB', (w, h), dark), Image.new('RGB', (w, h), light), mask)


def launcher_icon(path, size=1024):
    big = size * S
    img = gradient_bg(big)
    d = ImageDraw.Draw(img)
    draw_mark(d, big / 2, big / 2 + big * 0.04, big * 0.7)
    img.resize((size, size), Image.LANCZOS).save(path)


def adaptive_foreground(path, size=1024):
    # Adaptive icons crop to the inner ~61%; keep the mark inside it.
    big = size * S
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    draw_mark(d, big / 2, big / 2 + big * 0.03, big * 0.56)
    img.resize((size, size), Image.LANCZOS).save(path)


def font(size, bold=True):
    name = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf' if bold else '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    try:
        return ImageFont.truetype(name, size)
    except OSError:
        return ImageFont.load_default()


def feature_graphic(path):
    w, h = 1024, 500
    u = S
    img = gradient_bg(w * S, h * S).convert('RGBA')
    overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.rounded_rectangle([70 * u, 120 * u, 330 * u, 380 * u], radius=56 * u, fill=WHITE)
    draw_mark(od, 200 * u, 262 * u, 176 * u, fg=GREEN, bg=WHITE)
    img = Image.alpha_composite(img, overlay).convert('RGB')
    d = ImageDraw.Draw(img)
    d.text((380 * u, 118 * u), 'LiveHealthy', font=font(56 * u), fill=WHITE)
    d.text((380 * u, 186 * u), 'Know Your', font=font(66 * u), fill=WHITE)
    d.text((380 * u, 262 * u), 'Disease', font=font(66 * u), fill=WHITE)
    d.text((383 * u, 356 * u), 'Blood pressure · Diabetes · Obesity', font=font(26 * u, bold=False), fill=MINT)
    ur = ImageFont.truetype(URDU_FONT, 30 * u, layout_engine=ImageFont.Layout.RAQM)
    d.text((383 * u, 392 * u), 'English |', font=font(26 * u, bold=False), fill=MINT)
    d.text((515 * u, 372 * u), 'اردو', font=ur, fill=MINT, direction='rtl', language='ur')
    img.resize((w, h), Image.LANCZOS).save(path)


if __name__ == '__main__':
    launcher_icon('app/assets/images/app_icon.png')
    adaptive_foreground('app/assets/images/app_icon_foreground.png')
    launcher_icon('store/graphics/app_icon_clean.png')
    launcher_icon('store/graphics/play_store_icon_512.png', size=512)
    feature_graphic('store/graphics/feature_graphic.png')
    print('icons written')
