"""Tokyo Night mountains wallpaper for Ghostty's background-image. Re-run to regenerate."""
import math, random, sys
from PIL import Image, ImageChops, ImageDraw, ImageFilter

W, H = 3024, 1964
random.seed(7)
out = sys.argv[1] if len(sys.argv) > 1 else "night.png"

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

# sky gradient
top, mid, low = (13, 14, 26), (30, 27, 58), (74, 52, 100)
img = Image.new("RGB", (W, H))
d = ImageDraw.Draw(img)
for y in range(H):
    t = y / H
    c = lerp(top, mid, t / 0.6) if t < 0.6 else lerp(mid, low, (t - 0.6) / 0.4)
    d.line([(0, y), (W, y)], fill=c)

# moon glow
glow = Image.new("RGB", (W, H), (0, 0, 0))
gd = ImageDraw.Draw(glow)
mx, my = int(W * 0.72), int(H * 0.30)
for r in range(520, 0, -8):
    a = (1 - r / 520) ** 2.2
    gd.ellipse([mx - r, my - r, mx + r, my + r], fill=lerp((0, 0, 0), (122, 110, 200), a))
glow = glow.filter(ImageFilter.GaussianBlur(40))
img = ImageChops.add(img, glow)
d = ImageDraw.Draw(img)
d.ellipse([mx - 90, my - 90, mx + 90, my + 90], fill=(230, 222, 255))

# stars
for _ in range(500):
    x, y = random.randrange(W), random.randrange(int(H * 0.65))
    b = random.randint(90, 230)
    s = random.choice([1, 1, 1, 2, 2, 3])
    d.ellipse([x, y, x + s, y + s], fill=(b, b, min(255, b + 25)))

# mountain layers, far (light) to near (dark), jagged ridges via midpoint displacement
def ridge(n_pow, rough, amp):
    n = 2 ** n_pow
    ys = [0.0] * (n + 1)
    ys[0], ys[n] = random.uniform(-1, 1), random.uniform(-1, 1)
    step, scale = n, 1.0
    while step > 1:
        half = step // 2
        for i in range(half, n, step):
            ys[i] = (ys[i - half] + ys[i + half]) / 2 + random.uniform(-1, 1) * scale
        step, scale = half, scale * rough
    return [(W * i / n, -y * amp) for i, y in enumerate(ys)]

layers = [
    (0.60, 260, 0.55, (62, 52, 108)),
    (0.68, 240, 0.52, (44, 39, 82)),
    (0.77, 220, 0.50, (28, 28, 56)),
    (0.88, 200, 0.48, (15, 16, 30)),
]
for base, amp, rough, col in layers:
    pts = [(x, H * base + y) for x, y in ridge(9, rough, amp)]
    d.polygon(pts + [(W, H), (0, H)], fill=col)

img.save(out, optimize=True)
print("wrote", out)
