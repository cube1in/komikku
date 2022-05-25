import 'dart:async';

import 'package:flutter/material.dart';
import 'package:komikku/dex/apis.dart';
import 'package:komikku/dex/models.dart';
import 'package:komikku/dto/manga_dto.dart';
import 'package:komikku/views/details.dart';
import 'package:komikku/widgets/builder_checker.dart';
import 'package:komikku/widgets/manga_grid_view_item.dart';

class LatestUpdate extends StatefulWidget {
  const LatestUpdate({Key? key}) : super(key: key);

  @override
  State<LatestUpdate> createState() => _LatestUpdateState();
}

class _LatestUpdateState extends State<LatestUpdate> {
  final _streamController = StreamController<List<MangaDto>>();
  final _scrollController = ScrollController();
  final _cacheMangaList = <MangaDto>[];
  int chapterLimit = 40;
  int chapterOffset = 0;

  /// 不小于20
  int mangaGreaterOrEqual = 20;

  @override
  void initState() {
    super.initState();
    sinkStream();

    /// 监听滚动控制器
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && _scrollController.position.pixels != 0) {
        // On bottom
        sinkStream();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamController.close();
    _scrollController.dispose();
  }

  /// 推入流中
  sinkStream({bool refresh = false}) async {
    if (refresh) {
      _cacheMangaList.clear();
      chapterOffset = 0;
    }

    var distinctMangaList = <MangaDto>[];

    /// 获取足够的并且不重复的Manga
    while (distinctMangaList.length < mangaGreaterOrEqual) {
      var list = await _getMangaList();

      /// 添加_cacheMangaList没有并且distinctMangaList也没有的
      distinctMangaList.addAll(list.where((m) =>
          !_cacheMangaList.map((e) => e.id).contains(m.id) &&
          !distinctMangaList.map((e) => e.id).contains(m.id)));

      /// 设置Chapter查询偏移
      chapterOffset += chapterLimit;
    }

    _cacheMangaList.addAll(distinctMangaList);
    _streamController.sink.add(_cacheMangaList);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MangaDto>>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        return BuilderChecker(
          snapshot: snapshot,
          widget: () => RefreshIndicator(
            onRefresh: () async {
              await sinkStream(refresh: true);
            },
            child: GridView.builder(
              // 永远滚动，即使在不满屏幕的情况下
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              controller: _scrollController,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    /// 在刷新时点击可能会出现index > snapshot.data!.length的情况
                    if (index < snapshot.data!.length) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(dto: snapshot.data![index]),
                        ),
                      );
                    }
                  },
                  child: MangaGridViewItem(
                    dto: snapshot.data![index],
                    titleStyle: TitleStyle.footer,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 获取漫画列表
  Future<List<MangaDto>> _getMangaList() async {
    // var distinctChapters = <Chapter>[];

    var chapterListResponse = await ChapterApi.getChapterListAsync(
      query: ChapterListQuery(
        limit: chapterLimit,
        offset: chapterOffset,
        // includes: ['manga', 'scanlation_group'],
        includes: ['manga'],
        translatedLanguage: ['zh', 'zh-hk'],
        contentRating: [
          ContentRating.safe,
          ContentRating.suggestive,
          ContentRating.erotica,
          ContentRating.pornographic
        ],
      ),
      order: ChapterListOrder(readableAt: OrderMode.desc).build(),
    );

    /// NOTE: 必须含有 MangaAttributes
    var mangaIds = chapterListResponse.data
        .map((chapter) => chapter.relationships.firstType(EntityType.manga).id)
        .toSet();
    // for (var id in mangaIds) {
    //   distinctChapters.add(chapterListResponse.data.firstWhere(
    //       (item) => item.relationships.firstType(EntityType.manga).id == id));
    // }

    var mangaListResponse = await MangaApi.getMangaListAsync(
      query: MangaListQuery(
        ids: mangaIds.toList(),
        limit: mangaIds.length,
        includes: ['cover_art', 'author'],
        contentRating: [
          ContentRating.safe,
          ContentRating.suggestive,
          ContentRating.erotica,
          ContentRating.pornographic
        ],
      ),
    );
    return mangaListResponse.data.map((e) => MangaDto.fromSource(e)).toList();
  }
}
