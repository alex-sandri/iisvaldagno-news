import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:iisvaldagno_news/news.dart';
import 'package:iisvaldagno_news/search.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _page = 1;

  List<RssItem> _items;

  bool _showLoadMoreButton = true;

  bool _showLoadMoreSpinner = false;

  Future<List<RssItem>> _getItems() async {
    final http.Response response = await http.get("https://www.iisvaldagno.it/page/$_page/?s=&feed=rss2");

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
          child: _items == null
            ? LinearProgressIndicator()
            : ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                itemCount: _items.length + 1,
                itemBuilder: (context, index) {
                  if (index == _items.length)
                  {
                    if (_showLoadMoreSpinner)
                      return Padding(
                        padding: EdgeInsets.all(4),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                    if (!_showLoadMoreButton) return Container();

                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: FlatButton(
                        color: Theme.of(context).primaryColor,
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "Carica più elementi",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        onPressed: () async {
                          setState(() {
                            _showLoadMoreButton = false;
                            _showLoadMoreSpinner = true;
                          });

                          _page++;

                          final List<RssItem> items = await _getItems();

                          if (mounted)
                            setState(() {
                              _items.addAll(items);

                              _showLoadMoreButton = items.isNotEmpty;
                              _showLoadMoreSpinner = false;
                            });
                        },
                      ),
                    );
                  }

                  final RssItem item = _items[index];

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
                },
              ),
        ),
      ),
    );
  }
}