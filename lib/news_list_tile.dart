import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:iisvaldagno_news/news.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsListTile extends StatelessWidget {
  final RssItem item;

  NewsListTile(this.item);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: IconButton(
        icon: Icon(Icons.open_in_new),
        onPressed: () async {
          if (await canLaunch(item.link))
            await launch(item.link);
        },
      ),
      title: Text(
        item.title,
      ),
      subtitle: Text(
        // Source
        // https://stackoverflow.com/a/61801371
        DateFormat
          .yMMMMd()
          .add_jm()
          .format(DateFormat("E, dd MMM yyyy HH:mm:ss zzz").parse(item.pubDate)),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => News(item),
          ),
        );
      },
    );
  }
}