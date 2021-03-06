import 'dart:io';

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

  bool _isOffline = false;

  Future<List<RssItem>> _getItems() async {
    try
    {
      final http.Response response = await http.get(
        widget.url?.replaceFirst("{{PAGE}}", _page.toString())
        ?? "https://www.iisvaldagno.it/page/$_page/?feed=rss2"
      );

      setState(() {
        _isOffline = false;
      });

      final RssFeed feed = RssFeed.parse(response.body);

      final List<RssItem> items = feed.items;

      return items;
    }
    on SocketException
    {
      setState(() {
        _isOffline = true;
      });

      return [];
    }
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
    if (!_showLoadMoreButton) return;

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
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.extentAfter == 0)
          _loadMore();

        return true;
      },
      child: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: _handleRefresh,
        child: _items == null
          ? Column(
              children: [
                LinearProgressIndicator(),
              ],
            )
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: _items.length + 1,
              itemBuilder: (context, index) {
                if (_isOffline)
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Nessuna connessione a Internet",
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _items = null;
                            });

                            _handleRefresh();
                          },
                          child: Text(
                            "Riprova",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                            padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                          ),
                        ),
                      ],
                    ),
                  );

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

                  return TextButton(
                    child: Text(
                      "Carica più elementi",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
                      padding: MaterialStateProperty.all(EdgeInsets.all(15)),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
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