import 'package:flutter/material.dart';
import 'package:stream_language/stream_language.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final language = LanguageBloc(
      child: 'languages',
      defaultLanguage: 'pt_BR',
      defaultRoute: 'default'
  );

  @override
  Widget build(BuildContext context) {
    return FirstLanguageStart(
      future: language.init(),
      builder: (c){
        return StreamLanguage(
          screenRoute: ['screen-1'],
          builder: (data, route, def) => Scaffold(
            appBar: AppBar(
              title: Text(route['title']),
            ),
            body: Center(
              child: RaisedButton(
                  child: Text(route['btn']),
                  onPressed: () => language.showAlertChangeLanguage(
                      context: context,
                      title: def['change-language']['title'],
                      btnNegative: def['change-language']['btn-negative']
                  )
              ),
            ), // This trailing comma makes auto-formatting nicer for build methods.
          ),
        );
      },
    );
  }
}