// Gráficas de línea y área: #1, #4, #5, #6, #12, #13, #19, #20, #23, #24,
// #26, #27, #29, #31.

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';

import '../common/graphic_common.dart';
import '../data/graphic_dataset.dart';
import 'graphic_chart_helpers.dart';

/// #1 Línea Simple — NATIVO — DERIVADO (score medio por año).
Widget g01LineSimple(GraphicDataset d) => guard(
      d.scoreByYear.length >= 2,
      () => Chart(
        data: d.scoreByYear,
        variables: categoryVars(yScale: LinearScale(min: 0, max: 100)),
        marks: [LineMark(position: Varset('x') * Varset('y'))],
        axes: standardAxes,
        selections: xSelection(),
        tooltip: TooltipGuide(),
      ),
    );

/// #4 Línea Curva / Spline — NATIVO — DERIVADO.
Widget g04Spline(GraphicDataset d) => guard(
      d.scoreByYear.length >= 3,
      () => Chart(
        data: d.scoreByYear,
        variables: categoryVars(yScale: LinearScale(min: 0, max: 100)),
        marks: [
          LineMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #5 Área — NATIVO — DERIVADO (títulos por año).
Widget g05Area(GraphicDataset d) => guard(
      d.countByYear.length >= 2,
      () => Chart(
        data: d.countByYear,
        variables: categoryVars(),
        marks: [
          AreaMark(
            position: Varset('x') * Varset('y'),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(110)),
          ),
          LineMark(position: Varset('x') * Varset('y')), // borde: el área no tiene propiedad de borde
        ],
        axes: standardAxes,
      ),
    );

/// #6 Spline Area — NATIVO — DERIVADO.
Widget g06SplineArea(GraphicDataset d) => guard(
      d.countByYear.length >= 3,
      () => Chart(
        data: d.countByYear,
        variables: categoryVars(),
        marks: [
          AreaMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(110)),
          ),
          LineMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicLineShape(smooth: true)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #12 Step Line — NATIVO — DERIVADO (acumulado de títulos por año).
Widget g12StepLine(GraphicDataset d) => guard(
      d.cumulativeByYear.length >= 2,
      () => Chart(
        data: d.cumulativeByYear,
        variables: categoryVars(),
        marks: [
          LineMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicLineShape(stepped: true)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #13 Step Area — NATIVO — DERIVADO.
Widget g13StepArea(GraphicDataset d) => guard(
      d.cumulativeByYear.length >= 2,
      () => Chart(
        data: d.cumulativeByYear,
        variables: categoryVars(),
        marks: [
          AreaMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicAreaShape(stepped: true)),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(110)),
          ),
          LineMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: BasicLineShape(stepped: true)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #19 Stacked Area — NATIVO — DERIVADO (año × formato, alineado).
Widget g19StackedArea(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty && d.years.length >= 2,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          marks: [
            AreaMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

/// #20 Stacked Line — NATIVO — DERIVADO.
/// StackModifier es genérico para cualquier mark (verificado en el código).
Widget g20StackedLine(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty && d.years.length >= 2,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          marks: [
            LineMark(
              position: Varset('x') * Varset('value') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

/// #23 100% Stacked Area — NATIVO — DERIVADO.
Widget g23Stacked100Area(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty && d.years.length >= 2,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          transforms: [Proportion(variable: 'value', nest: Varset('x'), as: 'percent')],
          marks: [
            AreaMark(
              position: Varset('x') * Varset('percent') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

/// #24 100% Stacked Line — NATIVO — DERIVADO.
Widget g24Stacked100Line(GraphicDataset d) => guard(
      d.yearFormatSeries.isNotEmpty && d.years.length >= 2,
      () => withLegend(
        Chart(
          data: d.yearFormatSeries,
          variables: seriesVars(),
          transforms: [Proportion(variable: 'value', nest: Varset('x'), as: 'percent')],
          marks: [
            LineMark(
              position: Varset('x') * Varset('percent') / Varset('series'),
              color: ColorEncode(variable: 'series', values: graphicPalette),
              shape: ShapeEncode(value: BasicLineShape(dash: [5, 3])),
              modifiers: [StackModifier()],
            ),
          ],
          axes: standardAxes,
        ),
        d.formats,
      ),
    );

/// #26 Range Area — NATIVO — DERIVADO (score mínimo y máximo por año).
Widget g26RangeArea(GraphicDataset d) => guard(
      d.scoreRangeByYear.length >= 2,
      () => Chart(
        data: d.scoreRangeByYear,
        variables: rangeVars(d.scoreRangeByYear),
        marks: [
          AreaMark(
            position: Varset('x') * (Varset('low') + Varset('high')),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(90)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #27 Spline Range Area — NATIVO — DERIVADO.
Widget g27SplineRangeArea(GraphicDataset d) => guard(
      d.scoreRangeByYear.length >= 3,
      () => Chart(
        data: d.scoreRangeByYear,
        variables: rangeVars(d.scoreRangeByYear),
        marks: [
          AreaMark(
            position: Varset('x') * (Varset('low') + Varset('high')),
            shape: ShapeEncode(value: BasicAreaShape(smooth: true)),
            color: ColorEncode(value: Defaults.primaryColor.withAlpha(90)),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #29 Line with markers — NATIVO — DERIVADO.
Widget g29LineWithMarkers(GraphicDataset d) => guard(
      d.scoreByYear.length >= 2,
      () => Chart(
        data: d.scoreByYear,
        variables: categoryVars(yScale: LinearScale(min: 0, max: 100)),
        marks: [
          LineMark(position: Varset('x') * Varset('y')),
          PointMark(
            position: Varset('x') * Varset('y'),
            shape: ShapeEncode(value: SquareShape()),
            size: SizeEncode(value: 8),
          ),
        ],
        axes: standardAxes,
      ),
    );

/// #31 Sparkline Line — VARIANTE — DERIVADO. Sin ejes ni padding.
Widget g31SparklineLine(GraphicDataset d) => guard(
      d.countByYear.length >= 2,
      () => Center(
        child: SizedBox(
          height: 48,
          width: 180,
          child: Chart(
            data: d.countByYear,
            padding: (_) => EdgeInsets.zero,
            variables: categoryVars(),
            marks: [LineMark(position: Varset('x') * Varset('y'), size: SizeEncode(value: 1.5))],
            // sin `axes` → Graphic no dibuja ejes
          ),
        ),
      ),
    );
