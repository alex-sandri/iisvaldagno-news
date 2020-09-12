import 'package:dart_rss/dart_rss.dart';
import 'package:dart_rss/domain/dublin_core/dublin_core.dart';
import 'package:dart_rss/domain/rss_content.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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

  SerializableNews._({
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

  static SerializableNews fromRssItem(RssItem rssItem) => SerializableNews._(
    title: rssItem.title,
    link: rssItem.link,
    content: rssItem.content.value,
    categories: rssItem.categories.map<String>((category) => category.value).toList(),
    creator: rssItem.dc.creator,
    pubDate: rssItem.pubDate,
  );
}