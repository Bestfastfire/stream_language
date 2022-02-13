import 'package:stream_language/stream_language.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final language = LanguageController(
      child: 'languages', defaultPrefix: 'pt_BR', commonRoute: 'default');

  @override
  Widget build(BuildContext context) {
    return FirstLanguageStart(
        control: language,
        builder: (c) {
          return StreamLanguage(
              screenRoute: ['screen-1'],
              builder: (data, route, def) => Scaffold(
                  appBar: AppBar(title: Text(route['title'])),
                  body: Center(
                      child: ElevatedButton(
                          child: Text(route['btn']),
                          onPressed: () => language.showAlertChangeLanguage(
                              context: context,
                              title: def['change-language']['title'],
                              btnNegative: def['change-language'][
                                  'btn-negative']))) // This trailing comma makes auto-formatting nicer for build methods.
                  ));
        });
  }
}
