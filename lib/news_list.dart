import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/material.dart';
import 'package:iisvaldagno_news/news_list_tile.dart';
import 'package:http/http.dart' as http;

class NewsList extends StatefulWidget {
  final String url;

  NewsList([ this.url ]);

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
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
    return RefreshIndicator(
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

              return NewsListTile(_items[index]);
            },
          ),
    );
  }
}