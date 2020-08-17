import 'package:flutter/material.dart';
import 'package:iisvaldagno_news/news_list.dart';

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
    return NewsList("https://www.iisvaldagno.it/page/{{PAGE}}/?s=$query&feed=rss2");
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView();
  }
}