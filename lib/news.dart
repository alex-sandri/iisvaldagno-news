import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html/parser.dart';
import 'package:iisvaldagno_news/favorites_manager.dart';
import 'package:iisvaldagno_news/main.dart';
import 'package:iisvaldagno_news/models/SerializableNews.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
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

  static const String _baseUrl = "https://www.iisvaldagno.it";

  static const String _urlSuffix = "/page/{{PAGE}}/?feed=rss2";

  static const Map<String, String> categories = {
    "Notizie in evidenza": "$_baseUrl/categorie/news/$_urlSuffix",
    "In evidenza ITI": "$_baseUrl/categorie/news/iti-news/$_urlSuffix",
    "In evidenza ITE": "$_baseUrl/categorie/news/ite-news/$_urlSuffix",
    "In evidenza IP": "$_baseUrl/categorie/news/ip-news/$_urlSuffix",
    "Bacheca esperienze e premi": "$_baseUrl/categorie/bacheca/$_urlSuffix",
    "Bacheca esperienze e premi ITI": "$_baseUrl/categorie/bacheca/iti-bacheca/$_urlSuffix",
    "Bacheca esperienze e premi ITE": "$_baseUrl/categorie/bacheca/ite-bacheca/$_urlSuffix",
    "Bacheca esperienze e premi IP": "$_baseUrl/categorie/bacheca/ip-bacheca/$_urlSuffix",
    // ITI
    "Chimica": "$_baseUrl/categorie/iti/iti-chimica/$_urlSuffix",
    "Elettronica": "$_baseUrl/categorie/iti/iti-elettronica/$_urlSuffix",
    "Informatica": "$_baseUrl/categorie/iti/iti-informatica/$_urlSuffix",
    "Meccanica e meccatronica": "$_baseUrl/categorie/iti/iti-meccanica/$_urlSuffix",
    "Moda": "$_baseUrl/categorie/iti/iti-moda/",
    // ITE
    "Amministrazione, finanza e marketing": "$_baseUrl/categorie/ite/ite-afm/$_urlSuffix",
    "Sistemi informativi": "$_baseUrl/categorie/ite/ite-sistemi-informativi/$_urlSuffix",
    "Turismo": "$_baseUrl/categorie/ite/ite-turismo/$_urlSuffix",
    // IP
    "Gestione delle acque": "$_baseUrl/categorie/ip/ip-gestione-acque/$_urlSuffix",
    "Manutenzione e assistenza tecnica": "$_baseUrl/categorie/ip/ip-manutenzione/$_urlSuffix",
    "Servizi per la Sanità e l’Assistenza Sociale": "$_baseUrl/categorie/ip/ip-socio-sanitario/$_urlSuffix",
  };

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  ScrollController _scrollController = ScrollController();

  double _opacity = 1;

  @override
  Widget build(BuildContext context) {
    final List<RssContentLink> links = [];

    final document = parse(widget.item.content.value);

    document.querySelectorAll("a").forEach((element) {
      // Remove download count
      element.querySelector("span.badge")?.remove();

      links.add(RssContentLink(
        text: element.text,
        url: Uri.parse(element.attributes["href"]),
      ));

      element.text = "[${element.text}](${element.attributes["href"]})";
    });

    document.querySelectorAll("ul > li").forEach((element) => element.text = " - ${element.text}");

    document.querySelectorAll("strong").forEach((element) =>
      element.text =
        element
        .text
        .split(".")
        .map((phrase) => phrase = phrase.trim().isEmpty ? "" : "**${phrase.trim()}**")
        .join(". ")
        .trim());

    document.querySelectorAll("em").forEach((element) =>
      element.text =
        element
        .text
        .split(".")
        .map((phrase) => phrase = phrase.trim().isEmpty ? "" : "*${phrase.trim()}*")
        .join(". ")
        .trim());

    document.querySelectorAll("p").forEach((element) => element.text += "\n\n");

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
                  text: "Link",
                  icon: Icon(Icons.link),
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
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: SelectableText("Autore"),
                              subtitle: SelectableText(widget.item.dc.creator),
                            ),
                            ListTile(
                              title: SelectableText("Pubblicato"),
                              subtitle: SelectableText(
                                DateFormat
                                  .yMMMMd(Localizations.localeOf(context).toLanguageTag())
                                  .add_jm()
                                  .format(
                                    DateFormat("E, dd MMM yyyy HH:mm:ss zzz")
                                      .parse(widget.item.pubDate)
                                      .add(Duration(hours: 2))
                                  ),
                              ),
                            ),
                            ListTile(
                              isThreeLine: true,
                              title: SelectableText("Link"),
                              subtitle: SelectableText(
                                widget.item.link,
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                                onTap: () async {
                                  if (await canLaunch(widget.item.link))
                                    await launch(widget.item.link);
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.share),
                tooltip: "Condividi",
                onPressed: () => Share.share(widget.item.link),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  setState(() {
                    if (_scrollController.position.userScrollDirection == ScrollDirection.forward)
                      _opacity = 1;
                    else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse)
                      _opacity = 0;
                  });

                  return true;
                },
                child: ListView(
                  controller: _scrollController,
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
                            String url = News.categories[category.value] ?? "https://www.iisvaldagno.it/tag/${category.value}/page/{{PAGE}}/?feed=rss2";

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Home(url),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),

                    if (widget.item.categories.isNotEmpty)
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
                    MarkdownBody(
                      data: document.body.text.trim(),
                      selectable: true,
                      onTapLink: (url) async {
                        if (await canLaunch(url)) await launch(url);
                      },
                    ),
                  ],
                ),
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
                        text: link.url.toString(),
                      ));

                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Link copiato negli appunti"),
                      ));
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(),
              ),
            ],
          ),
          floatingActionButton: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 100),
            child: Builder(
              builder: (context) {
                final bool isAlreadyInFavorites = FavoritesManager.getAll().contains(SerializableNews.fromRssItem(widget.item));

                return FloatingActionButton(
                  onPressed: () async {
                    isAlreadyInFavorites
                      ? await FavoritesManager.delete(SerializableNews.fromRssItem(widget.item))
                      : await FavoritesManager.add(SerializableNews.fromRssItem(widget.item));

                    Scaffold
                      .of(context)
                      .showSnackBar(SnackBar(content: Text("'${widget.item.title}' ${isAlreadyInFavorites ? "rimosso dai preferiti" : "aggiunto ai preferiti"}")));

                    setState(() {});
                  },
                  backgroundColor: isAlreadyInFavorites
                    ? Colors.pink
                    : null,
                  foregroundColor: isAlreadyInFavorites
                    ? Colors.white
                    : null,
                  tooltip: isAlreadyInFavorites
                    ? "Rimuovi dai preferiti"
                    : "Aggiungi ai preferiti",
                  child: Icon(
                    isAlreadyInFavorites
                      ? Icons.favorite
                      : Icons.favorite_border
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}