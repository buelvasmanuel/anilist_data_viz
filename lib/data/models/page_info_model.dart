import 'package:anilist_data_viz/domain/entities/page_info.dart';

class PageInfoModel extends PageInfo {
  PageInfoModel({
    super.currentPage,
    super.hasNextPage,
    super.lastPage,
    super.perPage,
    super.total,
  });

  factory PageInfoModel.fromJson(Map<String, dynamic> json) {
    return PageInfoModel(
      currentPage: json['currentPage'],
      hasNextPage: json['hasNextPage'],
      lastPage: json['lastPage'],
      perPage: json['perPage'],
      total: json['total'],
    );
  }
}
