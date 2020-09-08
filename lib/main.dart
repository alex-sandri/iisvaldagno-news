import 'package:flutter/material.dart';
import 'package:iisvaldagno_news/news_list.dart';
import 'package:iisvaldagno_news/search.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quick_actions/quick_actions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final QuickActions quickActions = QuickActions();

  quickActions.initialize((shortcutType) {
    print(shortcutType);
  });

  quickActions.setShortcutItems([
    const ShortcutItem(type: "action_evidenza", localizedTitle: "Notizie in evidenza"),
    const ShortcutItem(type: "action_evidenza_iti", localizedTitle: "In evidenza ITI"),
    const ShortcutItem(type: "action_evidenza_ite", localizedTitle: "In evidenza ITE"),
    const ShortcutItem(type: "action_evidenza_ip", localizedTitle: "In evidenza IP"),
  ]);

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
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "IIS Valdagno News",
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              tooltip: "Cerca",
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: Search()
                );
              },
            )
          ],
        ),
        body: NewsList(),
      ),
    );
  }
}