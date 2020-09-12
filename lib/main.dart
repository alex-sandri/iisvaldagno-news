import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iisvaldagno_news/news.dart';
import 'package:iisvaldagno_news/news_list.dart';
import 'package:iisvaldagno_news/search.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();

  await Hive.openBox("favorites");

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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("it", "IT"),
      ],
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
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final QuickActions quickActions = QuickActions();

    quickActions.initialize((shortcutType) {
      String url;

      switch (shortcutType)
      {
        case "action_evidenza": url = "https://www.iisvaldagno.it/categorie/news"; break;
        case "action_evidenza_iti": url = "https://www.iisvaldagno.it/categorie/news/iti-news"; break;
        case "action_evidenza_ite": url = "https://www.iisvaldagno.it/categorie/news/ite-news"; break;
        case "action_evidenza_ip": url = "https://www.iisvaldagno.it/categorie/news/ip-news"; break;
      }

      url += "/page/{{PAGE}}/?feed=rss2";

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Home(url),
        ),
      );
    });

    quickActions.setShortcutItems([
      const ShortcutItem(type: "action_evidenza", localizedTitle: "Notizie in evidenza", icon: "ic_launcher"),
      const ShortcutItem(type: "action_evidenza_iti", localizedTitle: "In evidenza ITI", icon: "ic_launcher"),
      const ShortcutItem(type: "action_evidenza_ite", localizedTitle: "In evidenza ITE", icon: "ic_launcher"),
      const ShortcutItem(type: "action_evidenza_ip", localizedTitle: "In evidenza IP", icon: "ic_launcher"),
    ]);
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
            if (_currentIndex == 0)
              IconButton(
                icon: Icon(Icons.search),
                tooltip: "Cerca",
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: Search()
                  );
                },
              ),
          ],
        ),
        body: _currentIndex == 0
          ? NewsList(widget.url)
          : ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              itemCount: News.categories.length,
              itemBuilder: (context, index) {
                MapEntry<String, String> category = News.categories.entries.elementAt(index);

                return ListTile(
                  title: Text(category.key),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Home(category.value),
                      ),
                    );
                  },
                );
              },
            ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.rss_feed),
              title: Text("Feed"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              title: Text("Categorie"),
            ),
          ],
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}