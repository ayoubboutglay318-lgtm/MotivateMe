import 'dart:io';
import 'dart:math';
import 'package:image/image.dart';

void main() {
  const size = 1024;
  // RGBA so corners can be transparent
  final img = Image(width: size, height: size, numChannels: 4);

  // Start fully transparent
  fill(img, color: ColorRgba8(0, 0, 0, 0));

  // Fill rounded rectangle with dark background
  const radius = 200;
  final bgColor = ColorRgba8(28, 28, 30, 255);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      if (_inRoundRect(x, y, size, radius)) {
        img.setPixel(x, y, bgColor);
      }
    }
  }

  // 3 lines, scale=5, lineH=280, spacing=210 → block center=512
  _drawLine(img, "Don't", yCenter: 302, color: ColorRgba8(255, 255, 255, 255), scale: 5);
  _drawLine(img, 'give',  yCenter: 512, color: ColorRgba8(255, 255, 255, 255), scale: 5);
  _drawLine(img, 'up',    yCenter: 722, color: ColorRgba8(255, 196, 0, 255),   scale: 5);

  File('assets/icon/app_icon.png').writeAsBytesSync(encodePng(img));
  print('Done → assets/icon/app_icon.png');
}

void _drawLine(Image dst, String text, {required int yCenter, required Color color, required int scale}) {
  final tmp = Image(width: text.length * 30 + 20, height: 56, numChannels: 4);
  fill(tmp, color: ColorRgba8(0, 0, 0, 0));
  drawString(tmp, text, font: arial48, x: 4, y: 4, color: color);

  final scaled = copyResize(tmp,
    width: tmp.width * scale,
    height: tmp.height * scale,
    interpolation: Interpolation.nearest,
  );

  final dstX = (dst.width - scaled.width) ~/ 2;
  final dstY = yCenter - scaled.height ~/ 2;
  compositeImage(dst, scaled, dstX: dstX, dstY: dstY, blend: BlendMode.alpha);
}

bool _inRoundRect(int px, int py, int size, int r) {
  if (px < 0 || px >= size || py < 0 || py >= size) return false;
  if (px < r && py < r) return _dist(px, py, r, r) <= r;
  if (px >= size - r && py < r) return _dist(px, py, size - r, r) <= r;
  if (px < r && py >= size - r) return _dist(px, py, r, size - r) <= r;
  if (px >= size - r && py >= size - r) return _dist(px, py, size - r, size - r) <= r;
  return true;
}

double _dist(int px, int py, int cx, int cy) =>
    sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy).toDouble());
