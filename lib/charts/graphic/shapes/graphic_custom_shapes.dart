// Shapes personalizados para los casos de COMPOSICIÓN.
//
// Graphic 2.7.0 permite extender `Shape` (API oficial de extensión). Estas
// clases solo DIBUJAN: los datos (OHLC, cuartiles, errores) llegan ya
// calculados.
//
// Se usan siempre con `CustomMark(shape: ShapeEncode(value: ...))`, salvo
// ExplodedRectShape, que extiende `RectShape` y se usa con `IntervalMark`.
//
// Verificado contra el código fuente de graphic 2.7.0:
//   Shape.drawGroupPrimitives(List<Attributes>, CoordConv, Offset)
//   Shape.drawGroupLabels(List<Attributes>, CoordConv, Offset)
//   Shape.defaultSize, Shape.equalTo
//   getPaintStyle(Attributes, bool hollow, double strokeWidth, Rect?, List<double>?)

import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:graphic/graphic.dart';

/// #33 HLOC. Orden de posición: `[open, high, low, close]`.
///
/// Dibuja la línea vertical high-low, un tick a la izquierda en open y un
/// tick a la derecha en close.
class HlocShape extends Shape {
  HlocShape({this.strokeWidth = 1.5});

  final double strokeWidth;

  @override
  bool equalTo(Object other) => other is HlocShape && other.strokeWidth == strokeWidth;

  @override
  double get defaultSize => 10;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (final item in group) {
      final p = item.position.map(coord.convert).toList();
      if (p.length < 4) continue;
      final x = p[0].dx;
      final tick = (item.size ?? defaultSize) / 2;
      rst.add(PathElement(
        segments: [
          MoveSegment(end: Offset(x, p[1].dy)),
          LineSegment(end: Offset(x, p[2].dy)),
          MoveSegment(end: Offset(x - tick, p[0].dy)),
          LineSegment(end: Offset(x, p[0].dy)),
          MoveSegment(end: Offset(x, p[3].dy)),
          LineSegment(end: Offset(x + tick, p[3].dy)),
        ],
        style: getPaintStyle(item, true, strokeWidth, null, null),
        tag: item.tag,
      ));
    }
    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) =>
      const [];
}

/// #34 Box and Whisker. Orden de posición: `[min, q1, median, q3, max]`.
///
/// Las cinco variables DEBEN compartir la misma escala.
class BoxPlotShape extends Shape {
  BoxPlotShape({this.strokeWidth = 1.5});

  final double strokeWidth;

  @override
  bool equalTo(Object other) => other is BoxPlotShape && other.strokeWidth == strokeWidth;

  @override
  double get defaultSize => 24;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (final item in group) {
      final p = item.position.map(coord.convert).toList();
      if (p.length < 5) continue;
      final x = p[0].dx;
      final half = (item.size ?? defaultSize) / 2;
      final cap = half / 2;
      final yMin = p[0].dy, yQ1 = p[1].dy, yMed = p[2].dy, yQ3 = p[3].dy, yMax = p[4].dy;
      rst.add(PathElement(
        segments: [
          // Bigote inferior + cap
          MoveSegment(end: Offset(x, yMin)),
          LineSegment(end: Offset(x, yQ1)),
          MoveSegment(end: Offset(x - cap, yMin)),
          LineSegment(end: Offset(x + cap, yMin)),
          // Caja q1-q3
          MoveSegment(end: Offset(x - half, yQ1)),
          LineSegment(end: Offset(x + half, yQ1)),
          LineSegment(end: Offset(x + half, yQ3)),
          LineSegment(end: Offset(x - half, yQ3)),
          CloseSegment(),
          // Mediana
          MoveSegment(end: Offset(x - half, yMed)),
          LineSegment(end: Offset(x + half, yMed)),
          // Bigote superior + cap
          MoveSegment(end: Offset(x, yQ3)),
          LineSegment(end: Offset(x, yMax)),
          MoveSegment(end: Offset(x - cap, yMax)),
          LineSegment(end: Offset(x + cap, yMax)),
        ],
        style: getPaintStyle(item, true, strokeWidth, null, null),
        tag: item.tag,
      ));
    }
    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) =>
      const [];
}

/// #35 Error Bars con caps. Orden de posición: `[low, mean, high]`.
class ErrorBarShape extends Shape {
  ErrorBarShape({this.strokeWidth = 1.5, this.pointRadius = 4});

  final double strokeWidth;
  final double pointRadius;

  @override
  bool equalTo(Object other) =>
      other is ErrorBarShape &&
      other.strokeWidth == strokeWidth &&
      other.pointRadius == pointRadius;

  @override
  double get defaultSize => 14;

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final rst = <MarkElement>[];
    for (final item in group) {
      final p = item.position.map(coord.convert).toList();
      if (p.length < 3) continue;
      final x = p[0].dx;
      final cap = (item.size ?? defaultSize) / 2;
      rst.add(PathElement(
        segments: [
          MoveSegment(end: Offset(x, p[0].dy)),
          LineSegment(end: Offset(x, p[2].dy)),
          MoveSegment(end: Offset(x - cap, p[0].dy)),
          LineSegment(end: Offset(x + cap, p[0].dy)),
          MoveSegment(end: Offset(x - cap, p[2].dy)),
          LineSegment(end: Offset(x + cap, p[2].dy)),
        ],
        style: getPaintStyle(item, true, strokeWidth, null, null),
        tag: item.tag,
      ));
      rst.add(CircleElement(
        center: p[1],
        radius: pointRadius,
        style: getPaintStyle(item, false, 0, null, null),
        tag: item.tag,
      ));
    }
    return rst;
  }

  @override
  List<MarkElement> drawGroupLabels(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) =>
      const [];
}

/// #56 Exploding Radial Bar.
///
/// Reutiliza el dibujo de `RectShape` en coordenadas polares y desplaza hacia
/// fuera, a lo largo de su ángulo medio, los sectores cuya elevación es > 0.
/// La elevación se activa con un `updater` de selección en el
/// `ElevationEncode`, así que "explotar" = "estar seleccionado".
class ExplodedRectShape extends RectShape {
  ExplodedRectShape({this.explodeOffset = 12, BorderRadius? borderRadius})
      : super(borderRadius: borderRadius);

  final double explodeOffset;

  @override
  bool equalTo(Object other) =>
      other is ExplodedRectShape &&
      other.explodeOffset == explodeOffset &&
      super.equalTo(other);

  @override
  List<MarkElement> drawGroupPrimitives(
    List<Attributes> group,
    CoordConv coord,
    Offset origin,
  ) {
    final base = super.drawGroupPrimitives(group, coord, origin);
    return [
      for (final e in base)
        if (e is SectorElement && (e.style.elevation ?? 0) > 0)
          SectorElement(
            center: e.center +
                Offset(
                  math.cos((e.startAngle + e.endAngle) / 2),
                  math.sin((e.startAngle + e.endAngle) / 2),
                ) *
                    explodeOffset,
            startRadius: e.startRadius,
            endRadius: e.endRadius,
            startAngle: e.startAngle,
            endAngle: e.endAngle,
            borderRadius: e.borderRadius,
            style: e.style,
            tag: e.tag,
          )
        else
          e,
    ];
  }
}
