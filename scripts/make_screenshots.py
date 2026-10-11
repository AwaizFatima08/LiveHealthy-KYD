"""Frames raw phone captures (store/graphics/screenshots/NN_name.png, any
size) into Play Store phone screenshots: 1080×1920 (9:16, which Play's asset library requires), suite
green background, a one-line caption on top, the capture below with rounded
corners. Run from the repo root:  python3 scripts/make_screenshots.py
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SRC = 'store/graphics/screenshots'
OUT = 'store/graphics/phone_screenshots'
W, H = 1080, 1920
LIGHT, DARK = (18, 138, 99), (7, 78, 56)
URDU_FONT = 'app/assets/fonts/NotoNastaliqUrdu-Bold.ttf'

# Caption per capture (file stem without the NN_ prefix): English headline,
# Urdu line under it.
CAPTIONS = {
    'home': ('Plain facts about common diseases', 'عام بیماریوں کے بارے میں آسان حقائق'),
    'newtopics': ('Three new topics added', 'کولیسٹرول، مائیگرین اور چھاتی کا کینسر'),
    'topic': ('The same clear steps for every topic', 'ہر موضوع کے لیے ایک جیسے واضح مراحل'),
    'selfcheck': ('Short animations show you how', 'مختصر اینیمیشنز سے سمجھیں'),
    'section': ('Key numbers, explained simply', 'اہم نمبر، آسان الفاظ میں'),
    'doctor': ('Know when to see a doctor', 'جانیں کب ڈاکٹر کو دکھانا ہے'),
    'reference': ('A trusted source behind every fact', 'ہر بات کے پیچھے معتبر ماخذ'),
    'urdu': ('Read in Urdu or English', 'اردو یا انگریزی میں پڑھیں'),
}


def background():
    gx = Image.linear_gradient('L').rotate(90).resize((W, H))
    gy = Image.linear_gradient('L').resize((W, H))
    mask = Image.blend(Image.eval(gx, lambda v: 255 - v), gy, 0.5)
    return Image.composite(Image.new('RGB', (W, H), DARK), Image.new('RGB', (W, H), LIGHT), mask)


def font(text, size):
    if any('؀' <= c <= 'ۿ' for c in text):
        return ImageFont.truetype(URDU_FONT, size, layout_engine=ImageFont.Layout.RAQM), True
    return ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf', size), False


def line(d, text, size, top, fill):
    while True:  # shrink until the line fits with a margin
        f, urdu = font(text, size)
        kwargs = {'direction': 'rtl', 'language': 'ur'} if urdu else {}
        box = d.textbbox((0, 0), text, font=f, **kwargs)
        if box[2] - box[0] <= W - 120 or size <= 30:
            break
        size -= 2
    d.text(((W - (box[2] - box[0])) / 2 - box[0], top - box[1]), text, font=f, fill=fill, **kwargs)


def frame(path, caption):
    img = background()
    d = ImageDraw.Draw(img)
    en, ur = caption
    line(d, en, 54, 90, (255, 255, 255))
    line(d, ur, 42, 180, (214, 240, 228))

    shot = Image.open(path).convert('RGB')
    # Hide the phone's status bar (clock, personal notification icons).
    bar = round(shot.height * 0.032)
    ImageDraw.Draw(shot).rectangle([0, 0, shot.width, bar], fill=(247, 249, 248))
    target_h = H - 330 - 70
    scale = target_h / shot.height
    shot = shot.resize((round(shot.width * scale), target_h), Image.LANCZOS)
    x, y = (W - shot.width) // 2, 330
    radius = 44
    mask = Image.new('L', shot.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, shot.width - 1, shot.height - 1], radius=radius, fill=255)
    shadow = Image.new('L', (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle([x, y + 14, x + shot.width, y + shot.height + 14], radius=radius, fill=110)
    img.paste((0, 0, 0), (0, 0), shadow.filter(ImageFilter.GaussianBlur(18)))
    img.paste(shot, (x, y), mask)
    return img


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for f in glob.glob(f'{OUT}/*.png'):
        os.remove(f)
    for path in sorted(glob.glob(f'{SRC}/*.png')):
        stem = os.path.splitext(os.path.basename(path))[0]
        key = stem.split('_', 1)[1] if '_' in stem else stem
        frame(path, CAPTIONS.get(key, ('', ''))).save(f'{OUT}/{stem}.png', optimize=True)
        print('framed', stem)
