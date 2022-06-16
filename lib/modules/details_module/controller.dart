import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:komikku/data/hive.dart';
import 'package:komikku/dex/apis/chapter_read_marker_api.dart';
import 'package:komikku/dex/apis/manga_api.dart';
import 'package:komikku/modules/dto/chapter_dto.dart';
import 'package:komikku/modules/dto/manga_dto.dart';

class DetailsController extends GetxController {
  /// Argument from other page - home, search, subscribes
  final MangaDto data = Get.arguments;

  /// 倒序排序字典
  final Map<String, List<ChapterDto>> descChapters = <String, List<ChapterDto>>{};

  /// 正序排序字典
  final Map<String, List<ChapterDto>> ascChapters = <String, List<ChapterDto>>{};

  /// 章节排序是否是倒序通知
  /// 默认为true
  final RxBool _chapterGridIsDesc = true.obs;

  /// 获取章节排序是否是倒序
  get chapterGridIsDesc => _chapterGridIsDesc.value;

  /// 设置章节排序是否是倒序
  set chapterGridIsDesc(value) => _chapterGridIsDesc.value = value;

  /// 章节阅读记录
  final List<String> chapterReadMarkers = <String>[].obs;

  /// 是否正在加载
  final RxBool loading = false.obs;

  /// [DetailsController]的单例
  static DetailsController get to => Get.find();

  @override
  void onInit() async {
    super.onInit();
    try {
      loading.value = true;
      await Future.wait([_getMangaFeed(), _getMangaReadMarkers()]);
    } finally {
      loading.value = false;
    }
  }

  /// 获取漫画章节
  Future<void> _getMangaFeed() async {
    final queryMap = {
      'limit': '96',
      'offset': '0',
      'contentRating[]': HiveDatabase.contentRating,
      'translatedLanguage[]': HiveDatabase.translatedLanguage,
      'includes[]': ["scanlation_group", "user"],

      // 切勿 readableAt: OrderMode.desc, 否则缺少章节
      'order[volume]': 'desc',
      'order[chapter]': 'desc',
    };

    final response = await MangaApi.getMangaFeedAsync(data.id, queryParameters: queryMap);

    final newItems = response.data.map((e) => ChapterDto.fromDex(e)).toList();

    if (!newItems
        .any((value) => value.chapter == null || double.tryParse(value.chapter!) == null)) {
      // 按章节排序
      descChapters.addAll(newItems
          .sortedByCompare(
            (value) => double.parse(value.chapter!),
            (double a, double b) => b.compareTo(a),
          )
          .groupListsBy(
            (e) => e.chapter!,
          ));

      ascChapters.addAll(newItems
          .sortedByCompare(
            (value) => double.parse(value.chapter!),
            (double a, double b) => a.compareTo(b),
          )
          .groupListsBy(
            (e) => e.chapter!,
          ));
    } else {
      // 没有章节，按readableAt排序
      descChapters.addAll(newItems
          .sortedByCompare(
            (value) => value.readableAt,
            (DateTime a, DateTime b) => b.compareTo(a),
          )
          .groupListsBy(
            (e) => '${e.readableAt}',
          ));

      ascChapters.addAll(newItems
          .sortedByCompare(
            (value) => value.readableAt,
            (DateTime a, DateTime b) => a.compareTo(b),
          )
          .groupListsBy(
            (e) => '${e.readableAt}',
          ));
    }
  }

  /// 获取漫画阅读记录
  Future<void> _getMangaReadMarkers() async {
    if (!HiveDatabase.userLoginState) return;
    final response = await ChapterReadMarkerApi.getMangaReadMarkersAsync(data.id);
    chapterReadMarkers.addAll(response.data);
  }

  /// 设置漫画已经阅读
  Future<void> markMangaRead(String id) async {
    if (!HiveDatabase.userLoginState) return;
    await ChapterReadMarkerApi.markChapterRead(id);
    chapterReadMarkers.add(id);
  }
}
