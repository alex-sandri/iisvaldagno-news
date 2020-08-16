import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:url_launcher/url_launcher.dart';

class News extends StatefulWidget {
  final RssItem item;

  News(this.item);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.item.title,
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  text: "News",
                  icon: Icon(Icons.view_headline),
                ),
                Tab(
                  text: "Allegati",
                  icon: Icon(Icons.attachment),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}