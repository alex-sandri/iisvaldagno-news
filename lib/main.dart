import 'package:dart_rss/dart_rss.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:iisvaldagno_news/favorites_manager.dart';
import 'package:iisvaldagno_news/models/SerializableNews.dart';
import 'package:iisvaldagno_news/news.dart';
import 'package:iisvaldagno_news/news_list.dart';
import 'package:iisvaldagno_news/news_list_tile.dart';
import 'package:iisvaldagno_news/search.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart' as wm;

Future<void> checkForNewNews() async {
  final http.Response response = await http.get("https://www.iisvaldagno.it/?feed=rss2");

  final RssFeed feed = RssFeed.parse(response.body);

  final List<RssItem> items = feed.items;

  await Hive.initFlutter();

  await Hive.openBox("miscellaneous");

  final String previousLatestNewsUrl = Hive.box("miscellaneous").get("previousLatestNewsUrl");

  if (previousLatestNewsUrl != null && items[0].link != previousLatestNewsUrl)
  {
    await FlutterLocalNotificationsPlugin().show(0, "Notizie", "Ci sono nuove notizie da leggere", NotificationDetails(
      AndroidNotificationDetails(
        "0",
        "Notizie",
        "Notizie",
      ),
      IOSNotificationDetails(),
    ));
  }

  await Hive.box("miscellaneous").put("previousLatestNewsUrl", items[0].link);
}

void callbackDispatcher() async {
  wm.Workmanager.executeTask((task, inputData) async {
    await checkForNewNews();

    return true;
  });
}

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(SerializableNewsAdapter());

  await FavoritesManager.initialize();

  await Hive.openBox("miscellaneous");

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final InitializationSettings initializationSettings = InitializationSettings(
    AndroidInitializationSettings("app_icon"),
    IOSInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) => null,
  );

  wm.Workmanager.initialize(callbackDispatcher);

  wm.Workmanager.registerPeriodicTask(
    "fetchNews",
    "fetchNews",
    frequency: Duration(minutes: 15),
    constraints: wm.Constraints(
      networkType: wm.NetworkType.connected,
    ),
  );

  checkForNewNews();

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
        body: Builder(
          builder: (context) {
            Widget body;

            switch (_currentIndex)
            {
              case 0: body = NewsList(widget.url); break;
              case 1:
                body = ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: News.categories.length,
                  itemBuilder: (context, index) {
                    final MapEntry<String, String> category = News.categories.entries.elementAt(index);

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
                );
                break;
              case 2:
                body = ListView.separated(
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: FavoritesManager.getAll().isNotEmpty
                    ? FavoritesManager.getAll().length
                    : 1,
                  itemBuilder: (context, index) {
                    if (FavoritesManager.getAll().isEmpty)
                      return SelectableText(
                        "Non hai ancora aggiunto nulla ai preferiti",
                        textAlign: TextAlign.center,
                      );

                    final SerializableNews news = FavoritesManager.getAll()[index];

                    return Dismissible(
                      key: ValueKey(news),
                      onDismissed: (direction) async {
                        await FavoritesManager.delete(news);

                        setState(() {});
                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      child: NewsListTile(news.toRssItem()),
                    );
                  },
                );
                break;
            }

            return body;
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
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              title: Text("Preferiti"),
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