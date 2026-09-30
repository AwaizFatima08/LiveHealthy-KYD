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


GRAPHICS = {
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
