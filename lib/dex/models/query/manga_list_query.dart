import 'package:json_annotation/json_annotation.dart';
import 'package:komikku/dex/models/enum/content_rating.dart';
import 'package:komikku/dex/models/enum/publication_demographic.dart';
import 'package:komikku/dex/models/enum/order_mode.dart';
import 'package:komikku/dex/models/enum/logic_mode.dart';

/// MangaList Query
class MangaListQuery {
  final List<String>? ids;
  final String? title;
  final String? group;
  final bool? hasAvailableChapters;
  final List<String>? authors;
  final List<String>? artists;
  final int? year;
  final List<String>? includedTags;
  final LogicMode? includedTagsMode;
  final List<String>? excludedTags;
  final LogicMode? excludedTagsMode;
  final List<String>? status;
  final List<String>? originalLanguage;
  final List<String>? excludedOriginalLanguage;
  final List<String>? availableTranslatedLanguage;
  final List<PublicationDemographic>? publicationDemographic;
  final List<ContentRating>? contentRating;

  final DateTime? createdAtSince;
  final DateTime? updatedAtSince;

  final List<String>? includes;
  final int? limit;
  final int? offset;

  MangaListQuery({
    this.ids,
    this.title,
    this.group,
    this.hasAvailableChapters,
    this.authors,
    this.artists,
    this.year,
    this.includedTags,
    this.includedTagsMode,
    this.excludedTags,
    this.excludedTagsMode,
    this.status,
    this.originalLanguage,
    this.excludedOriginalLanguage,
    this.availableTranslatedLanguage,
    this.publicationDemographic,
    this.contentRating,
    this.createdAtSince,
    this.updatedAtSince,
    this.includes,
    this.limit,
    this.offset,
  });

  factory MangaListQuery.fromJson(Map<String, dynamic> json) => MangaListQuery(
        ids: (json['ids[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        title: json['title'] as String?,
        group: json['group'] as String?,
        hasAvailableChapters: json['hasAvailableChapters'] as bool?,
        authors: (json['authors[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        artists: (json['artists[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        year: json['year'] as int?,
        includedTags: (json['includedTags[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        includedTagsMode: $enumDecodeNullable(logicModeEnumMap, json['includedTagsMode']),
        excludedTags: (json['excludedTags[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        excludedTagsMode: $enumDecodeNullable(logicModeEnumMap, json['excludedTagsMode']),
        status: (json['status[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        originalLanguage:
            (json['originalLanguage[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        excludedOriginalLanguage: (json['excludedOriginalLanguage[]'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        availableTranslatedLanguage: (json['availableTranslatedLanguage[]'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        publicationDemographic: (json['publicationDemographic[]'] as List<dynamic>?)
            ?.map((e) => $enumDecode(publicationDemographicEnumMap, e))
            .toList(),
        contentRating: (json['contentRating[]'] as List<dynamic>?)
            ?.map((e) => $enumDecode(contentRatingEnumMap, e))
            .toList(),
        createdAtSince: json['createdAtSince'] == null
            ? null
            : DateTime.parse(json['createdAtSince'] as String),
        updatedAtSince: json['updatedAtSince'] == null
            ? null
            : DateTime.parse(json['updatedAtSince'] as String),
        includes: (json['includes[]'] as List<dynamic>?)?.map((e) => e as String).toList(),
        limit: json['limit'] as int?,
        offset: json['offset'] as int?,
      );

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('ids[]', ids);
    writeNotNull('title', title);
    writeNotNull('group', group);
    writeNotNull('hasAvailableChapters', hasAvailableChapters);
    writeNotNull('authors[]', authors);
    writeNotNull('artists[]', artists);
    writeNotNull('year', year);
    writeNotNull('includedTags[]', includedTags);
    writeNotNull('includedTagsMode', logicModeEnumMap[includedTagsMode]);
    writeNotNull('excludedTags[]', excludedTags);
    writeNotNull('excludedTagsMode', logicModeEnumMap[excludedTagsMode]);
    writeNotNull('status[]', status);
    writeNotNull('originalLanguage[]', originalLanguage);
    writeNotNull('excludedOriginalLanguage[]', excludedOriginalLanguage);
    writeNotNull('availableTranslatedLanguage[]', availableTranslatedLanguage);
    writeNotNull('publicationDemographic[]',
        publicationDemographic?.map((e) => publicationDemographicEnumMap[e]).toList());
    writeNotNull('contentRating[]', contentRating?.map((e) => contentRatingEnumMap[e]).toList());
    writeNotNull('createdAtSince', createdAtSince?.toIso8601String());
    writeNotNull('updatedAtSince', updatedAtSince?.toIso8601String());
    writeNotNull('includes[]', includes);
    writeNotNull('limit', limit?.toString());
    writeNotNull('offset', offset?.toString());
    return val;
  }
}

/// MangaList Order
class MangaListOrder {
  final OrderMode? title;
  final OrderMode? year;
  final OrderMode? createdAt;
  final OrderMode? updatedAt;
  final OrderMode? latestUploadedChapter;
  final OrderMode? followedCount;
  final OrderMode? relevance;

  MangaListOrder({
    this.title,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.latestUploadedChapter,
    this.followedCount,
    this.relevance,
  });

  String build() {
    var query = '';
    if (title != null) {
      query += '&order[title]=${orderModeEnumMap[title]}';
    }
    if (year != null) {
      query += '&order[year]=${orderModeEnumMap[year]}';
    }
    if (createdAt != null) {
      query += '&order[createdAt]=${orderModeEnumMap[createdAt]}';
    }
    if (updatedAt != null) {
      query += '&order[updatedAt]=${orderModeEnumMap[updatedAt]}';
    }
    if (latestUploadedChapter != null) {
      query += '&order[latestUploadedChapter]=${orderModeEnumMap[latestUploadedChapter]}';
    }
    if (followedCount != null) {
      query += '&order[followedCount]=${orderModeEnumMap[followedCount]}';
    }
    if (relevance != null) {
      query += '&order[relevance]=${orderModeEnumMap[relevance]}';
    }

    return query.substring(1);
  }
}
