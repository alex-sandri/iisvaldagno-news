import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';
import 'package:iisvaldagno_news/news_list_tile.dart';

class Search extends SearchDelegate
{
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (theme.brightness == Brightness.light) return super.appBarTheme(context);

    return theme;
  }
  
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      )
    ];
  }
  
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
  
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<http.Response>(
      future: http.get(Uri.encodeFull("https://www.iisvaldagno.it/?s=$query&feed=rss2")),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Column(
            children: [
              LinearProgressIndicator(),
            ],
          );

        final RssFeed feed = RssFeed.parse(snapshot.data.body);

        final List<RssItem> items = feed.items;

        return ListView.builder(
          itemCount: items.isNotEmpty
            ? items.length
            : 1,
          itemBuilder: (context, index) {
            if (items.isEmpty)
              return Padding(
                padding: EdgeInsets.all(4),
                child: Text(
                  "Nessun risultato",
                  textAlign: TextAlign.center,
                ),
              );

            return NewsListTile(items[index]);
          },
        );
      },
    );
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}