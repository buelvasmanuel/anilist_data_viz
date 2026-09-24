import 'package:anilist_data_viz/domain/entities/fuzzy_date.dart';

class FuzzyDateModel extends FuzzyDate {
  FuzzyDateModel({
    super.year,
    super.month,
    super.day,
  });

  factory FuzzyDateModel.fromJson(Map<String, dynamic> json) {
    return FuzzyDateModel(
      year: json['year'],
      month: json['month'],
      day: json['day'],
    );
  }
}
