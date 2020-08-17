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
  int _page = 1;

  List<RssItem> _items;

  bool _showLoadMoreButton = true;

  bool _showLoadMoreSpinner = false;

  Future<List<RssItem>> _getItems() async {
    final http.Response response = await http.get(
      widget.url?.replaceFirst("{{PAGE}}", _page.toString())
      ?? "https://www.iisvaldagno.it/page/$_page/?s=&feed=rss2"
    );

    final RssFeed feed = RssFeed.parse(response.body);

    final List<RssItem> items = feed.items;

    return items;
  }

  Future<void> _handleRefresh() async {
    _page = 1;

    final List<RssItem> items = await _getItems();

    if (mounted)
      setState(() {
        _items = items;
      });
  }

  void initState() {
    super.initState();

    _handleRefresh();
  }

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
        body: RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.blue,
          onRefresh: _handleRefresh,
          child: NewsList()
        ),
      ),
    );
  }
}