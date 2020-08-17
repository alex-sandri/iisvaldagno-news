import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:iisvaldagno_news/news_list.dart';
import 'package:iisvaldagno_news/news_list_tile.dart';
import 'package:iisvaldagno_news/search.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IIS Valdagno News",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  final String url;

  Home([ this.url ]);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "IIS Valdagno News",
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: Search()
                );
              },
            )
          ],
        ),
        body: NewsList(),
      ),
    );
  }
}