import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

class Search extends SearchDelegate
{
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
        if (!snapshot.hasData) return LinearProgressIndicator();

        final RssFeed feed = RssFeed.parse(snapshot.data.body);

        final List<RssItem> items = feed.items;

        return ListView.builder(
          itemCount: 0,
          itemBuilder: (context, index) {
            return ListTile(

            );
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