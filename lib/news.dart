import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/services.dart';
import 'package:html/parser.dart';
import 'package:iisvaldagno_news/main.dart';
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
            actions: [
              IconButton(
                icon: Icon(Icons.open_in_new),
                tooltip: "Apri nel browser",
                onPressed: () async {
                  if (await canLaunch(widget.item.link))
                    await launch(widget.item.link);
                },
              ),
              IconButton(
                icon: Icon(Icons.info_outline),
                tooltip: "Informazioni",
                onPressed: () async {
                  // TODO
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                tooltip: "Condividi",
                onPressed: () async {
                  // TODO
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              ListView(
                padding: EdgeInsets.all(8),
                children: [
                  Wrap(
                    spacing: 4,
                    children: widget.item.categories.map((category) {
                      Color chipColor;

                      switch (category.value)
                      {
                        case "Notizie in evidenza": chipColor = Color(0xff013777); break;
                        case "In evidenza ITI": chipColor = Color(0xffa6d514); break;
                        case "In evidenza ITE": chipColor = Color(0xffff9100); break;
                        case "In evidenza IP": chipColor = Color(0xff1f8ebf); break;
                      }

                      return ActionChip(
                        backgroundColor: chipColor,
                        label: Text(
                          category.value,
                        ),
                        labelStyle: chipColor != null
                          ? TextStyle(
                              backgroundColor: chipColor,
                            )
                          : null,
                        onPressed: () {
                          String url;

                          switch (category.value)
                          {
                            case "Notizie in evidenza": url = "https://www.iisvaldagno.it/categorie/news"; break;
                            case "In evidenza ITI": url = "https://www.iisvaldagno.it/categorie/news/iti-news"; break;
                            case "In evidenza ITE": url = "https://www.iisvaldagno.it/categorie/news/ite-news"; break;
                            case "In evidenza IP": url = "https://www.iisvaldagno.it/categorie/news/ip-news"; break;
                            default: url = "https://www.iisvaldagno.it/tag/${category.value}"; break;
                          }

                          url += "/page/{{PAGE}}/?feed=rss2";

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Home(url),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SelectableText(
                    widget.item.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  SelectableText(
                    document.querySelector("p").text,
                  ),
                ],
              ),
              ListView.separated(
                itemCount: links.isNotEmpty
                  ? links.length
                  : 1,
                itemBuilder: (context, index) {
                  if (links.isEmpty)
                    return Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        "Non sono presenti allegati",
                        textAlign: TextAlign.center,
                      ),
                    );

                  final RssContentLink link = links[index];

                  return ListTile(
                    title: Text(
                      link.text,
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      if (await canLaunch(link.url.toString()))
                        await launch(link.url.toString());
                    },
                    onLongPress: () async {
                      await Clipboard.setData(ClipboardData(
                        text: link.text,
                      ));

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Testo copiato negli appunti"),
                      ));
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}