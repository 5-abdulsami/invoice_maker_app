import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The printable page, for templates that place art relative to its edges.
const double kPageWidth = 595.28;
const double kPageHeight = 841.89;

/// Draws page decoration measured from the top-left corner, the way the
/// layouts themselves are reasoned about.
///
/// PDF graphics put the origin bottom-left with y pointing up; every method
/// here flips that once, so a template can say "a 150pt band at the top"
/// without doing the arithmetic in each painter.
class ArtCanvas {
  ArtCanvas(this.canvas, PdfPoint size)
      : width = size.x,
        height = size.y;

  final PdfGraphics canvas;
  final double width;
  final double height;

  double _y(double top) => height - top;

  void rect(double x, double top, double w, double h, PdfColor color) {
    canvas
      ..setFillColor(color)
      ..drawRect(x, _y(top + h), w, h)
      ..fillPath();
  }

  void roundedRect(
    double x,
    double top,
    double w,
    double h,
    double radius,
    PdfColor color,
  ) {
    canvas
      ..setFillColor(color)
      ..drawRRect(x, _y(top + h), w, h, radius, radius)
      ..fillPath();
  }

  void strokeRect(
    double x,
    double top,
    double w,
    double h,
    PdfColor color, {
    double lineWidth = 1,
  }) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(lineWidth)
      ..drawRect(x, _y(top + h), w, h)
      ..strokePath();
  }

  void circle(double cx, double cy, double r, PdfColor color) {
    canvas
      ..setFillColor(color)
      ..drawEllipse(cx, _y(cy), r, r)
      ..fillPath();
  }

  void ring(
    double cx,
    double cy,
    double r,
    PdfColor color, {
    double lineWidth = 1,
  }) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(lineWidth)
      ..drawEllipse(cx, _y(cy), r, r)
      ..strokePath();
  }

  void line(
    double x1,
    double y1,
    double x2,
    double y2,
    PdfColor color, {
    double lineWidth = 0.5,
  }) {
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(lineWidth)
      ..drawLine(x1, _y(y1), x2, _y(y2))
      ..strokePath();
  }

  /// A filled polygon through [points], given as (x, top) pairs.
  void polygon(List<(double, double)> points, PdfColor color) {
    if (points.isEmpty) return;
    canvas
      ..setFillColor(color)
      ..moveTo(points.first.$1, _y(points.first.$2));
    for (final point in points.skip(1)) {
      canvas.lineTo(point.$1, _y(point.$2));
    }
    canvas
      ..closePath()
      ..fillPath();
  }

  /// A band whose lower edge is a smooth wave, filled down from [top] (or up
  /// from the page foot when [fromBottom]).
  ///
  /// [baseline] is where the wave's centre line sits, measured from the top
  /// of the page; [amplitude] and [waves] shape the crest.
  void wave({
    required double baseline,
    required double amplitude,
    required double waves,
    required PdfColor color,
    double phase = 0,
    bool fromBottom = false,
  }) {
    final edge = fromBottom ? height : 0.0;
    const steps = 48;

    canvas
      ..setFillColor(color)
      ..moveTo(0, _y(edge));
    for (var i = 0; i <= steps; i++) {
      final x = width * i / steps;
      final t = (i / steps) * waves * 2 * math.pi + phase;
      canvas.lineTo(x, _y(baseline + math.sin(t) * amplitude));
    }
    canvas
      ..lineTo(width, _y(edge))
      ..closePath()
      ..fillPath();
  }

  /// Parallel diagonal lines filling a rectangle, clipped to it.
  void diagonalStripes(
    double x,
    double top,
    double w,
    double h,
    PdfColor color, {
    double spacing = 7,
    double lineWidth = 0.6,
  }) {
    canvas
      ..saveContext()
      ..drawRect(x, _y(top + h), w, h)
      ..clipPath()
      ..setStrokeColor(color)
      ..setLineWidth(lineWidth);
    for (var offset = -h; offset < w; offset += spacing) {
      canvas
        ..moveTo(x + offset, _y(top + h))
        ..lineTo(x + offset + h, _y(top));
    }
    canvas
      ..strokePath()
      ..restoreContext();
  }

  /// A square graph-paper grid over a rectangle, with a heavier line every
  /// [majorEvery] cells.
  void grid(
    double x,
    double top,
    double w,
    double h, {
    required double cell,
    required PdfColor minor,
    required PdfColor major,
    int majorEvery = 5,
  }) {
    void lines(PdfColor color, double lineWidth, bool Function(int) include) {
      canvas
        ..setStrokeColor(color)
        ..setLineWidth(lineWidth);
      var i = 0;
      for (var dx = 0.0; dx <= w; dx += cell, i++) {
        if (include(i)) {
          canvas
            ..moveTo(x + dx, _y(top))
            ..lineTo(x + dx, _y(top + h));
        }
      }
      i = 0;
      for (var dy = 0.0; dy <= h; dy += cell, i++) {
        if (include(i)) {
          canvas
            ..moveTo(x, _y(top + dy))
            ..lineTo(x + w, _y(top + dy));
        }
      }
      canvas.strokePath();
    }

    lines(minor, 0.3, (i) => i % majorEvery != 0);
    lines(major, 0.6, (i) => i % majorEvery == 0);
  }

  /// A halftone field: rows of dots that shrink from [maxRadius] to nothing
  /// across the rectangle, left to right.
  void halftone(
    double x,
    double top,
    double w,
    double h,
    PdfColor color, {
    double pitch = 9,
    double maxRadius = 3.2,
    bool fadeLeft = false,
  }) {
    canvas.setFillColor(color);
    var row = 0;
    for (var dy = pitch / 2; dy < h; dy += pitch, row++) {
      final shift = row.isOdd ? pitch / 2 : 0.0;
      for (var dx = pitch / 2 + shift; dx < w; dx += pitch) {
        final progress = dx / w;
        final r = maxRadius * (fadeLeft ? progress : 1 - progress);
        if (r < 0.35) continue;
        canvas.drawEllipse(x + dx, _y(top + dy), r, r);
      }
    }
    canvas.fillPath();
  }
}

/// Wraps a painter in a widget that fills the page behind the content.
pw.Widget pageArt(void Function(ArtCanvas art) paint) {
  return pw.CustomPaint(
    painter: (canvas, size) => paint(ArtCanvas(canvas, size)),
  );
}

/// Art of a fixed size, for a band or a shape placed inside a layout.
pw.Widget pageArtSized(
  double width,
  double height,
  void Function(ArtCanvas art) paint, {
  pw.Widget? child,
}) {
  return pw.CustomPaint(
    size: PdfPoint(width, height),
    painter: (canvas, size) => paint(ArtCanvas(canvas, size)),
    child: child,
  );
}
