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

  bool _loading = false;

  Future<void> _loadMore() async {
    if (_loading) return;

    setState(() {
      _loading = true;

      _showLoadMoreButton = false;
    });

    _page++;

    final List<RssItem> items = await _getItems();

    if (mounted)
      setState(() {
        _items.addAll(items);

        _showLoadMoreButton = items.isNotEmpty;

        _loading = false;
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
        ? Column(
            children: [
              LinearProgressIndicator(),
            ],
          )
        : NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.extentAfter == 0)
                _loadMore();

              return true;
            },
            child: ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (_items.isEmpty)
                  return Padding(
                    padding: EdgeInsets.all(4),
                    child: Text(
                      "Nessun risultato",
                      textAlign: TextAlign.center,
                    ),
                  );

                if (index == _items.length)
                {
                  if (_loading)
                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                  if (!_showLoadMoreButton) return Container();

                  return FlatButton(
                    color: Theme.of(context).primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Carica più elementi",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    onPressed: _loadMore,
                  );
                }

                return NewsListTile(_items[index]);
              },
            ),
        ),
    );
  }
}