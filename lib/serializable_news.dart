import 'package:dart_rss/dart_rss.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class SerializableNews
{
  SerializableNews();

  RssItem toRssItem() => null;

  static SerializableNews fromRssItem(RssItem rssItem) => null;
}