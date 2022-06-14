import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:komikku/data/hive.dart';
import 'package:komikku/dex/apis/manga_api.dart';
import 'package:komikku/dex/models.dart';
import 'package:komikku/dto/manga_dto.dart';

class SearchController extends GetxController {
  final pagingController = PagingController<int, MangaDto>(firstPageKey: 0);
  final tagsGrouped = <String, Map<String, String>>{};
  final selectedTags = <String, String>{}.obs;
  var searchTitle = '';

  /// [SearchController]的单例
  static SearchController get to => Get.find();

  @override
  void onInit() async {
    pagingController.addPageRequestListener((pageKey) async => await _searchMangaList(pageKey));

    final response = await MangaApi.getTagListAsync();
    tagsGrouped.addAll(groupBy<Tag, String>(response.data, (p0) => p0.attributes.group)
        .map((key, value) => MapEntry(key, _toMap(value))));
    super.onInit();
  }

  /// 添加标签
  void addAll(MapEntry<String, String> value) => selectedTags.addEntries([value]);

  /// 移除标签
  void removeValue(String value) => selectedTags.removeWhere((k, v) => v == value);

  static const _pageSize = 20;

  /// 搜索漫画
  Future<void> _searchMangaList(int pageKey) async {
    final queryMap = {
      'title': searchTitle,
      'limit': '$_pageSize',
      'offset': '$pageKey',
      'contentRating[]': HiveDatabase.contentRating,
      'availableTranslatedLanguage[]': HiveDatabase.translatedLanguage,
      'includes[]': ["cover_art", "author"],
      'includedTags[]': selectedTags.keys,
      'order[relevance]': 'desc',
    };

    try {
      final response = await MangaApi.getMangaListAsync(queryParameters: queryMap);

      var newItems = response.data.map((e) => MangaDto.fromDex(e)).toList();
      if (newItems.length < _pageSize) {
        // Last
        pagingController.appendLastPage(newItems);
      } else {
        var nextPageKey = pageKey + newItems.length;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      if (kDebugMode) rethrow;
    }
  }

  Map<String, String> _toMap(List<Tag> tags) {
    var value = <String, String>{};
    for (var tag in tags) {
      final nameMap = tag.attributes.name.toJson();
      var name = nameMap.values.first;
      for (var entry in nameMap.entries) {
        if (!HiveDatabase.translatedLanguage.contains(entry.key)) continue;
        name = entry.value;
      }
      value.addAll({tag.id: name});
    }

    return value;
  }
}
