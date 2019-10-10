library stream_language;

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class StreamLanguage extends StatelessWidget {
  final Function onChange;
  final List<String> screenRoute;
  final languageBloc = LanguageBloc();
  final Widget Function(dynamic data, dynamic route, dynamic def) builder;

  StreamLanguage({@required this.builder, this.screenRoute = const [], this.onChange}){
   if(onChange != null){
     languageBloc.outStreamList.listen((v) => onChange());
   }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: languageBloc.currentValue,
      stream: languageBloc.outStreamList,
      builder: (context, snapshot) {
        dynamic screenRoute = snapshot.data;
        this.screenRoute.forEach((v) => screenRoute = screenRoute[v]);
        return builder(
            snapshot.data,
            screenRoute,
            languageBloc.defaultRoute != null
                ? snapshot.data[languageBloc.defaultRoute]
                : []);
      },
    );
  }
}

class LanguageBloc implements BlocBase {
  String lastPrefix;
  final String child;
  final String defaultRoute;
  final String defaultLanguage;
  final BehaviorSubject<Map<dynamic, dynamic>> _languageDb =
      BehaviorSubject<Map<dynamic, dynamic>>();
  final BehaviorSubject<Map<dynamic, dynamic>> _languageList =
      BehaviorSubject<Map<dynamic, dynamic>>();

  Stream<dynamic> get outStreamList => _languageList.stream;
  Map<dynamic, dynamic> get currentValue => _languageList.value;
  Map<dynamic, dynamic> get currentDef =>
      defaultRoute != null ? currentValue[defaultRoute] : [];

  static LanguageBloc _instance;
  factory LanguageBloc({child, defaultLanguage, initialPrefix, defaultRoute}) {
    _instance ??= LanguageBloc._internal(
        child: child,
        defaultLanguage: defaultLanguage,
        lastPrefix: initialPrefix,
        defaultRoute: defaultRoute);
    return _instance;
  }

  LanguageBloc._internal(
      {this.child, this.defaultLanguage, this.lastPrefix, this.defaultRoute});

  Future<void> init() async {
    this.lastPrefix ??= defaultLanguage;
    _languageDb.sink.add(
        (await FirebaseDatabase.instance.reference().child(child).once())
            .value);

    FirebaseDatabase.instance
        .reference()
        .child(child)
        .onValue
        .listen((v) => _languageDb.sink.add(v.snapshot.value));
    _languageDb.listen((v) => _languageList.sink.add(v[lastPrefix]));

    await _setDeviceLanguage();
  }

  Future<LanguageBloc> _setDeviceLanguage() async {
    await changeLanguage(await Devicelocale.currentLocale);
    return this;
  }

  Future<void> changeLanguage(String prefix) async {
    if (_languageDb.value[prefix] == null) {
      prefix = this.defaultLanguage;
      print(
          'setting prefix with defaultLanguage because prefix: $prefix dont exists in database!');
    }

    if (this.lastPrefix != (prefix)) {
      this.lastPrefix = prefix;
      _languageList.sink.add(_languageDb.value[this.lastPrefix]);
      print('language inited with prefix: $prefix');
    } else {
      print(
          'language dont changed because informed prefix is the same as current prefix: $prefix');
    }
  }

  List<Map<dynamic, dynamic>> getListLanguage() {
    List<Map<dynamic, dynamic>> out = [];
    _languageDb.value.forEach((k, v) {
      out.add({
        'prefix': k,
        'iso-code': v['config']['iso-code'],
        'title': v['config']['title']
      });
    });

    return out;
  }

  Future<dynamic> showAlertChangeLanguage(
      {@required context,
      @required String title,
      @required String btnNegative}) async {
    List<Map<dynamic, dynamic>> out = this.getListLanguage();

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              actions: <Widget>[
                FlatButton(
                  child: Text(btnNegative),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
              content: Container(
                width: MediaQuery.of(context).size.height * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                child: ListView.builder(
                  itemCount: out.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Material(
                      color: currentValue['config']['prefix'] ==
                              out[index]['prefix']
                          ? Colors.blueAccent[700]
                          : Colors.transparent,
                      child: ListTile(
                        leading: CountryPickerUtils.getDefaultFlagImage(
                            Country(isoCode: out[index]['iso-code'])),
                        selected: currentValue['config']['prefix'] ==
                            out[index]['prefix'],
                        title: Text(
                          out[index]['title'].toString(),
                          style: TextStyle(
                              color: currentValue['config']['prefix'] ==
                                      out[index]['prefix']
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        onTap: () {
                          changeLanguage(out[index]['prefix']);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
            ));
  }

  @override
  void dispose() {
    _languageList.close();
    _languageDb.close();
  }

  @override
  void addListener(listener) {}

  @override
  bool get hasListeners => null;

  @override
  void notifyListeners() {}

  @override
  void removeListener(listener) {}
}

class FirstLanguageStart extends StatelessWidget {
  final future;
  final Widget loadWidget;
  final Function(BuildContext context) builder;
  FirstLanguageStart(
      {@required this.future, @required this.builder, this.loadWidget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder(context);
        }
        return loadWidget ?? CircularProgressIndicator();
      },
    );
  }
}
