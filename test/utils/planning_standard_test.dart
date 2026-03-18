import 'package:flutter_test/flutter_test.dart';
import 'package:hesapkitap_v1/utils/planning_standard.dart';

void main() {
  test('previewDates includes the selected end day for daily plans with time', () {
    final dates = PlanningStandard.previewDates(
      startDate: DateTime(2026, 3, 18, 14, 30),
      periodType: 'daily',
      frequency: 1,
      endDate: DateTime(2026, 3, 20),
      maxCount: 10,
    );

    expect(
      dates,
      [
        DateTime(2026, 3, 18, 14, 30),
        DateTime(2026, 3, 19, 14, 30),
        DateTime(2026, 3, 20, 14, 30),
      ],
    );
  });
}
