import 'package:flutter_test/flutter_test.dart';
import 'package:anilist_data_viz/charts/models/master_chart_registry.dart';

void main() {
  group('MasterChartRegistry validation', () {
    test('Should contain exactly 63 cases', () {
      expect(masterChartRegistry.length, 63);
    });

    test('Should have exact unique numbers from 1 to 63', () {
      final numbers = masterChartRegistry.map((e) => e.number).toList();
      numbers.sort();
      
      expect(numbers.length, 63);
      expect(numbers.first, 1);
      expect(numbers.last, 63);
      expect(numbers.toSet().length, 63, reason: 'No duplicate numbers allowed');
    });

    test('Every chart must define exactly 4 libraries', () {
      for (final spec in masterChartRegistry) {
        expect(spec.support.length, 4, reason: 'Chart #${spec.number} does not have exactly 4 libraries');
        expect(spec.support.containsKey(ChartLibrary.flChart), isTrue, reason: 'Chart #${spec.number} missing flChart');
        expect(spec.support.containsKey(ChartLibrary.syncfusion), isTrue, reason: 'Chart #${spec.number} missing syncfusion');
        expect(spec.support.containsKey(ChartLibrary.dChart), isTrue, reason: 'Chart #${spec.number} missing dChart');
        expect(spec.support.containsKey(ChartLibrary.graphic), isTrue, reason: 'Chart #${spec.number} missing graphic');
      }
    });
    
    test('Names should not be empty', () {
      for (final spec in masterChartRegistry) {
        expect(spec.name.isNotEmpty, isTrue, reason: 'Chart #${spec.number} has empty name');
      }
    });
  });
}
