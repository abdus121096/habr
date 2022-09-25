import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webfeed/webfeed.dart';
import 'package:habr/common/fetch_http.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:habr/screen/read_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenRSS extends StatefulWidget {
  @override
  _HomeScreenRSSState createState() => _HomeScreenRSSState();
}

class _HomeScreenRSSState extends State {
  bool _darkTheme = false;
  final List _habsList = [];

  @override
  void initState() {
    super.initState();
    _setTheme();
  }

  _setTheme() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      if(_prefs.getBool('darkTheme') != null) {
        _darkTheme = _prefs.getBool('darkTheme')!;
      } else {
        _darkTheme = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: !_darkTheme ? ThemeData.light() : ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Habr RSS'),
          actions: [
            Icon(_getAppBarIcon()),
            CupertinoSwitch(
                value: _darkTheme,
                onChanged: (bool value) {
                  setState(() {
                    _darkTheme = !_darkTheme;
                  });
                })
          ],
        ),
        body: FutureBuilder(
          future: _getHttpHabs(),
          builder: (context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Container(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    left: 10.0, top: 10.0, right: 10.0, bottom: 10.0
                  ),
                    scrollDirection: Axis.vertical,
                    itemCount: _habsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0
                          ),
                          child: Column(
                            children: [
                              Text('${_habsList[index].title}',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Text('${parseDescription(_habsList[index].description)}',
                              style: const TextStyle(fontSize: 16.0),),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat('dd.mm.yyyy kk:mm').format(
                                    DateTime.parse(
                                      '${_habsList[index].pubDate}'
                                    )
                                  )),
                                  FloatingActionButton.extended(
                                      heroTag: null,
                                      onPressed: () =>
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => ReadScreen(urlHab: '${_habsList[index].guid}',))),
                                  label: Text('Читать'),
                                    icon: Icon(Icons.arrow_forward),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }
                ),
              );
            }
          },
        ),
      ),
    );
  }

  _getAppBarIcon() {
    if (_darkTheme) {
      return Icons.highlight;
    } else {
      return Icons.lightbulb_outline;
    }
  }


  _getHttpHabs() async {
    final url = Uri.parse('https://habr.com/ru/rss/hubs/all/');
    final response = await http.get(url);
    final chanel = RssFeed.parse(response.body);
    chanel.items?.forEach((element) {
      _habsList.add(element);
    });

    return _habsList;
  }



}
