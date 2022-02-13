library stream_language;

import 'package:firebase_database/firebase_database.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class StreamLanguage extends StatelessWidget {
  /// On change language
  final Function? onChange;

  /// route in json, ex:
  /// {
  ///   "a" : {
  ///     "b" : "value"
  ///   }
  /// }
  ///
  /// to get only "b" I pass: ['a', 'b']
  final List<String> screenRoute;

  /// Controller
  final control = LanguageController(defaultPrefix: '', child: '');

  /// Builder widget
  final Widget Function(dynamic data, dynamic route, dynamic def) builder;

  StreamLanguage(
      {required this.builder, this.screenRoute = const [], this.onChange}) {
    if (onChange != null) {
      control.outStreamList.listen((v) => onChange!());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: control.currentValue,
      stream: control.outStreamList,
      builder: (context, snapshot) {
        dynamic screenRoute = snapshot.data as dynamic;
        this.screenRoute.forEach((v) => screenRoute = screenRoute[v]);

        return builder(
            snapshot.data,
            screenRoute,
            control.commonRoute != null
                ? (snapshot.data as dynamic)[control.commonRoute]
                : []);
      },
    );
  }
}

abstract class _BlocBase {
  void dispose();
}

class LanguageController implements _BlocBase {
  /// Last prefix selected
  String? lastPrefix;

  /// Child in RT Database
  final String child;

  /// Route common in to screens
  final String? commonRoute;

  /// Default prefix
  final String defaultPrefix;

  final BehaviorSubject<Map<dynamic, dynamic>> _languageDb =
      BehaviorSubject<Map<dynamic, dynamic>>();

  final BehaviorSubject<Map<dynamic, dynamic>> _languageList =
      BehaviorSubject<Map<dynamic, dynamic>>();

  /// Stream of languages
  Stream<dynamic> get outStreamList => _languageList.stream;

  /// Current selected language
  Map<dynamic, dynamic> get currentValue => _languageList.value;

  /// Current common
  Map<dynamic, dynamic> get currentCommon =>
      commonRoute != null ? currentValue[commonRoute] : [];

  static LanguageController? _instance;
  factory LanguageController(
      {required String child,
      required String defaultPrefix,
      String? initialPrefix,
      String? commonRoute}) {
    return _instance ??= LanguageController._internal(
        child: child,
        defaultPrefix: defaultPrefix,
        lastPrefix: initialPrefix ?? defaultPrefix,
        commonRoute: commonRoute);
  }

  LanguageController._internal(
      {required this.child,
      required this.defaultPrefix,
      this.lastPrefix,
      this.commonRoute});

  /// Required called before all to load
  Future<void> init() async {
    this.lastPrefix ??= defaultPrefix;
    _languageDb.sink.add(
        (await FirebaseDatabase.instance.ref().child(child).once())
            .snapshot
            .value as dynamic);

    FirebaseDatabase.instance
        .ref()
        .child(child)
        .onValue
        .listen((v) => _languageDb.sink.add(v.snapshot.value as dynamic));
    _languageDb.listen((v) => _languageList.sink.add(v[lastPrefix]));

    await _setDeviceLanguage();
  }

  Future<LanguageController> _setDeviceLanguage() async {
    if (kIsWeb)
      await changeLanguage(defaultPrefix);
    else
      await changeLanguage(await Devicelocale.currentLocale ?? defaultPrefix);

    return this;
  }

  /// Change current language passing prefix ex: [changeLanguage('en_US')]
  Future<void> changeLanguage(String prefix) async {
    if (_languageDb.value[prefix] == null) {
      prefix = this.defaultPrefix;
      print(
          'setting prefix with defaultLanguage because prefix: $prefix dont exists in database!');
    }

    if (this.lastPrefix != (prefix)) {
      this.lastPrefix = prefix;
      _languageList.sink.add(_languageDb.value[this.lastPrefix]);
      print('language inited with prefix: $prefix');
    } else {
      print(
          'language don\'t changed because informed prefix is the same as current prefix: $prefix');
    }
  }

  /// Get list of languages in route "config" inside jsons
  List<Map<dynamic, dynamic>> getListLanguage() {
    List<Map<dynamic, dynamic>> out = [];
    _languageDb.value.forEach((k, v) {
      out.add({
        'prefix': k,
        'iso_code': v['config']['iso_code'],
        'title': v['config']['title']
      });
    });

    return out;
  }

  /// Show alert to change language
  Future<dynamic> showAlertChangeLanguage(
      {required BuildContext context,
      required String title,
      required String btnNegative}) async {
    List<Map<dynamic, dynamic>> out = this.getListLanguage();

    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(btnNegative)),
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
                            CountryPickerUtils.getCountryByIsoCode(
                                out[index]['iso_code'])),
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
}

class FirstLanguageStart extends StatelessWidget {
  /// Controller
  final LanguageController control;

  /// Widget to show while init
  final Widget? loadWidget;

  /// Widget builder
  final Function(BuildContext context) builder;

  FirstLanguageStart(
      {required this.control, required this.builder, this.loadWidget});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: control.init(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return builder(context);
          }

          return loadWidget ?? CircularProgressIndicator();
        });
  }
}
