// Run with: dart tool/generate_icon.dart
// Generates assets/images/app_icon.png and app_icon_foreground.png
// matching the dark glassmorphism theme.

import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;

void main() {
  const int size = 1024;

  // ── Full icon (used by iOS and as fallback) ───────────────────────────────
  final fullIcon = _buildFullIcon(size);
  final fullFile = File('assets/images/app_icon.png');
  fullFile.writeAsBytesSync(img.encodePng(fullIcon));
  print('✓ Wrote ${fullFile.path}');

  // ── Foreground layer (Android adaptive — safe zone = center 66%) ──────────
  final foreground = _buildForeground(size);
  final fgFile = File('assets/images/app_icon_foreground.png');
  fgFile.writeAsBytesSync(img.encodePng(foreground));
  print('✓ Wrote ${fgFile.path}');

  print('Done! Run: dart run flutter_launcher_icons');
}

// ── Helpers ──────────────────────────────────────────────────────────────────

img.Image _buildFullIcon(int size) {
  final image = img.Image(width: size, height: size);

  // Background gradient: #0F0C29 → #302B63 → #24243E (top-left → bottom-right)
  _drawGradient(
    image,
    const _Col(0x0F, 0x0C, 0x29),
    const _Col(0x30, 0x2B, 0x63),
    const _Col(0x24, 0x24, 0x3E),
  );

  // Decorative blobs (semi-transparent radial glows)
  _drawBlob(image, size * 0.15, size * 0.20, size * 0.38,
      const _Col(0x6C, 0x63, 0xFF), 0.35); // purple top-left
  _drawBlob(image, size * 0.82, size * 0.78, size * 0.32,
      const _Col(0x00, 0xD4, 0xAA), 0.25); // teal bottom-right
  _drawBlob(image, size * 0.75, size * 0.22, size * 0.25,
      const _Col(0xFF, 0x6B, 0x9D), 0.20); // pink top-right

  // Glass card background (centre square, rounded)
  _drawRoundedRect(
    image,
    x: (size * 0.18).round(),
    y: (size * 0.18).round(),
    w: (size * 0.64).round(),
    h: (size * 0.64).round(),
    radius: (size * 0.12).round(),
    color: img.ColorRgba8(255, 255, 255, 28), // ~11% white
  );

  // ₱ symbol centred
  _drawPesoSymbol(image, size);

  return image;
}

img.Image _buildForeground(int size) {
  // Transparent background — only draw the ₱ symbol (adaptive foreground)
  final image = img.Image(width: size, height: size);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));
  _drawPesoSymbol(image, size);
  return image;
}

// Trilinear gradient fill
void _drawGradient(
    img.Image image, _Col topLeft, _Col midCenter, _Col bottomRight) {
  final w = image.width;
  final h = image.height;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final tx = x / w;
      final ty = y / h;
      // Blend: corner → mid → corner
      final t = (tx + ty) / 2.0;
      final t1 = (t < 0.5) ? t * 2 : 0.0;
      final t2 = (t >= 0.5) ? (t - 0.5) * 2 : 0.0;
      final r = (topLeft.r * (1 - t1) + midCenter.r * t1) * (1 - t2) +
          bottomRight.r * t2;
      final g = (topLeft.g * (1 - t1) + midCenter.g * t1) * (1 - t2) +
          bottomRight.g * t2;
      final b = (topLeft.b * (1 - t1) + midCenter.b * t1) * (1 - t2) +
          bottomRight.b * t2;
      image.setPixel(x, y, img.ColorRgba8(r.round(), g.round(), b.round(), 255));
    }
  }
}

// Radial glow blob
void _drawBlob(
    img.Image image, double cx, double cy, double radius, _Col color, double maxAlpha) {
  final x0 = (cx - radius).floor().clamp(0, image.width - 1);
  final x1 = (cx + radius).ceil().clamp(0, image.width - 1);
  final y0 = (cy - radius).floor().clamp(0, image.height - 1);
  final y1 = (cy + radius).ceil().clamp(0, image.height - 1);

  for (int y = y0; y <= y1; y++) {
    for (int x = x0; x <= x1; x++) {
      final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
      if (dist > radius) continue;
      final t = 1.0 - (dist / radius);
      final alpha = (maxAlpha * t * t * 255).round().clamp(0, 255);
      final existing = image.getPixel(x, y);
      final blended = img.ColorRgba8(
        _blend(existing.r.toInt(), color.r, alpha),
        _blend(existing.g.toInt(), color.g, alpha),
        _blend(existing.b.toInt(), color.b, alpha),
        255,
      );
      image.setPixel(x, y, blended);
    }
  }
}

int _blend(int bg, int fg, int alpha) =>
    ((bg * (255 - alpha) + fg * alpha) / 255).round().clamp(0, 255);

// Filled rounded rectangle
void _drawRoundedRect(img.Image image,
    {required int x,
    required int y,
    required int w,
    required int h,
    required int radius,
    required img.Color color}) {
  for (int py = y; py < y + h; py++) {
    for (int px = x; px < x + w; px++) {
      if (!_insideRoundedRect(px, py, x, y, w, h, radius)) continue;
      if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;
      final existing = image.getPixel(px, py);
      final a = color.a.toInt();
      image.setPixel(
        px,
        py,
        img.ColorRgba8(
          _blend(existing.r.toInt(), color.r.toInt(), a),
          _blend(existing.g.toInt(), color.g.toInt(), a),
          _blend(existing.b.toInt(), color.b.toInt(), a),
          255,
        ),
      );
    }
  }
}

bool _insideRoundedRect(int px, int py, int x, int y, int w, int h, int r) {
  if (px >= x + r && px < x + w - r) return true;
  if (py >= y + r && py < y + h - r) return true;
  // corners
  final corners = [
    (x + r, y + r),
    (x + w - r - 1, y + r),
    (x + r, y + h - r - 1),
    (x + w - r - 1, y + h - r - 1),
  ];
  for (final c in corners) {
    final dx = px - c.$1;
    final dy = py - c.$2;
    if (dx * dx + dy * dy <= r * r) return true;
  }
  return false;
}

// Draw a thick ₱ symbol using filled circles and rectangles
void _drawPesoSymbol(img.Image image, int size) {
  final cx = size / 2;
  final cy = size / 2;

  // Scale: symbol fits within ~46% of icon size
  final scale = size * 0.46;
  final stroke = (size * 0.065).round(); // stroke thickness

  // ── P letter body ──
  // Vertical bar
  _fillRect(
    image,
    left: (cx - scale * 0.22).round(),
    top: (cy - scale * 0.46).round(),
    right: (cx - scale * 0.22 + stroke).round(),
    bottom: (cy + scale * 0.46).round(),
    color: img.ColorRgba8(255, 255, 255, 255),
  );

  // Rounded bump of P (right side arc)
  final arcCx = cx - scale * 0.22 + stroke / 2;
  final arcCy = cy - scale * 0.10;
  final arcOuter = scale * 0.33;
  final arcInner = arcOuter - stroke;
  _drawArc(image, arcCx, arcCy, arcOuter, arcInner,
      -math.pi / 2, math.pi / 2, img.ColorRgba8(255, 255, 255, 255));

  // ── Two horizontal bars (the ₱ accent lines) ──
  final barY1 = (cy - scale * 0.06).round();
  final barY2 = (cy + scale * 0.13).round();
  final barLeft = (cx - scale * 0.38).round();
  final barRight = (cx + scale * 0.24).round();
  final barH = (stroke * 0.75).round().clamp(4, 999);

  _fillRect(image,
      left: barLeft, top: barY1, right: barRight, bottom: barY1 + barH,
      color: img.ColorRgba8(255, 255, 255, 230));
  _fillRect(image,
      left: barLeft, top: barY2, right: barRight, bottom: barY2 + barH,
      color: img.ColorRgba8(255, 255, 255, 230));
}

void _fillRect(img.Image image,
    {required int left,
    required int top,
    required int right,
    required int bottom,
    required img.Color color}) {
  for (int y = top; y <= bottom; y++) {
    for (int x = left; x <= right; x++) {
      if (x < 0 || y < 0 || x >= image.width || y >= image.height) continue;
      image.setPixel(x, y, color);
    }
  }
}

void _drawArc(img.Image image, double cx, double cy, double outerR,
    double innerR, double startAngle, double endAngle, img.Color color) {
  final steps = (outerR * (endAngle - startAngle) * 4).ceil();
  for (int i = 0; i <= steps; i++) {
    final angle = startAngle + (endAngle - startAngle) * i / steps;
    for (double r = innerR; r <= outerR; r += 0.5) {
      final px = (cx + math.cos(angle) * r).round();
      final py = (cy + math.sin(angle) * r).round();
      if (px < 0 || py < 0 || px >= image.width || py >= image.height) {
        continue;
      }
      image.setPixel(px, py, color);
    }
  }
}

class _Col {
  final int r, g, b;
  const _Col(this.r, this.g, this.b);
}
