import 'package:anilist_data_viz/data/models/media_model.dart';
import 'package:anilist_data_viz/data/models/page_info_model.dart';

class PaginatedMediaModel {
  final List<MediaModel> mediaList;
  final PageInfoModel pageInfo;

  PaginatedMediaModel({
    required this.mediaList,
    required this.pageInfo,
  });
}
