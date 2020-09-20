import 'package:dart_rss/dart_rss.dart';
import 'package:dart_rss/domain/dublin_core/dublin_core.dart';
import 'package:dart_rss/domain/rss_content.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'SerializableNews.g.dart';

@HiveType(typeId: 0)
class SerializableNews
{
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final List<String> categories;

  @HiveField(4)
  final String creator;

  @HiveField(5)
  final String pubDate;

  SerializableNews({
    @required this.title,
    @required this.link,
    @required this.content,
    @required this.categories,
    @required this.creator,
    @required this.pubDate,
  });

  RssItem toRssItem() => RssItem(
    title: title,
    link: link,
    content: RssContent(content, []),
    categories: categories.map<RssCategory>((category) => RssCategory("DOMAIN", category)).toList(),
    dc: DublinCore(
      creator: creator,
    ),
    pubDate: pubDate,
  );

  SerializableNews copyWith({
    String title,
    String link,
    String content,
    List<String> categories,
    String creator,
    String pubDate,
  }) => SerializableNews(
    title: title ?? this.title,
    link: link ?? this.link,
    content: content ?? this.content,
    categories: categories ?? this.categories,
    creator: creator ?? this.creator,
    pubDate: pubDate ?? this.pubDate,
  );

  static SerializableNews fromRssItem(RssItem rssItem) => SerializableNews(
    title: rssItem.title,
    link: rssItem.link,
    content: rssItem.content.value,
    categories: rssItem.categories.map<String>((category) => category.value).toList(),
    creator: rssItem.dc.creator,
    pubDate: rssItem.pubDate,
  );

  bool operator ==(Object other) => other is SerializableNews && other.link == link;

  @override
  int get hashCode => super.hashCode;
}