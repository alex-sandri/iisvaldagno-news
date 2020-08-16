import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

class RssContentLink
{
  String text;
  Uri url;

  RssContentLink({
    @required this.text,
    @required this.url,
  });
}

class News extends StatefulWidget {
  final RssItem item;

  News(this.item);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    final List<RssContentLink> links = [];

    final document = parse(widget.item.content.value);

    document.querySelectorAll("a").forEach((element) {
      links.add(RssContentLink(
        text: element.text,
        url: Uri.parse(element.attributes["href"]),
      ));
    });

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
              Column(
                children: [
                  SelectableText(
                    widget.item.title,
                  ),
                  SelectableText(
                    document.querySelector("p").text,
                  ),
                ],
              ),
              Container(),
            ],
          ),
        ),
      ),
    );
  }
}