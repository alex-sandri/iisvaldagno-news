import 'package:flutter/material.dart';
import 'package:dart_rss/dart_rss.dart';
import 'package:http/http.dart' as http;

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

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "IIS Valdagno News",
          ),
        ),
        body: FutureBuilder(
          future: http.get("https://www.iisvaldagno.it/page/$_page/?s=&feed=rss2"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();

            final http.Response response = snapshot.data;

            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                return ListTile(

                );
              },
            );
          },
        ),
      ),
    );
  }
}