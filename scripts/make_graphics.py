"""Draws the language-free content graphics (design §3 "image" blocks) as SVG
into app/assets/graphics/. Reproducible and editable in Inkscape.

Rules for every graphic:
  * no words, only numbers and pictures, so one file serves Urdu and English;
    the caption in the content file carries the language;
  * suite colours; green / amber / red match the Vitals flags and are never
    the only signal (captions and key-number boxes label every band);
  * presentation attributes only (no <style>, filters or masks), which
    flutter_svg renders reliably.

Run from the repo root:  python3 scripts/make_graphics.py
"""
import math
import os

OUT = 'app/assets/graphics'

GREEN = '#0B6E4F'
GREEN_MID = '#3E9C7C'
GREEN_LIGHT = '#E3F1EB'
OK = '#1B7F3B'
AMBER = '#B26A00'
AMBER_LIGHT = '#F6E7CF'
RED = '#C62828'
RED_LIGHT = '#F7DADA'
INK = '#1D2B26'
GREY = '#8A9A93'
GREY_LIGHT = '#E2E8E5'
SKIN = '#E9C29E'
SKIN_DARK = '#C99A70'
WHITE = '#FFFFFF'
BLUE = '#2F6DB5'
BLUE_LIGHT = '#DCE8F6'
FONT = 'font-family="Roboto, sans-serif"'


def svg(w, h, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}">\n'
            f'{body}\n</svg>\n')


def text(x, y, s, size=14, fill=INK, weight='700', anchor='middle'):
    return (f'<text x="{x}" y="{y}" {FONT} font-size="{size}" font-weight="{weight}" '
            f'fill="{fill}" text-anchor="{anchor}">{s}</text>')


def heart_path(cx, cy, s):
    """Classic heart, s = half-width."""
    return (f'M{cx} {cy + s * 0.9} '
            f'C{cx - s * 1.25} {cy + s * 0.05} {cx - s * 1.0} {cy - s * 0.95} {cx} {cy - s * 0.35} '
            f'C{cx + s * 1.0} {cy - s * 0.95} {cx + s * 1.25} {cy + s * 0.05} {cx} {cy + s * 0.9} Z')


def drop_path(cx, cy, r):
    """Blood drop: circle of radius r at (cx, cy) with a point on top."""
    top = cy - r * 2.1
    return (f'M{cx} {top} C{cx + r * 0.35} {cy - r * 1.35} {cx + r} {cy - r * 0.75} {cx + r} {cy} '
            f'A{r} {r} 0 0 1 {cx - r} {cy} C{cx - r} {cy - r * 0.75} {cx - r * 0.35} {cy - r * 1.35} {cx} {top} Z')


def person(cx, top, h, fill=GREEN_MID, belly=0.0):
    """Simple standing figure; belly widens the torso (0..1)."""
    head_r = h * 0.1
    body_top = top + head_r * 2 + h * 0.02
    torso_w = h * (0.26 + 0.2 * belly)
    torso_h = h * 0.4
    leg_h = h - (body_top - top) - torso_h
    parts = [
        f'<circle cx="{cx}" cy="{top + head_r}" r="{head_r}" fill="{fill}"/>',
        f'<rect x="{cx - torso_w / 2}" y="{body_top}" width="{torso_w}" height="{torso_h}" '
        f'rx="{torso_w * 0.42}" fill="{fill}"/>',
        f'<rect x="{cx - h * 0.1}" y="{body_top + torso_h * 0.8}" width="{h * 0.085}" height="{leg_h + torso_h * 0.2}" '
        f'rx="{h * 0.04}" fill="{fill}"/>',
        f'<rect x="{cx + h * 0.015}" y="{body_top + torso_h * 0.8}" width="{h * 0.085}" height="{leg_h + torso_h * 0.2}" '
        f'rx="{h * 0.04}" fill="{fill}"/>',
    ]
    return '\n'.join(parts)


# ------------------------------------------------------------------ headers

def hypertension_header():
    body = [
        # gauge
        f'<circle cx="150" cy="96" r="62" fill="{WHITE}" stroke="{GREY_LIGHT}" stroke-width="4"/>',
    ]
    # coloured arc: green -> amber -> red, from 200deg to 340deg (top half)
    def arc(a0, a1, color):
        r = 50
        x0, y0 = 150 + r * math.cos(math.radians(a0)), 96 + r * math.sin(math.radians(a0))
        x1, y1 = 150 + r * math.cos(math.radians(a1)), 96 + r * math.sin(math.radians(a1))
        return (f'<path d="M{x0:.1f} {y0:.1f} A{r} {r} 0 0 1 {x1:.1f} {y1:.1f}" fill="none" '
                f'stroke="{color}" stroke-width="12" stroke-linecap="butt"/>')
    body += [arc(160, 225, OK), arc(225, 290, AMBER), arc(290, 380, RED)]
    # needle pointing into red
    a = math.radians(330)
    body += [
        f'<line x1="150" y1="96" x2="{150 + 42 * math.cos(a):.1f}" y2="{96 + 42 * math.sin(a):.1f}" '
        f'stroke="{INK}" stroke-width="6" stroke-linecap="round"/>',
        f'<circle cx="150" cy="96" r="8" fill="{INK}"/>',
        # heart to the left
        f'<path d="{heart_path(58, 92, 34)}" fill="{RED}"/>',
        f'<path d="M30 95 L46 95 L52 84 L60 106 L68 78 L74 95 L88 95" fill="none" stroke="{WHITE}" '
        f'stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>',
        # tube from gauge to cuff hint
        f'<path d="M150 158 C150 172 200 172 206 150" fill="none" stroke="{GREY}" stroke-width="5"/>',
        f'<rect x="192" y="96" width="34" height="56" rx="10" fill="{GREEN}"/>',
        f'<rect x="199" y="104" width="20" height="8" rx="4" fill="{GREEN_LIGHT}"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def diabetes_group_header():
    body = [
        f'<path d="{drop_path(86, 112, 42)}" fill="{RED}"/>',
        f'<ellipse cx="72" cy="104" rx="10" ry="16" fill="{WHITE}" opacity="0.35"/>',
        # glucometer
        f'<rect x="136" y="44" width="72" height="112" rx="16" fill="{GREEN}"/>',
        f'<rect x="146" y="56" width="52" height="40" rx="6" fill="{GREEN_LIGHT}"/>',
        text(172, 84, '99', 22, GREEN),
        f'<circle cx="160" cy="122" r="9" fill="{GREEN_LIGHT}"/>',
        f'<circle cx="186" cy="122" r="9" fill="{GREEN_LIGHT}"/>',
        f'<rect x="164" y="24" width="16" height="26" rx="3" fill="{GREY_LIGHT}" stroke="{GREY}" stroke-width="2"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def prediabetes_header():
    body = [
        f'<path d="{drop_path(82, 114, 40)}" fill="{AMBER}"/>',
        f'<ellipse cx="68" cy="106" rx="9" ry="15" fill="{WHITE}" opacity="0.35"/>',
        # rising arrow toward a warning
        f'<path d="M132 138 L168 104 L184 118 L214 80" fill="none" stroke="{AMBER}" stroke-width="10" '
        f'stroke-linecap="round" stroke-linejoin="round"/>',
        f'<path d="M198 76 L218 74 L216 94 Z" fill="{AMBER}"/>',
        # stop / turn-back: green curved arrow
        f'<path d="M150 156 C180 164 206 150 214 126" fill="none" stroke="{OK}" stroke-width="8" '
        f'stroke-linecap="round" stroke-dasharray="2 12"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def type2_header():
    body = [
        f'<path d="{drop_path(72, 116, 38)}" fill="{RED}"/>',
        f'<ellipse cx="59" cy="108" rx="8" ry="14" fill="{WHITE}" opacity="0.35"/>',
        # cell with a keyhole, and a key (insulin)
        f'<circle cx="170" cy="96" r="48" fill="{GREEN_LIGHT}" stroke="{GREEN}" stroke-width="5"/>',
        f'<circle cx="170" cy="86" r="10" fill="{GREEN}"/>',
        f'<path d="M164 90 L176 90 L180 114 L160 114 Z" fill="{GREEN}"/>',
        # key
        f'<circle cx="118" cy="40" r="15" fill="none" stroke="{AMBER}" stroke-width="7"/>',
        f'<path d="M129 51 L150 72 M140 62 L146 56 M146 68 L152 62" stroke="{AMBER}" stroke-width="7" '
        f'stroke-linecap="round"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def gestational_header():
    body = [
        # pregnant figure, side view
        f'<circle cx="102" cy="34" r="16" fill="{GREEN_MID}"/>',
        f'<path d="M92 54 C80 70 82 96 88 116 L86 164 L102 164 L106 124 L114 124 L118 164 L134 164 L130 118 '
        f'C150 112 156 88 140 74 C132 66 122 64 116 54 Z" fill="{GREEN_MID}"/>',
        f'<circle cx="136" cy="94" r="8" fill="{GREEN_LIGHT}" opacity="0.8"/>',
        # small drop
        f'<path d="{drop_path(190, 126, 22)}" fill="{RED}"/>',
        f'<ellipse cx="183" cy="122" rx="5" ry="8" fill="{WHITE}" opacity="0.35"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def obesity_header():
    body = [
        # bathroom scale
        f'<rect x="40" y="112" width="160" height="50" rx="16" fill="{GREEN}"/>',
        f'<rect x="92" y="122" width="56" height="22" rx="6" fill="{GREEN_LIGHT}"/>',
        f'<path d="M104 140 A16 16 0 0 1 136 140" fill="none" stroke="{GREEN}" stroke-width="3"/>',
        f'<line x1="120" y1="140" x2="130" y2="128" stroke="{RED}" stroke-width="3" stroke-linecap="round"/>',
        # tape measure loop
        f'<ellipse cx="120" cy="64" rx="60" ry="30" fill="none" stroke="{AMBER}" stroke-width="12"/>',
    ]
    for i in range(12):
        a = math.radians(i * 30)
        x, y = 120 + 60 * math.cos(a), 64 + 30 * math.sin(a)
        body.append(f'<circle cx="{x:.1f}" cy="{y:.1f}" r="2.2" fill="{WHITE}"/>')
    body.append(f'<rect x="168" y="74" width="30" height="22" rx="4" fill="{AMBER}"/>')
    return svg(240, 180, '\n'.join(body))


# ---------------------------------------------------------- content images

def band_chart(w, bands, marker_rows, h=None):
    """Horizontal colour bands with numeric labels underneath.
    bands: [(fraction_width, fill, light_fill)], marker_rows: [(x_fraction, label)]"""
    x0, bar_y, bar_h = 16, 40, 44
    width = w - 32
    parts = []
    x = x0
    for frac, fill, light in bands:
        bw = width * frac
        parts.append(f'<rect x="{x:.1f}" y="{bar_y}" width="{bw:.1f}" height="{bar_h}" fill="{fill}"/>')
        x += bw
    parts.insert(0, f'<rect x="{x0 - 3}" y="{bar_y - 3}" width="{width + 6}" height="{bar_h + 6}" rx="10" fill="{GREY_LIGHT}"/>')
    for fx, label in marker_rows:
        mx = x0 + width * fx
        parts.append(f'<line x1="{mx:.1f}" y1="{bar_y - 8}" x2="{mx:.1f}" y2="{bar_y + bar_h + 8}" stroke="{INK}" stroke-width="2"/>')
        parts.append(text(round(mx, 1), bar_y + bar_h + 28, label, 15))
    return parts


def bp_categories():
    """Five BP bands: <120/<80, 120-129, 130-139/80-89, >=140/>=90, >180/>120."""
    w, h = 340, 150
    parts = band_chart(w, [
        (0.22, OK, None), (0.16, '#D08A1E', None), (0.2, AMBER, None), (0.24, RED, None), (0.18, '#8E1B1B', None),
    ], [(0.22, '120'), (0.38, '130'), (0.58, '140'), (0.82, '180')])
    # diastolic row
    x0, width = 16, w - 32
    for fx, label in [(0.38, '80'), (0.58, '90'), (0.82, '120')]:
        parts.append(text(round(x0 + width * fx, 1), 132, label, 13, GREY, '600'))
    parts.append(text(16, 26, 'mmHg', 13, GREY, '600', 'start'))
    # little icons inside bands: tick / ! / !!
    parts.append(f'<path d="M40 62 L48 70 L62 54" fill="none" stroke="{WHITE}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    parts.append(text(300, 71, '!!', 20, WHITE))
    return svg(w, h, '\n'.join(parts))


def glucose_fasting():
    """Fasting glucose bands: <70 low, 70-99 normal, 100-125 prediabetes, >=126 diabetes."""
    w, h = 340, 130
    parts = band_chart(w, [
        (0.18, RED, None), (0.34, OK, None), (0.26, AMBER, None), (0.22, RED, None),
    ], [(0.18, '70'), (0.52, '100'), (0.78, '126')])
    parts.append(text(16, 26, 'mg/dL', 13, GREY, '600', 'start'))
    parts.append(f'<path d="M100 62 L108 70 L122 54" fill="none" stroke="{WHITE}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    return svg(w, h, '\n'.join(parts))


def bmi_scale():
    """BMI bands 18.5 / 25 / 30, with the WHO Asian action points 23 and 27.5 dashed."""
    w, h = 340, 150
    parts = band_chart(w, [
        (0.18, AMBER, None), (0.34, OK, None), (0.24, AMBER, None), (0.24, RED, None),
    ], [(0.18, '18.5'), (0.52, '25'), (0.76, '30')])
    x0, width = 16, w - 32
    # Asian action points, on the same axis (16..36 mapped by the bands above:
    # 18.5 at 0.18, 25 at 0.52, 30 at 0.76 -> linear pieces)
    def pos(v):
        if v <= 25:
            return 0.18 + (v - 18.5) / (25 - 18.5) * 0.34
        return 0.52 + (v - 25) / (30 - 25) * 0.24
    for v, lab in [(23, '23'), (27.5, '27.5')]:
        mx = x0 + width * pos(v)
        parts.append(f'<line x1="{mx:.1f}" y1="30" x2="{mx:.1f}" y2="94" stroke="{INK}" stroke-width="2" stroke-dasharray="4 4"/>')
        parts.append(text(round(mx, 1), 24, lab, 13, INK, '600'))
    parts.append(text(16, 140, 'kg/m²', 13, GREY, '600', 'start'))
    return svg(w, h, '\n'.join(parts))


def body_outline(cx, top, scale=1.0, fill=GREEN_LIGHT, stroke=GREEN):
    s = scale
    return (f'<path d="M{cx} {top} m-18 22 a18 20 0 1 0 36 0 a18 20 0 1 0 -36 0 '
            f'M{cx - 14 * s} {top + 44 * s} L{cx + 14 * s} {top + 44 * s} '
            f'C{cx + 46 * s} {top + 48 * s} {cx + 52 * s} {top + 60 * s} {cx + 54 * s} {top + 90 * s} '
            f'L{cx + 58 * s} {top + 150 * s} L{cx + 44 * s} {top + 152 * s} L{cx + 38 * s} {top + 96 * s} '
            f'L{cx + 36 * s} {top + 160 * s} L{cx + 32 * s} {top + 250 * s} L{cx + 8 * s} {top + 250 * s} '
            f'L{cx + 2 * s} {top + 168 * s} L{cx - 2 * s} {top + 168 * s} L{cx - 8 * s} {top + 250 * s} '
            f'L{cx - 32 * s} {top + 250 * s} L{cx - 36 * s} {top + 160 * s} L{cx - 38 * s} {top + 96 * s} '
            f'L{cx - 44 * s} {top + 152 * s} L{cx - 58 * s} {top + 150 * s} L{cx - 54 * s} {top + 90 * s} '
            f'C{cx - 52 * s} {top + 60 * s} {cx - 46 * s} {top + 48 * s} {cx - 14 * s} {top + 44 * s} Z" '
            f'fill="{fill}" stroke="{stroke}" stroke-width="3" stroke-linejoin="round"/>')


def organ_marks(organs):
    """Numbered callouts around a body. organs: [(x, y, label_x, label_y, n, icon_svg)]."""
    parts = []
    for x, y, lx, ly, n, icon in organs:
        parts.append(f'<line x1="{x}" y1="{y}" x2="{lx}" y2="{ly}" stroke="{GREY}" stroke-width="2"/>')
        parts.append(f'<circle cx="{x}" cy="{y}" r="7" fill="{RED}"/>')
        parts.append(f'<circle cx="{lx}" cy="{ly}" r="26" fill="{WHITE}" stroke="{RED}" stroke-width="3"/>')
        parts.append(icon(lx, ly))
    return parts


def icon_brain(x, y):
    return (f'<path d="M{x - 14} {y + 4} C{x - 20} {y - 8} {x - 8} {y - 18} {x} {y - 12} '
            f'C{x + 8} {y - 18} {x + 20} {y - 8} {x + 14} {y + 4} C{x + 12} {y + 12} {x - 12} {y + 12} {x - 14} {y + 4} Z" '
            f'fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>'
            f'<path d="M{x} {y - 12} L{x} {y + 9}" stroke="{RED}" stroke-width="2"/>')


def icon_eye(x, y):
    return (f'<path d="M{x - 16} {y} Q{x} {y - 14} {x + 16} {y} Q{x} {y + 14} {x - 16} {y} Z" fill="{WHITE}" stroke="{RED}" stroke-width="2.5"/>'
            f'<circle cx="{x}" cy="{y}" r="6" fill="{RED}"/>')


def icon_heart(x, y):
    return f'<path d="{heart_path(x, y + 1, 14)}" fill="{RED}"/>'


def icon_kidney(x, y):
    return (f'<path d="M{x + 4} {y - 14} C{x - 14} {y - 18} {x - 16} {y + 16} {x + 2} {y + 14} '
            f'C{x + 10} {y + 12} {x + 4} {y + 4} {x + 8} {y} C{x + 4} {y - 4} {x + 12} {y - 12} {x + 4} {y - 14} Z" '
            f'fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>')


def icon_foot(x, y):
    return (f'<path d="M{x - 6} {y - 14} C{x + 6} {y - 16} {x + 8} {y} {x + 6} {y + 8} C{x + 4} {y + 16} {x - 10} {y + 16} {x - 10} {y + 6} '
            f'C{x - 10} {y - 2} {x - 12} {y - 10} {x - 6} {y - 14} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>'
            f'<circle cx="{x + 10}" cy="{y - 12}" r="2.5" fill="{RED}"/><circle cx="{x + 12}" cy="{y - 5}" r="2.2" fill="{RED}"/>')


def icon_vessel(x, y):
    return (f'<path d="M{x - 16} {y + 8} C{x - 6} {y - 12} {x + 6} {y + 12} {x + 16} {y - 8}" fill="none" stroke="{RED}" stroke-width="7" stroke-linecap="round"/>'
            f'<path d="M{x - 16} {y + 8} C{x - 6} {y - 12} {x + 6} {y + 12} {x + 16} {y - 8}" fill="none" stroke="{RED_LIGHT}" stroke-width="2.5" stroke-linecap="round"/>')


def bp_organs():
    w, h = 340, 290
    parts = [body_outline(170, 18)]
    parts += organ_marks([
        (165, 28, 60, 40, 1, icon_brain),
        (177, 44, 280, 40, 2, icon_eye),
        (182, 92, 60, 120, 3, icon_heart),
        (184, 132, 280, 132, 4, icon_kidney),
        (156, 190, 60, 210, 5, icon_vessel),
    ])
    return svg(w, h, '\n'.join(parts))


def diabetes_organs():
    w, h = 340, 290
    parts = [body_outline(170, 18)]
    parts += organ_marks([
        (177, 44, 60, 40, 1, icon_eye),
        (182, 92, 280, 70, 2, icon_heart),
        (184, 132, 60, 132, 3, icon_kidney),
        (156, 190, 280, 170, 4, icon_vessel),
        (150, 262, 60, 240, 5, icon_foot),
    ])
    return svg(w, h, '\n'.join(parts))


def bp_measure():
    """Seated, back supported, feet flat, arm supported at heart level, cuff on bare upper arm."""
    w, h = 340, 220
    p = [
        # chair
        f'<rect x="70" y="60" width="12" height="100" rx="4" fill="{GREY}"/>',
        f'<rect x="70" y="140" width="96" height="12" rx="4" fill="{GREY}"/>',
        f'<rect x="80" y="150" width="8" height="54" fill="{GREY}"/><rect x="150" y="150" width="8" height="54" fill="{GREY}"/>',
        # table
        f'<rect x="196" y="108" width="120" height="10" rx="4" fill="{SKIN_DARK}"/>',
        f'<rect x="290" y="116" width="8" height="88" fill="{SKIN_DARK}"/>',
        # person: head, torso, thigh, shin, arm
        f'<circle cx="112" cy="46" r="18" fill="{GREEN_MID}"/>',
        f'<rect x="90" y="68" width="40" height="76" rx="16" fill="{GREEN_MID}"/>',
        f'<rect x="100" y="126" width="80" height="20" rx="10" fill="{GREEN}"/>',
        f'<rect x="164" y="130" width="20" height="74" rx="10" fill="{GREEN}"/>',
        f'<rect x="160" y="198" width="36" height="10" rx="5" fill="{INK}"/>',
        f'<rect x="112" y="84" width="16" height="36" rx="8" fill="{GREEN_MID}"/>',
        f'<rect x="112" y="104" width="100" height="14" rx="7" fill="{GREEN_MID}"/>',
        # cuff + tube + monitor
        f'<rect x="108" y="84" width="24" height="22" rx="5" fill="{BLUE}"/>',
        f'<path d="M132 94 C170 80 220 70 240 92" fill="none" stroke="{GREY}" stroke-width="3"/>',
        f'<rect x="232" y="76" width="54" height="32" rx="6" fill="{WHITE}" stroke="{GREEN}" stroke-width="3"/>',
        text(259, 98, '120/80', 12, GREEN),
        # floor
        f'<line x1="40" y1="208" x2="320" y2="208" stroke="{GREY_LIGHT}" stroke-width="3"/>',
        # heart-level guide
        f'<line x1="40" y1="100" x2="330" y2="100" stroke="{AMBER}" stroke-width="2" stroke-dasharray="6 6"/>',
        f'<path d="{heart_path(26, 100, 9)}" fill="{RED}"/>',
    ]
    return svg(w, h, '\n'.join(p))


def salt_limit():
    """One level teaspoon = 5 g salt per day (WHO)."""
    w, h = 340, 150
    p = [
        f'<ellipse cx="116" cy="84" rx="54" ry="30" fill="{GREY_LIGHT}" stroke="{GREY}" stroke-width="3"/>',
        f'<ellipse cx="116" cy="80" rx="44" ry="20" fill="{WHITE}"/>',
    ]
    for i in range(26):
        x = 84 + (i * 37) % 64
        y = 72 + (i * 13) % 16
        p.append(f'<rect x="{x}" y="{y}" width="4" height="4" fill="{GREY}" transform="rotate(20 {x} {y})"/>')
    p += [
        f'<rect x="166" y="78" width="120" height="12" rx="6" fill="{GREY}"/>',
        text(116, 138, '≤ 5 g', 22, GREEN),
        # clock-day marker
        f'<circle cx="300" cy="44" r="22" fill="{GREEN_LIGHT}" stroke="{GREEN}" stroke-width="3"/>',
        text(300, 50, '24h', 14, GREEN),
    ]
    return svg(w, h, '\n'.join(p))


def healthy_plate():
    """Half vegetables, a quarter protein, a quarter whole grains; water."""
    w, h = 340, 220
    cx, cy, r = 140, 110, 90
    p = [
        f'<circle cx="{cx}" cy="{cy}" r="{r + 10}" fill="{WHITE}" stroke="{GREY_LIGHT}" stroke-width="4"/>',
        # half: vegetables (left)
        f'<path d="M{cx} {cy - r} A{r} {r} 0 0 0 {cx} {cy + r} Z" fill="#6FB36B"/>',
        # quarter: protein (top right)
        f'<path d="M{cx} {cy} L{cx} {cy - r} A{r} {r} 0 0 1 {cx + r} {cy} Z" fill="#C9745A"/>',
        # quarter: grains (bottom right)
        f'<path d="M{cx} {cy} L{cx + r} {cy} A{r} {r} 0 0 1 {cx} {cy + r} Z" fill="#E1B96A"/>',
        f'<line x1="{cx}" y1="{cy - r}" x2="{cx}" y2="{cy + r}" stroke="{WHITE}" stroke-width="4"/>',
        f'<line x1="{cx}" y1="{cy}" x2="{cx + r}" y2="{cy}" stroke="{WHITE}" stroke-width="4"/>',
    ]
    # veg: leaves
    for (x, y) in [(84, 70), (100, 110), (80, 145), (112, 160), (112, 60)]:
        p.append(f'<ellipse cx="{x}" cy="{y}" rx="14" ry="8" fill="#3F8F43" transform="rotate(-30 {x} {y})"/>')
    for (x, y) in [(76, 105), (98, 138)]:
        p.append(f'<circle cx="{x}" cy="{y}" r="8" fill="#D9453B"/>')
    # protein: bean-ish / fish
    for (x, y) in [(170, 60), (190, 82), (164, 88)]:
        p.append(f'<ellipse cx="{x}" cy="{y}" rx="12" ry="7" fill="#8E4A33"/>')
    # grains: dots
    for i in range(14):
        x = 152 + (i * 23) % 60
        y = 124 + (i * 17) % 50
        if (x - cx) ** 2 + (y - cy) ** 2 < (r - 10) ** 2:
            p.append(f'<ellipse cx="{x}" cy="{y}" rx="5" ry="3" fill="#A87A2A"/>')
    # water glass
    p += [
        f'<path d="M262 60 L302 60 L296 170 L268 170 Z" fill="{BLUE_LIGHT}" stroke="{BLUE}" stroke-width="3"/>',
        f'<path d="M266 92 L298 92 L296 168 L268 168 Z" fill="{BLUE}" opacity="0.35"/>',
    ]
    return svg(w, h, '\n'.join(p))


def activity_week():
    """150 minutes a week: 5 x 30 min brisk walking, 2 rest days."""
    w, h = 340, 150
    p = []
    for i in range(7):
        x = 14 + i * 46
        active = i < 5
        fill = GREEN if active else GREY_LIGHT
        p.append(f'<rect x="{x}" y="20" width="40" height="80" rx="10" fill="{fill if active else WHITE}" stroke="{fill}" stroke-width="3"/>')
        if active:
            # walker
            p.append(f'<circle cx="{x + 22}" cy="36" r="6" fill="{WHITE}"/>')
            p.append(f'<path d="M{x + 21} 44 L{x + 18} 62 L{x + 12} 78 M{x + 18} 62 L{x + 26} 78 M{x + 21} 48 L{x + 12} 58 M{x + 21} 48 L{x + 30} 56" '
                     f'fill="none" stroke="{WHITE}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>')
            p.append(text(x + 20, 96, '30', 13, WHITE))
        else:
            p.append(f'<circle cx="{x + 20}" cy="60" r="10" fill="none" stroke="{GREY}" stroke-width="3"/>')
    p.append(text(170, 134, '5 × 30 = 150 min', 18, GREEN))
    return svg(w, h, '\n'.join(p))


def waist_measure():
    """Waist less than half your height."""
    w, h = 340, 240
    p = [
        body_outline(120, 10, 0.88),
        # tape at waist
        f'<rect x="72" y="120" width="96" height="12" rx="6" fill="{AMBER}"/>',
    ]
    for i in range(8):
        p.append(f'<line x1="{80 + i * 11}" y1="121" x2="{80 + i * 11}" y2="127" stroke="{WHITE}" stroke-width="2"/>')
    # height bar
    p += [
        f'<line x1="206" y1="12" x2="206" y2="232" stroke="{GREEN}" stroke-width="4"/>',
        f'<line x1="196" y1="12" x2="216" y2="12" stroke="{GREEN}" stroke-width="4"/>',
        f'<line x1="196" y1="232" x2="216" y2="232" stroke="{GREEN}" stroke-width="4"/>',
        f'<line x1="200" y1="122" x2="212" y2="122" stroke="{GREEN}" stroke-width="3"/>',
        # ratio
        f'<rect x="232" y="98" width="96" height="48" rx="12" fill="{GREEN_LIGHT}"/>',
        f'<rect x="248" y="108" width="30" height="10" rx="5" fill="{AMBER}"/>',
        f'<line x1="244" y1="122" x2="316" y2="122" stroke="{INK}" stroke-width="2"/>',
        f'<rect x="248" y="128" width="30" height="10" rx="5" fill="{GREEN}"/>',
        text(300, 140, '&lt; ½', 16, INK),
    ]
    return svg(w, h, '\n'.join(p))


def insulin_key():
    """Insulin works like a key that lets sugar into the body's cells."""
    w, h = 340, 180
    p = [
        # blood vessel strip with glucose dots
        f'<rect x="10" y="60" width="130" height="60" rx="30" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="3"/>',
    ]
    for (x, y) in [(36, 80), (60, 100), (84, 78), (108, 98), (124, 76)]:
        p.append(f'<rect x="{x - 6}" y="{y - 6}" width="12" height="12" rx="2" fill="{AMBER}"/>')
    # key
    p += [
        f'<circle cx="160" cy="44" r="13" fill="none" stroke="{GREEN}" stroke-width="7"/>',
        f'<path d="M170 54 L188 72 M180 64 L186 58 M186 70 L192 64" stroke="{GREEN}" stroke-width="7" stroke-linecap="round"/>',
        # cell with open door
        f'<circle cx="262" cy="90" r="62" fill="{GREEN_LIGHT}" stroke="{GREEN}" stroke-width="5"/>',
        f'<rect x="196" y="74" width="16" height="32" fill="{WHITE}" stroke="{GREEN}" stroke-width="3"/>',
        f'<path d="M146 90 L190 90" stroke="{AMBER}" stroke-width="4" stroke-dasharray="6 5"/>',
        f'<path d="M186 82 L198 90 L186 98 Z" fill="{AMBER}"/>',
    ]
    for (x, y) in [(252, 70), (276, 96), (246, 108), (286, 70)]:
        p.append(f'<rect x="{x - 6}" y="{y - 6}" width="12" height="12" rx="2" fill="{AMBER}"/>')
    p.append(f'<path d="M244 136 L262 150 L280 136" fill="none" stroke="{GREEN}" stroke-width="5" stroke-linecap="round"/>')
    return svg(w, h, '\n'.join(p))


def gdm_timeline():
    """Pregnancy weeks 0-40 with the usual screening window at 24-28 weeks."""
    w, h = 340, 130
    x0, x1 = 20, 320
    def xw(week):
        return x0 + (x1 - x0) * week / 40
    p = [
        f'<rect x="{x0}" y="50" width="{x1 - x0}" height="18" rx="9" fill="{GREEN_LIGHT}" stroke="{GREEN}" stroke-width="2"/>',
        f'<rect x="{xw(24):.1f}" y="44" width="{xw(28) - xw(24):.1f}" height="30" rx="6" fill="{AMBER}"/>',
        f'<path d="{drop_path(round(xw(26), 1), 28, 8)}" fill="{RED}"/>',
    ]
    for wk in (0, 12, 24, 28, 40):
        p.append(f'<line x1="{xw(wk):.1f}" y1="74" x2="{xw(wk):.1f}" y2="84" stroke="{INK}" stroke-width="2"/>')
        p.append(text(round(xw(wk), 1), 104, str(wk), 15))
    p.append(f'<circle cx="{x1 + 2}" cy="59" r="0" fill="none"/>')
    return svg(w, h, '\n'.join(p))


def foot_check():
    """Check both feet every day; mirror for the soles."""
    w, h = 340, 180
    def foot(cx, flip=1):
        return (f'<path d="M{cx} 36 C{cx + 26 * flip} 30 {cx + 34 * flip} 64 {cx + 30 * flip} 96 '
                f'C{cx + 28 * flip} 128 {cx + 26 * flip} 160 {cx + 4 * flip} 162 C{cx - 18 * flip} 164 {cx - 20 * flip} 130 {cx - 16 * flip} 104 '
                f'C{cx - 12 * flip} 78 {cx - 26 * flip} 44 {cx} 36 Z" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="3"/>')
    p = [foot(90, -1), foot(160, 1)]
    for i, (dx, dy, r) in enumerate([(-6, 20, 8), (10, 18, 6), (22, 24, 5), (30, 32, 4.5), (36, 42, 4)]):
        p.append(f'<circle cx="{160 + dx}" cy="{dy + 6}" r="{r}" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2"/>')
        p.append(f'<circle cx="{90 - dx}" cy="{dy + 6}" r="{r}" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2"/>')
    p += [
        # magnifier
        f'<circle cx="250" cy="80" r="34" fill="{WHITE}" fill-opacity="0.6" stroke="{GREEN}" stroke-width="8"/>',
        f'<line x1="274" y1="104" x2="306" y2="140" stroke="{GREEN}" stroke-width="12" stroke-linecap="round"/>',
        f'<path d="M234 80 L246 92 L268 68" fill="none" stroke="{OK}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"/>',
    ]
    return svg(w, h, '\n'.join(p))


def glucose_after_meal():
    """After-meal / random glucose bands: <70, <140, 140-199, >=200."""
    w, h = 340, 130
    parts = band_chart(w, [
        (0.16, RED, None), (0.38, OK, None), (0.26, AMBER, None), (0.2, RED, None),
    ], [(0.16, '70'), (0.54, '140'), (0.8, '200')])
    parts.append(text(16, 26, 'mg/dL', 13, GREY, '600', 'start'))
    return svg(w, h, '\n'.join(parts))


# ---------------------------------------------------------- v1.1 topics

PINK = '#C2185B'
PINK_LIGHT = '#F8D7E5'
FAT = '#E1B96A'
FAT_DARK = '#B8862B'


def tick(x, y, s=1.0, color=OK):
    return (f'<path d="M{x - 10 * s} {y} L{x - 3 * s} {y + 8 * s} L{x + 11 * s} {y - 9 * s}" fill="none" '
            f'stroke="{color}" stroke-width="{5 * s}" stroke-linecap="round" stroke-linejoin="round"/>')


def cross(x, y, s=1.0, color=RED):
    return (f'<path d="M{x - 9 * s} {y - 9 * s} L{x + 9 * s} {y + 9 * s} M{x + 9 * s} {y - 9 * s} L{x - 9 * s} {y + 9 * s}" '
            f'stroke="{color}" stroke-width="{5 * s}" stroke-linecap="round"/>')


def breast_cancer_header():
    """Awareness ribbon."""
    body = [
        f'<circle cx="120" cy="92" r="70" fill="{PINK_LIGHT}"/>',
        f'<path d="M86 160 L132 82 C150 50 142 28 120 28 C98 28 90 50 108 82 L154 160" fill="none" '
        f'stroke="{PINK}" stroke-width="20" stroke-linecap="round" stroke-linejoin="round"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def high_cholesterol_header():
    """Artery cross-section narrowed by plaque, and a fat drop."""
    body = [
        f'<circle cx="100" cy="92" r="64" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="6"/>',
        f'<path d="M48 120 A58 58 0 0 1 64 46 C86 64 92 98 70 132 Z" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="3"/>',
        f'<ellipse cx="116" cy="92" rx="30" ry="40" fill="{RED}"/>',
        f'<circle cx="122" cy="84" r="7" fill="{WHITE}" opacity="0.35"/>',
        f'<path d="{drop_path(196, 120, 22)}" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="3"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def migraine_header():
    """Head in profile with a zigzag (aura) and pain bolt."""
    body = [
        f'<path d="M70 168 L72 132 C46 118 40 84 52 60 C66 32 100 20 128 30 C154 40 166 62 166 84 '
        f'L180 106 L166 110 L168 128 C168 140 158 144 146 142 L134 140 L134 168 Z" fill="{GREEN_MID}"/>',
        f'<path d="M150 50 L170 44 L162 60 L184 56" fill="none" stroke="{AMBER}" stroke-width="6" '
        f'stroke-linecap="round" stroke-linejoin="round"/>',
        f'<path d="M96 46 L84 74 L100 74 L88 104" fill="none" stroke="{WHITE}" stroke-width="8" '
        f'stroke-linecap="round" stroke-linejoin="round"/>',
        f'<circle cx="196" cy="36" r="5" fill="{AMBER}"/><circle cx="206" cy="66" r="4" fill="{AMBER}"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def breast_icon(cx, cy, r=28, outline=True):
    """Front view as used on self-exam charts: a circle with the areola and nipple."""
    out = f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{PINK_LIGHT}" stroke="{PINK}" stroke-width="3"/>' if outline else ''
    return out + (f'<circle cx="{cx}" cy="{cy}" r="{r * 0.28}" fill="#E8A1BE"/>'
                  f'<circle cx="{cx}" cy="{cy}" r="{r * 0.11}" fill="{PINK}"/>')


def breast_signs():
    """Six changes to look for, one per card (no words; the caption names them)."""
    w, h = 340, 240
    cards = [(60, 64), (170, 64), (280, 64), (60, 176), (170, 176), (280, 176)]
    p = []
    for x, y in cards:
        p.append(f'<rect x="{x - 50}" y="{y - 50}" width="100" height="100" rx="16" fill="{WHITE}" stroke="{GREY_LIGHT}" stroke-width="3"/>')
    # 1 lump
    p.append(breast_icon(60, 62))
    p.append(f'<circle cx="44" cy="52" r="7" fill="{RED}"/>')
    # 2 change in size or shape: a dashed, larger outline
    p.append(breast_icon(170, 64, 24))
    p.append(f'<ellipse cx="174" cy="60" rx="36" ry="32" fill="none" stroke="{RED}" stroke-width="3" stroke-dasharray="5 5"/>')
    # 3 dimpled ("orange peel") or red skin
    p.append(f'<circle cx="280" cy="62" r="28" fill="#F3B9C9" stroke="{PINK}" stroke-width="3"/>')
    p.append(breast_icon(280, 62, outline=False))
    for dx, dy in [(-14, -10), (-4, -16), (10, -12), (-16, 6), (14, 8), (-6, 16), (8, 18)]:
        p.append(f'<circle cx="{280 + dx}" cy="{62 + dy}" r="2.4" fill="{RED}"/>')
    # 4 nipple turning inward
    p.append(breast_icon(60, 174))
    p.append(f'<path d="M60 140 L60 166 M51 157 L60 167 L69 157" fill="none" stroke="{RED}" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>')
    # 5 fluid from the nipple
    p.append(breast_icon(170, 170))
    p.append(f'<path d="{drop_path(170, 210, 6)}" fill="{RED}"/>')
    # 6 lump in the armpit: arm raised, dot in the armpit
    p.append(f'<path d="M250 216 L254 170 C256 150 270 146 282 150 L300 134 L312 142 L292 164 L296 216 Z" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="3"/>')
    p.append(f'<circle cx="276" cy="162" r="7" fill="{RED}"/>')
    return svg(w, h, '\n'.join(p))


def icon_lungs(x, y):
    return (f'<path d="M{x - 3} {y - 12} C{x - 16} {y - 12} {x - 18} {y + 6} {x - 14} {y + 12} C{x - 8} {y + 14} {x - 4} {y + 10} {x - 3} {y + 4} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>'
            f'<path d="M{x + 3} {y - 12} C{x + 16} {y - 12} {x + 18} {y + 6} {x + 14} {y + 12} C{x + 8} {y + 14} {x + 4} {y + 10} {x + 3} {y + 4} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>')


def icon_liver(x, y):
    return (f'<path d="M{x - 16} {y - 4} C{x - 14} {y - 14} {x + 14} {y - 14} {x + 16} {y - 8} C{x + 12} {y + 4} {x} {y + 12} {x - 10} {y + 10} '
            f'C{x - 16} {y + 8} {x - 18} {y + 2} {x - 16} {y - 4} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>')


def icon_bone(x, y):
    return (f'<rect x="{x - 12}" y="{y - 3}" width="24" height="6" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2"/>'
            + ''.join(f'<circle cx="{x + dx}" cy="{y + dy}" r="4.5" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2"/>'
                      for dx, dy in [(-13, -4), (-13, 4), (13, -4), (13, 4)]))


def icon_node(x, y):
    return ''.join(f'<circle cx="{x + dx}" cy="{y + dy}" r="5" fill="{RED}"/>' for dx, dy in [(-7, -4), (5, -6), (0, 6)])


def breast_spread():
    w, h = 340, 290
    parts = [body_outline(170, 18)]
    parts += organ_marks([
        (165, 28, 60, 40, 1, icon_brain),
        (148, 96, 280, 50, 2, icon_node),
        (178, 98, 60, 120, 3, icon_lungs),
        (182, 132, 280, 140, 4, icon_liver),
        (150, 215, 60, 220, 5, icon_bone),
    ])
    return svg(w, h, '\n'.join(parts))


def mammogram_timeline():
    """A screening dot every 2 years from 40 to 74."""
    w, h = 340, 130
    x0, x1 = 24, 316

    def xa(age):
        return x0 + (x1 - x0) * (age - 40) / 34
    p = [f'<rect x="{x0 - 8}" y="52" width="{x1 - x0 + 16}" height="16" rx="8" fill="{PINK_LIGHT}"/>']
    for age in range(40, 75, 2):
        p.append(f'<circle cx="{xa(age):.1f}" cy="60" r="6" fill="{PINK}"/>')
    for age in (40, 50, 60, 74):
        p.append(f'<line x1="{xa(age):.1f}" y1="74" x2="{xa(age):.1f}" y2="84" stroke="{INK}" stroke-width="2"/>')
        p.append(text(round(xa(age), 1), 104, str(age), 15))
    # "every 2 years" bracket
    p.append(f'<path d="M{xa(40):.1f} 40 L{xa(40):.1f} 32 L{xa(42):.1f} 32 L{xa(42):.1f} 40" fill="none" stroke="{GREY}" stroke-width="2"/>')
    p.append(text(round((xa(40) + xa(42)) / 2, 1), 26, '2', 13, GREY))
    return svg(w, h, '\n'.join(p))


def cholesterol_risks():
    w, h = 340, 290
    parts = [body_outline(170, 18)]
    parts += organ_marks([
        (165, 28, 60, 40, 1, icon_brain),
        (172, 58, 280, 40, 2, icon_vessel),
        (182, 92, 60, 130, 3, icon_heart),
        (156, 200, 280, 200, 4, icon_vessel),
    ])
    return svg(w, h, '\n'.join(parts))


def fats_swap():
    """Ghee / butter / fried food  ->  fish, nuts, oil."""
    w, h = 340, 180
    p = [
        f'<rect x="8" y="16" width="140" height="148" rx="18" fill="{RED_LIGHT}"/>',
        f'<rect x="192" y="16" width="140" height="148" rx="18" fill="{GREEN_LIGHT}"/>',
        # ghee tin
        f'<rect x="26" y="44" width="46" height="54" rx="6" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="3"/>',
        f'<rect x="22" y="38" width="54" height="10" rx="4" fill="{FAT_DARK}"/>',
        # butter block
        f'<path d="M86 88 L126 80 L138 92 L98 100 Z" fill="#F4DC8A" stroke="{FAT_DARK}" stroke-width="3"/>',
        f'<path d="M86 88 L86 100 L98 112 L98 100 Z M98 100 L138 92 L138 104 L98 112 Z" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="3"/>',
        # fried item (samosa triangle)
        f'<path d="M40 150 L66 112 L92 150 Z" fill="#C98A3A" stroke="#8E5A1E" stroke-width="3"/>',
        cross(124, 136, 1.4),
        # arrow
        f'<path d="M154 90 L184 90" stroke="{GREY}" stroke-width="6" stroke-linecap="round"/>',
        f'<path d="M176 80 L188 90 L176 100 Z" fill="{GREY}"/>',
        # fish
        f'<path d="M200 64 C212 50 236 50 246 64 C236 78 212 78 200 64 Z" fill="{BLUE_LIGHT}" stroke="{BLUE}" stroke-width="3"/>',
        f'<path d="M246 64 L260 54 L260 74 Z" fill="{BLUE_LIGHT}" stroke="{BLUE}" stroke-width="3"/>',
        f'<circle cx="212" cy="61" r="3" fill="{BLUE}"/>',
        # oil bottle
        f'<path d="M294 30 L306 30 L306 46 C318 52 320 60 320 70 L320 112 C320 118 316 120 312 120 L288 120 C284 120 280 118 280 112 L280 70 '
        f'C280 60 282 52 294 46 Z" fill="#E8E2A0" stroke="#9A9030" stroke-width="3"/>',
        # nuts
    ]
    for x, y in [(214, 126), (232, 134), (250, 124), (226, 116)]:
        p.append(f'<ellipse cx="{x}" cy="{y}" rx="10" ry="7" fill="#B98955" stroke="#7A5530" stroke-width="2"/>')
    p.append(tick(292, 146, 1.4))
    return svg(w, h, '\n'.join(p))


def migraine_phases():
    """Early signs -> aura -> headache -> recovery, as four coloured segments with icons."""
    w, h = 340, 130
    segs = [(14, 92, '#9FB8AE'), (106, 60, AMBER), (166, 104, RED), (270, 56, GREEN_MID)]
    p = []
    for x, sw, c in segs:
        p.append(f'<rect x="{x}" y="96" width="{sw}" height="18" fill="{c}"/>')
    p.append(f'<rect x="12" y="94" width="316" height="22" rx="11" fill="none" stroke="{GREY_LIGHT}" stroke-width="4"/>')
    # early signs: yawning face
    p.append(f'<circle cx="60" cy="52" r="26" fill="{WHITE}" stroke="#7E9A8F" stroke-width="4"/>')
    p.append(f'<path d="M48 44 L56 44 M64 44 L72 44" stroke="#7E9A8F" stroke-width="4" stroke-linecap="round"/>')
    p.append(f'<ellipse cx="60" cy="62" rx="6" ry="8" fill="#7E9A8F"/>')
    # aura: zigzag + sparkle
    p.append(f'<path d="M114 60 L126 40 L136 62 L146 40 L158 62" fill="none" stroke="{AMBER}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    # headache: head with bolt
    p.append(f'<circle cx="218" cy="52" r="28" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="4"/>')
    p.append(f'<path d="M222 30 L210 54 L224 54 L212 76" fill="none" stroke="{RED}" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>')
    # recovery: battery recharging
    p.append(f'<rect x="282" y="36" width="34" height="34" rx="5" fill="{WHITE}" stroke="{GREEN_MID}" stroke-width="4"/>')
    p.append(f'<rect x="294" y="30" width="10" height="6" rx="2" fill="{GREEN_MID}"/>')
    p.append(f'<rect x="288" y="52" width="22" height="13" rx="2" fill="{GREEN_MID}"/>')
    return svg(w, h, '\n'.join(p))


def migraine_triggers():
    """Skipped meal, caffeine, poor sleep, stress, periods."""
    w, h = 340, 150
    p = []
    xs = [38, 104, 170, 236, 302]
    for x in xs:
        p.append(f'<circle cx="{x}" cy="64" r="30" fill="{AMBER_LIGHT}"/>')
    # 1 empty plate + clock hand
    p.append(f'<circle cx="38" cy="64" r="18" fill="{WHITE}" stroke="{FAT_DARK}" stroke-width="3"/>')
    p.append(f'<path d="M38 64 L38 52 M38 64 L47 68" stroke="{INK}" stroke-width="3" stroke-linecap="round"/>')
    # 2 cup
    p.append(f'<path d="M90 52 L114 52 L112 78 L92 78 Z" fill="{WHITE}" stroke="#7A5530" stroke-width="3"/>')
    p.append(f'<path d="M114 58 C124 58 124 70 113 70" fill="none" stroke="#7A5530" stroke-width="3"/>')
    p.append(f'<path d="M96 46 C94 40 100 38 98 32 M106 46 C104 40 110 38 108 32" fill="none" stroke="{GREY}" stroke-width="2.5" stroke-linecap="round"/>')
    # 3 moon, broken
    p.append(f'<path d="M178 48 A18 18 0 1 0 184 78 A14 14 0 1 1 178 48 Z" fill="#5C6BC0"/>')
    p.append(f'<path d="M152 50 L160 58 M160 50 L152 58" stroke="{RED}" stroke-width="3" stroke-linecap="round"/>')
    # 4 stress: cloud with bolt
    p.append(f'<path d="M218 70 C210 70 210 56 220 56 C222 46 238 44 242 54 C252 52 256 66 248 70 Z" fill="{GREY}"/>')
    p.append(f'<path d="M236 70 L230 82 L238 82 L232 94" fill="none" stroke="{AMBER}" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>')
    # 5 calendar with drop
    p.append(f'<rect x="284" y="46" width="36" height="34" rx="5" fill="{WHITE}" stroke="{PINK}" stroke-width="3"/>')
    p.append(f'<rect x="284" y="46" width="36" height="9" rx="3" fill="{PINK}"/>')
    p.append(f'<path d="{drop_path(302, 72, 6)}" fill="{RED}"/>')
    for i, x in enumerate(xs):
        p.append(text(x, 124, str(i + 1), 14, GREY, '600'))
    return svg(w, h, '\n'.join(p))


def painkiller_limit():
    """A week: painkillers on at most 2 days."""
    w, h = 340, 150
    p = []
    for i in range(7):
        x = 14 + i * 46
        used = i in (1, 4)
        p.append(f'<rect x="{x}" y="24" width="40" height="56" rx="8" fill="{GREEN_LIGHT if used else WHITE}" stroke="{GREEN if used else GREY_LIGHT}" stroke-width="3"/>')
        p.append(f'<rect x="{x}" y="24" width="40" height="12" rx="6" fill="{GREEN if used else GREY_LIGHT}"/>')
        if used:
            # capsule
            p.append(f'<rect x="{x + 8}" y="50" width="24" height="12" rx="6" fill="{WHITE}" stroke="{GREEN}" stroke-width="2.5"/>')
            p.append(f'<path d="M{x + 20} 50 L{x + 20} 62" stroke="{GREEN}" stroke-width="2.5"/>')
            p.append(f'<rect x="{x + 20}" y="51.5" width="10.5" height="9" rx="4" fill="{GREEN}"/>')
    p.append(text(170, 124, '≤ 2 / 7', 22, GREEN))
    return svg(w, h, '\n'.join(p))


# ------------------------------------------------------------------ 1.2: heart, stroke, hepatitis

LIVER = '#B5523B'
LIVER_LIGHT = '#F1D5CC'
SCAR = '#D9B8A6'
VIRUS = '#B26A00'


def liver_path(cx, cy, s=1.0):
    """Liver seen from the front: a domed top, the big right lobe on the viewer's left,
    tapering to the left lobe; the underside slopes up to the tip."""
    return (f'M{cx - 70 * s} {cy - 14 * s} C{cx - 62 * s} {cy - 42 * s} {cx + 30 * s} {cy - 46 * s} {cx + 74 * s} {cy - 30 * s} '
            f'C{cx + 84 * s} {cy - 26 * s} {cx + 78 * s} {cy - 16 * s} {cx + 64 * s} {cy - 12 * s} '
            f'C{cx + 36 * s} {cy - 6 * s} {cx + 14 * s} {cy + 4 * s} {cx - 6 * s} {cy + 18 * s} '
            f'C{cx - 26 * s} {cy + 32 * s} {cx - 52 * s} {cy + 36 * s} {cx - 64 * s} {cy + 22 * s} '
            f'C{cx - 72 * s} {cy + 12 * s} {cx - 74 * s} {cy} {cx - 70 * s} {cy - 14 * s} Z')


def virus(cx, cy, r, fill=VIRUS):
    spikes = ''.join(
        f'<line x1="{cx + r * math.cos(a):.1f}" y1="{cy + r * math.sin(a):.1f}" '
        f'x2="{cx + (r + r * 0.45) * math.cos(a):.1f}" y2="{cy + (r + r * 0.45) * math.sin(a):.1f}" '
        f'stroke="{fill}" stroke-width="{max(2.0, r * 0.18):.1f}" stroke-linecap="round"/>'
        f'<circle cx="{cx + (r + r * 0.5) * math.cos(a):.1f}" cy="{cy + (r + r * 0.5) * math.sin(a):.1f}" r="{max(2.0, r * 0.14):.1f}" fill="{fill}"/>'
        for a in [i * math.pi / 4 for i in range(8)])
    return spikes + f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"/><circle cx="{cx - r * 0.3}" cy="{cy - r * 0.3}" r="{r * 0.25}" fill="{AMBER_LIGHT}"/>'


def shield(cx, cy, s=1.0, fill=GREEN):
    return (f'<path d="M{cx} {cy - 34 * s} L{cx + 28 * s} {cy - 24 * s} C{cx + 28 * s} {cy + 6 * s} {cx + 18 * s} {cy + 24 * s} {cx} {cy + 34 * s} '
            f'C{cx - 18 * s} {cy + 24 * s} {cx - 28 * s} {cy + 6 * s} {cx - 28 * s} {cy - 24 * s} Z" fill="{fill}"/>'
            + tick(cx, cy, 1.3 * s, WHITE))


def tablet(cx, cy, s=1.0, a=BLUE, b=WHITE):
    """Two-colour capsule, tilted."""
    return (f'<g transform="rotate(-35 {cx} {cy})">'
            f'<rect x="{cx - 26 * s}" y="{cy - 11 * s}" width="52" height="22" rx="11" fill="{b}" stroke="{a}" stroke-width="3" transform="scale(1)"/>'
            f'<path d="M{cx} {cy - 11 * s} L{cx - 15 * s} {cy - 11 * s} A11 11 0 0 0 {cx - 15 * s} {cy + 11 * s} L{cx} {cy + 11 * s} Z" fill="{a}"/>'
            f'</g>')


def head_profile(dx=0, dy=0, fill=GREEN_MID):
    """The migraine header's head, shifted."""
    return (f'<path transform="translate({dx} {dy})" d="M70 168 L72 132 C46 118 40 84 52 60 C66 32 100 20 128 30 C154 40 166 62 166 84 '
            f'L180 106 L166 110 L168 128 C168 140 158 144 146 142 L134 140 L134 168 Z" fill="{fill}"/>')


def heart_disease_header():
    """Heart with a coronary artery; plaque narrows it, and a pulse line."""
    body = [
        f'<path d="{heart_path(110, 96, 70)}" fill="{RED}"/>',
        f'<path d="M86 52 C96 80 92 112 112 148" fill="none" stroke="#8E1B1B" stroke-width="10" stroke-linecap="round"/>',
        f'<path d="M92 92 C102 104 116 104 132 118" fill="none" stroke="#8E1B1B" stroke-width="7" stroke-linecap="round"/>',
        f'<ellipse cx="94" cy="100" rx="9" ry="7" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="2"/>',
        f'<path d="M150 150 L176 150 L184 132 L194 168 L204 120 L212 150 L234 150" fill="none" stroke="{GREEN}" '
        f'stroke-width="5" stroke-linejoin="round" stroke-linecap="round"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def stroke_header():
    """Head with the brain; a red patch where blood flow stopped; a clock (time matters)."""
    body = [
        head_profile(-20, 0),
        f'<path d="M50 70 C46 46 72 30 96 36 C114 26 140 38 140 60 C150 72 140 92 124 92 C110 102 84 100 76 92 C58 94 46 84 50 70 Z" '
        f'fill="{PINK_LIGHT}"/>',
        f'<path d="M78 46 C88 56 80 66 92 74 M110 44 C104 56 116 64 108 80" fill="none" stroke="#E8A1BE" stroke-width="4" stroke-linecap="round"/>',
        f'<circle cx="118" cy="66" r="13" fill="{RED}"/>',
        f'<circle cx="196" cy="56" r="30" fill="{WHITE}" stroke="{RED}" stroke-width="6"/>',
        f'<path d="M196 56 L196 38 M196 56 L210 64" stroke="{INK}" stroke-width="5" stroke-linecap="round"/>',
    ]
    return svg(240, 180, '\n'.join(body))


def hepatitis_group_header():
    body = [
        f'<path d="{liver_path(110, 100, 1.25)}" fill="{LIVER}"/>',
        f'<path d="M70 70 C90 62 116 64 132 72" fill="none" stroke="{LIVER_LIGHT}" stroke-width="5" stroke-linecap="round"/>',
        virus(190, 50, 18),
    ]
    return svg(240, 180, '\n'.join(body))


def hepatitis_b_header():
    """Liver protected by a shield (the vaccine)."""
    body = [
        f'<path d="{liver_path(96, 104, 1.1)}" fill="{LIVER}"/>',
        virus(60, 40, 11),
        shield(186, 92, 1.4),
    ]
    return svg(240, 180, '\n'.join(body))


def hepatitis_c_header():
    """Liver, a tablet and a tick: hepatitis C can be cured."""
    body = [
        f'<path d="{liver_path(96, 104, 1.1)}" fill="{LIVER}"/>',
        tablet(178, 62),
        f'<circle cx="190" cy="134" r="26" fill="{OK}"/>',
        tick(190, 134, 1.3, WHITE),
    ]
    return svg(240, 180, '\n'.join(body))


def icon_jaw(x, y):
    return (f'<path d="M{x - 14} {y - 10} C{x - 14} {y + 8} {x - 6} {y + 14} {x} {y + 14} C{x + 6} {y + 14} {x + 14} {y + 8} {x + 14} {y - 10}" '
            f'fill="none" stroke="{RED}" stroke-width="4" stroke-linecap="round"/>')


def icon_arm(x, y):
    return (f'<path d="M{x - 12} {y - 14} L{x - 4} {y - 14} L{x + 12} {y + 12} L{x + 4} {y + 16} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5" stroke-linejoin="round"/>')


def icon_stomach(x, y):
    return (f'<path d="M{x - 4} {y - 14} C{x - 4} {y - 4} {x - 16} {y - 2} {x - 14} {y + 8} C{x - 12} {y + 16} {x + 10} {y + 16} {x + 14} {y + 4} '
            f'C{x + 16} {y - 4} {x + 6} {y - 6} {x + 4} {y - 14} Z" fill="{RED_LIGHT}" stroke="{RED}" stroke-width="2.5"/>')


def icon_sweat(x, y):
    return (f'<path d="{drop_path(x - 7, y + 6, 6)}" fill="{BLUE}"/><path d="{drop_path(x + 8, y + 10, 5)}" fill="{BLUE}"/>')


def heart_attack_signs():
    """1 chest pain, 2 arm, 3 jaw/neck, 4 stomach, 5 breathless, 6 cold sweat."""
    w, h = 340, 290
    parts = [body_outline(170, 18)]
    parts += organ_marks([
        (160, 96, 60, 100, 1, icon_heart),
        (126, 140, 60, 180, 2, icon_arm),
        (170, 54, 60, 30, 3, icon_jaw),
        (176, 138, 280, 160, 4, icon_stomach),
        (184, 100, 280, 90, 5, icon_lungs),
        (186, 28, 280, 26, 6, icon_sweat),
    ])
    for n, (x, y) in enumerate([(60, 136), (60, 216), (60, 66), (280, 196), (280, 126), (280, 62)], 1):
        parts.append(text(x, y, str(n), 13, GREY, '600'))
    return svg(w, h, '\n'.join(parts))


def artery_block():
    """1 healthy artery, 2 plaque narrows it, 3 a clot blocks it and the heart muscle beyond is starved."""
    w, h = 340, 170
    p = []
    for i, y in enumerate([34, 84, 134]):
        p.append(f'<rect x="20" y="{y - 18}" width="210" height="36" rx="6" fill="{RED_LIGHT}"/>')
        p.append(f'<rect x="20" y="{y - 22}" width="210" height="6" fill="{RED}"/><rect x="20" y="{y + 16}" width="210" height="6" fill="{RED}"/>')
        p.append(text(8, y + 5, str(i + 1), 14, GREY, '600'))
        if i >= 1:
            p.append(f'<path d="M80 {y - 16} C100 {y - 2} 140 {y - 2} 160 {y - 16} Z" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="2"/>')
            p.append(f'<path d="M80 {y + 16} C100 {y + 2} 140 {y + 2} 160 {y + 16} Z" fill="{FAT}" stroke="{FAT_DARK}" stroke-width="2"/>')
        if i == 2:
            p.append(f'<ellipse cx="120" cy="{y}" rx="16" ry="9" fill="#8E1B1B"/>')
        dots = [40, 64, 186, 210] if i < 2 else [40, 64]
        for x in dots:
            p.append(f'<circle cx="{x}" cy="{y}" r="5" fill="{RED}"/>')
    # heart muscle after the artery: healthy (rows 1-2) vs starved (row 3)
    p.append(f'<path d="{heart_path(290, 66, 34)}" fill="{RED}"/>')
    p.append(f'<path d="{heart_path(290, 138, 26)}" fill="{RED}"/>')
    p.append(f'<path d="M290 130 C302 130 308 142 300 152 L290 160 Z" fill="{GREY}"/>')
    p.append(f'<path d="M236 134 L258 134" stroke="{GREY}" stroke-width="4" stroke-linecap="round"/>')
    p.append(f'<path d="M236 59 L254 59" stroke="{GREY}" stroke-width="4" stroke-linecap="round"/>')
    return svg(w, h, '\n'.join(p))


def face(cx, cy, droop=False):
    """A face; with droop, one side of the mouth and one eyelid sag (stroke)."""
    if droop:
        mouth = f'M{cx - 14} {cy + 10} Q{cx - 2} {cy + 18} {cx + 6} {cy + 18} L{cx + 14} {cy + 24}'
        eye_r = (f'<circle cx="{cx + 10}" cy="{cy - 4}" r="3.5" fill="{INK}"/>'
                 f'<path d="M{cx + 4} {cy - 9} L{cx + 16} {cy - 5}" stroke="{SKIN_DARK}" stroke-width="3" stroke-linecap="round"/>')
    else:
        mouth = f'M{cx - 14} {cy + 12} Q{cx} {cy + 22} {cx + 14} {cy + 12}'
        eye_r = f'<circle cx="{cx + 10}" cy="{cy - 6}" r="3.5" fill="{INK}"/>'
    return (f'<circle cx="{cx}" cy="{cy}" r="30" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="3"/>'
            f'<circle cx="{cx - 10}" cy="{cy - 6}" r="3.5" fill="{INK}"/>' + eye_r +
            f'<path d="{mouth}" fill="none" stroke="{INK}" stroke-width="3.5" stroke-linecap="round" stroke-linejoin="round"/>')


def stroke_fast():
    """F face drooping, A arm drifting down, S speech slurred, T time to call 1122."""
    w, h = 340, 150
    p = []
    xs = [44, 128, 212, 296]
    for x in xs:
        p.append(f'<rect x="{x - 40}" y="12" width="80" height="100" rx="14" fill="{WHITE}" stroke="{RED}" stroke-width="3"/>')
    p.append(face(44, 60, droop=True))
    # arms: person with one arm up and one dropping
    p.append(f'<circle cx="128" cy="38" r="10" fill="{GREEN_MID}"/>')
    p.append(f'<rect x="118" y="50" width="20" height="44" rx="8" fill="{GREEN_MID}"/>')
    p.append(f'<path d="M118 56 L94 54" stroke="{GREEN_MID}" stroke-width="8" stroke-linecap="round"/>')
    p.append(f'<path d="M138 56 L152 76" stroke="{GREEN_MID}" stroke-width="8" stroke-linecap="round"/>')
    p.append(f'<path d="M158 60 L158 84 M152 78 L158 85 L164 78" fill="none" stroke="{RED}" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/>')
    # speech bubble with a scribble
    p.append(f'<path d="M184 34 L240 34 C246 34 248 38 248 42 L248 70 C248 74 246 78 240 78 L206 78 L194 92 L196 78 L184 78 C180 78 176 74 176 70 L176 42 C176 38 180 34 184 34 Z" '
             f'fill="{BLUE_LIGHT}" stroke="{BLUE}" stroke-width="3"/>')
    p.append(f'<path d="M186 56 C192 44 196 68 202 56 C208 44 212 68 218 56 C224 44 228 68 236 56" fill="none" stroke="{BLUE}" stroke-width="3" stroke-linecap="round"/>')
    # clock and phone
    p.append(f'<circle cx="280" cy="46" r="18" fill="{WHITE}" stroke="{RED}" stroke-width="4"/>')
    p.append(f'<path d="M280 46 L280 34 M280 46 L289 51" stroke="{INK}" stroke-width="3" stroke-linecap="round"/>')
    p.append(f'<rect x="296" y="52" width="26" height="44" rx="5" fill="{INK}"/><rect x="300" y="58" width="18" height="28" rx="2" fill="{GREEN_LIGHT}"/>')
    p.append(text(282, 100, '1122', 14, RED))
    for i, x in enumerate(xs):
        p.append(text(x, 136, 'FAST'[i], 18, RED))
    return svg(w, h, '\n'.join(p))


def stroke_types():
    """1 a clot blocks a blood vessel in the brain; 2 a blood vessel bursts and bleeds."""
    w, h = 340, 150
    p = []
    for i, cx in enumerate([90, 250]):
        p.append(f'<path d="M{cx - 64} {74} C{cx - 70} {40} {cx - 30} {16} {cx} {26} C{cx + 30} {14} {cx + 70} {40} {cx + 64} {74} '
                 f'C{cx + 64} {104} {cx + 30} {120} {cx} {112} C{cx - 30} {120} {cx - 64} {104} {cx - 64} {74} Z" fill="{PINK_LIGHT}" stroke="#E8A1BE" stroke-width="3"/>')
        p.append(f'<path d="M{cx - 50} 96 C{cx - 24} 86 {cx - 10} 70 {cx + 6} 50 M{cx + 6} 50 L{cx + 30} 40 M{cx + 6} 50 L{cx + 20} 74" fill="none" stroke="{RED}" stroke-width="6" stroke-linecap="round"/>')
        p.append(text(cx, 140, str(i + 1), 14, GREY, '600'))
    p.append(f'<ellipse cx="90" cy="56" rx="9" ry="6" fill="#8E1B1B"/>')
    p.append(f'<path d="M96 50 L120 40 M96 50 L110 74" fill="none" stroke="{GREY}" stroke-width="6" stroke-linecap="round"/>')
    p.append(f'<path d="M252 48 C268 34 290 46 280 62 C292 74 268 86 258 72 C242 80 236 58 252 48 Z" fill="{RED}"/>')
    return svg(w, h, '\n'.join(p))


def syringe(cx, cy, s=1.0):
    return (f'<g transform="rotate(-30 {cx} {cy})">'
            f'<rect x="{cx - 22 * s}" y="{cy - 7 * s}" width="{36 * s}" height="{14 * s}" rx="3" fill="{WHITE}" stroke="{INK}" stroke-width="2.5"/>'
            f'<rect x="{cx - 18 * s}" y="{cy - 4 * s}" width="{18 * s}" height="{8 * s}" fill="{RED}"/>'
            f'<path d="M{cx + 14 * s} {cy} L{cx + 32 * s} {cy}" stroke="{INK}" stroke-width="2.5"/>'
            f'<path d="M{cx - 22 * s} {cy} L{cx - 32 * s} {cy} M{cx - 32 * s} {cy - 8 * s} L{cx - 32 * s} {cy + 8 * s}" stroke="{INK}" stroke-width="3"/>'
            f'</g>')


def razor(cx, cy):
    return (f'<rect x="{cx - 4}" y="{cy - 4}" width="8" height="30" rx="3" fill="{GREY}"/>'
            f'<rect x="{cx - 18}" y="{cy - 16}" width="36" height="14" rx="3" fill="{GREY_LIGHT}" stroke="{INK}" stroke-width="2.5"/>'
            f'<path d="M{cx - 16} {cy - 16} L{cx + 16} {cy - 16}" stroke="{RED}" stroke-width="2"/>')


def blood_bag(cx, cy):
    return (f'<rect x="{cx - 16}" y="{cy - 20}" width="32" height="36" rx="8" fill="{RED}"/>'
            f'<path d="M{cx} {cy + 16} L{cx} {cy + 26}" stroke="{RED}" stroke-width="3"/>'
            f'<rect x="{cx - 10}" y="{cy - 14}" width="20" height="8" rx="2" fill="{WHITE}"/>')


def mother_baby(cx, cy):
    return (f'<circle cx="{cx - 8}" cy="{cy - 18}" r="9" fill="{GREEN_MID}"/>'
            f'<path d="M{cx - 22} {cy + 22} C{cx - 22} {cy - 4} {cx - 16} {cy - 8} {cx - 8} {cy - 8} C{cx + 2} {cy - 8} {cx + 6} {cy} {cx + 6} {cy + 22} Z" fill="{GREEN_MID}"/>'
            f'<ellipse cx="{cx + 10}" cy="{cy + 4}" rx="10" ry="7" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2"/>')


def hug(cx, cy):
    return (f'<circle cx="{cx - 10}" cy="{cy - 16}" r="8" fill="{GREEN_MID}"/><circle cx="{cx + 10}" cy="{cy - 16}" r="8" fill="{BLUE}"/>'
            f'<rect x="{cx - 20}" y="{cy - 6}" width="18" height="30" rx="7" fill="{GREEN_MID}"/>'
            f'<rect x="{cx + 2}" y="{cy - 6}" width="18" height="30" rx="7" fill="{BLUE}"/>'
            f'<path d="M{cx - 14} {cy + 2} C{cx - 4} {cy + 8} {cx + 4} {cy + 8} {cx + 14} {cy + 2}" fill="none" stroke="{GREEN_MID}" stroke-width="6" stroke-linecap="round"/>')


def plate(cx, cy):
    return (f'<ellipse cx="{cx}" cy="{cy + 4}" rx="24" ry="12" fill="{WHITE}" stroke="{GREY}" stroke-width="3"/>'
            f'<ellipse cx="{cx}" cy="{cy}" rx="12" ry="5" fill="{FAT}"/>'
            f'<path d="M{cx + 18} {cy - 14} L{cx + 12} {cy + 2}" stroke="{GREY}" stroke-width="3" stroke-linecap="round"/>')


def handshake(cx, cy):
    return (f'<path d="M{cx - 30} {cy + 4} L{cx - 8} {cy - 6} L{cx + 6} {cy + 4} L{cx - 6} {cy + 12} Z" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2.5" stroke-linejoin="round"/>'
            f'<path d="M{cx + 30} {cy + 4} L{cx + 8} {cy - 6} L{cx - 6} {cy + 4} L{cx + 6} {cy + 12} Z" fill="#D8A97E" stroke="{SKIN_DARK}" stroke-width="2.5" stroke-linejoin="round"/>')


def cough(cx, cy):
    return (f'<circle cx="{cx - 8}" cy="{cy}" r="16" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2.5"/>'
            f'<ellipse cx="{cx + 6}" cy="{cy + 4}" rx="4" ry="5" fill="{INK}"/>'
            + ''.join(f'<path d="M{cx + 14 + i * 6} {cy - 6 + i * 2} C{cx + 18 + i * 6} {cy - 2 + i * 2} {cx + 18 + i * 6} {cy + 6 + i * 2} {cx + 14 + i * 6} {cy + 10 + i * 2}" fill="none" stroke="{GREY}" stroke-width="2.5" stroke-linecap="round"/>'
                      for i in range(3)))


def hepatitis_spread():
    """Top: 1 shared or reused needles, 2 shared razors, 3 unscreened blood, 4 mother to baby at birth.
    Bottom (does not spread): 5 hugging, 6 sharing food, 7 shaking hands, 8 coughing."""
    w, h = 340, 250
    p = []
    xs = [44, 128, 212, 296]
    for row, (y, colour, light) in enumerate([(62, RED, RED_LIGHT), (180, OK, GREEN_LIGHT)]):
        for x in xs:
            p.append(f'<rect x="{x - 38}" y="{y - 44}" width="76" height="88" rx="14" fill="{light}" stroke="{colour}" stroke-width="3"/>')
    p += [syringe(44, 54), razor(128, 54), blood_bag(212, 52), mother_baby(296, 54)]
    p += [hug(44, 174), plate(128, 172), handshake(212, 172), cough(296, 172)]
    for i, x in enumerate(xs):
        p.append(text(x, 100, str(i + 1), 13, RED, '600'))
        p.append(text(x, 218, str(i + 5), 13, OK, '600'))
        p.append(cross(x + 26, 28, 0.6))
        p.append(tick(x + 26, 146, 0.6))
    return svg(w, h, '\n'.join(p))


def liver_damage():
    """1 healthy liver, 2 scarred (cirrhosis), 3 liver cancer."""
    w, h = 340, 140
    p = []
    for i, cx in enumerate([56, 170, 284]):
        fill = LIVER if i == 0 else SCAR
        p.append(f'<path d="{liver_path(cx, 64, 0.6)}" fill="{fill}"/>')
        p.append(text(cx, 128, str(i + 1), 14, GREY, '600'))
    for dx, dy in [(-20, -8), (0, 4), (14, -12), (-6, 18), (24, -2)]:
        for cx in (170, 284):
            p.append(f'<circle cx="{cx + dx}" cy="{64 + dy}" r="5" fill="#B88A74"/>')
    p.append(f'<circle cx="276" cy="58" r="13" fill="#5D2A1E"/>')
    for x in (110, 224):
        p.append(f'<path d="M{x - 10} 66 L{x + 8} 66" stroke="{GREY}" stroke-width="4" stroke-linecap="round"/>')
        p.append(f'<path d="M{x + 4} 59 L{x + 12} 66 L{x + 4} 73 Z" fill="{GREY}"/>')
    return svg(w, h, '\n'.join(p))


def hepb_vaccine():
    """A newborn, the shield of the vaccine, and a liver kept healthy."""
    w, h = 340, 150
    p = [
        f'<ellipse cx="66" cy="84" rx="44" ry="26" fill="{BLUE_LIGHT}" stroke="{BLUE}" stroke-width="3"/>',
        f'<circle cx="36" cy="78" r="18" fill="{SKIN}" stroke="{SKIN_DARK}" stroke-width="2.5"/>',
        f'<path d="M30 80 Q36 86 42 80" fill="none" stroke="{INK}" stroke-width="2.5" stroke-linecap="round"/>',
        syringe(128, 60, 0.9),
        shield(190, 76, 1.3),
        f'<path d="M226 76 L246 76" stroke="{GREY}" stroke-width="4" stroke-linecap="round"/>',
        f'<path d="M242 69 L250 76 L242 83 Z" fill="{GREY}"/>',
        f'<path d="{liver_path(296, 80, 0.6)}" fill="{LIVER}"/>',
    ]
    return svg(w, h, '\n'.join(p))


def hepc_cure():
    """1 a blood test, 2 a course of tablets, 3 cured."""
    w, h = 340, 150
    p = [
        f'<rect x="40" y="26" width="24" height="74" rx="10" fill="{WHITE}" stroke="{INK}" stroke-width="3"/>',
        f'<rect x="43" y="62" width="18" height="35" rx="8" fill="{RED}"/>',
        f'<rect x="36" y="20" width="32" height="10" rx="3" fill="{BLUE}"/>',
        f'<rect x="128" y="30" width="80" height="66" rx="8" fill="{WHITE}" stroke="{GREY}" stroke-width="3"/>',
    ]
    for r in range(3):
        for c in range(4):
            p.append(f'<circle cx="{146 + c * 15}" cy="{48 + r * 17}" r="5.5" fill="{BLUE}"/>')
    p += [
        f'<path d="{liver_path(284, 64, 0.6)}" fill="{LIVER}"/>',
        f'<circle cx="300" cy="94" r="18" fill="{OK}"/>', tick(300, 94, 0.9, WHITE),
    ]
    for x in (94, 236):
        p.append(f'<path d="M{x - 12} 64 L{x + 8} 64" stroke="{GREY}" stroke-width="4" stroke-linecap="round"/>')
        p.append(f'<path d="M{x + 4} 57 L{x + 12} 64 L{x + 4} 71 Z" fill="{GREY}"/>')
    for i, x in enumerate([52, 168, 290]):
        p.append(text(x, 132, str(i + 1), 14, GREY, '600'))
    return svg(w, h, '\n'.join(p))


def hepatitis_safe():
    """1 a new, sealed syringe every time, 2 your own razor, 3 screened blood, 4 test and treat."""
    w, h = 340, 150
    p = []
    xs = [44, 128, 212, 296]
    for x in xs:
        p.append(f'<rect x="{x - 38}" y="12" width="76" height="92" rx="14" fill="{GREEN_LIGHT}" stroke="{OK}" stroke-width="3"/>')
    p.append(f'<rect x="18" y="32" width="52" height="40" rx="6" fill="{WHITE}" stroke="{GREY}" stroke-width="2.5" stroke-dasharray="5 4"/>')
    p.append(syringe(44, 52, 0.7))
    p.append(razor(128, 50))
    p.append(f'<circle cx="146" cy="78" r="9" fill="{GREEN_MID}"/>')
    p.append(blood_bag(212, 50))
    p.append(tick(222, 84, 0.7))
    p.append(f'<rect x="274" y="26" width="16" height="46" rx="7" fill="{WHITE}" stroke="{INK}" stroke-width="2.5"/>')
    p.append(f'<rect x="276" y="50" width="12" height="20" rx="5" fill="{RED}"/>')
    p.append(f'<circle cx="310" cy="56" r="8" fill="{BLUE}"/><circle cx="302" cy="80" r="8" fill="{BLUE}"/><circle cx="318" cy="80" r="8" fill="{BLUE}"/>')
    for i, x in enumerate(xs):
        p.append(text(x, 128, str(i + 1), 14, OK, '600'))
    return svg(w, h, '\n'.join(p))


GRAPHICS = {
    'heart_disease_header.svg': heart_disease_header,
    'stroke_header.svg': stroke_header,
    'hepatitis_group_header.svg': hepatitis_group_header,
    'hepatitis_b_header.svg': hepatitis_b_header,
    'hepatitis_c_header.svg': hepatitis_c_header,
    'heart_attack_signs.svg': heart_attack_signs,
    'artery_block.svg': artery_block,
    'stroke_fast.svg': stroke_fast,
    'stroke_types.svg': stroke_types,
    'hepatitis_spread.svg': hepatitis_spread,
    'liver_damage.svg': liver_damage,
    'hepb_vaccine.svg': hepb_vaccine,
    'hepc_cure.svg': hepc_cure,
    'hepatitis_safe.svg': hepatitis_safe,
    'breast_cancer_header.svg': breast_cancer_header,
    'high_cholesterol_header.svg': high_cholesterol_header,
    'migraine_header.svg': migraine_header,
    'breast_signs.svg': breast_signs,
    'breast_spread.svg': breast_spread,
    'mammogram_timeline.svg': mammogram_timeline,
    'cholesterol_risks.svg': cholesterol_risks,
    'fats_swap.svg': fats_swap,
    'migraine_phases.svg': migraine_phases,
    'migraine_triggers.svg': migraine_triggers,
    'painkiller_limit.svg': painkiller_limit,
    'hypertension_header.svg': hypertension_header,
    'diabetes_group_header.svg': diabetes_group_header,
    'prediabetes_header.svg': prediabetes_header,
    'type2_diabetes_header.svg': type2_header,
    'gestational_diabetes_header.svg': gestational_header,
    'obesity_header.svg': obesity_header,
    'bp_categories.svg': bp_categories,
    'bp_organs.svg': bp_organs,
    'bp_measure.svg': bp_measure,
    'salt_limit.svg': salt_limit,
    'glucose_fasting.svg': glucose_fasting,
    'glucose_after_meal.svg': glucose_after_meal,
    'diabetes_organs.svg': diabetes_organs,
    'healthy_plate.svg': healthy_plate,
    'activity_week.svg': activity_week,
    'bmi_scale.svg': bmi_scale,
    'waist_measure.svg': waist_measure,
    'insulin_key.svg': insulin_key,
    'gdm_timeline.svg': gdm_timeline,
    'foot_check.svg': foot_check,
}

if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for name, fn in GRAPHICS.items():
        with open(os.path.join(OUT, name), 'w') as f:
            f.write(fn())
    print(f'{len(GRAPHICS)} graphics written to {OUT}')
