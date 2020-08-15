import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "IIS Valdagno News",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
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

  Future<void> _handleRefresh() async {
    final http.Response response = await http.get("https://www.iisvaldagno.it/page/$_page/?s=&feed=rss2");

    final RssFeed feed = RssFeed.parse(response.body);

    final List<RssItem> items = feed.items;

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
        ),
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: _items == null
            ? LinearProgressIndicator()
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final RssItem item = _items[index];

                  final List<RssContentLink> links = [];

                  final document = parse(item.content.value);

                  document.querySelectorAll("a").forEach((element) {
                    links.add(RssContentLink(
                      text: element.text,
                      url: Uri.parse(element.attributes["href"]),
                    ));
                  });

                  return ListTile(
                    trailing: IconButton(
                      icon: Icon(Icons.open_in_new),
                      onPressed: () {
                        // TODO
                      },
                    ),
                    title: SelectableText(
                      item.title,
                    ),
                    subtitle: Column(
                      children: [
                        SelectableText(
                          parse(item.content.value).body.text,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: links.length,
                          itemBuilder: (context, index) {
                            final RssContentLink link = links[index];

                            return ListTile(
                              title: Text(
                                link.text,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }
}

class RssContentLink
{
  String text;
  Uri url;

  RssContentLink({
    @required this.text,
    @required this.url,
  });
}