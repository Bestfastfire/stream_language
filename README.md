# Stream Language
Check it out at [Pub.Dev](https://pub.dev/packages/stream_language)

A simple way to support your Flutter application, which from firebase with realtime database supports multiple languages!

![ezgif com-video-to-gif (1)](https://user-images.githubusercontent.com/22732544/65823906-9b68ee00-e235-11e9-989c-1c05a845b832.gif)

## Getting Started
You must first create an object with the following attributes:

    var language = LanguageBloc(
      child: 'languages',      
      defaultLanguage: 'pt_BR',
      defaultRoute: 'default'
    );
    
LanguageBloc is a singleton, after the first start, it will have the same attributes.

### Child:
The child in your realtime database that contains the app language.
In app example its likes this:

![Captura de Tela (101)](https://user-images.githubusercontent.com/22732544/65823660-d87eb180-e230-11e9-802f-0edb5a91f0f5.png)

Each child of this node must be named in the language and iso-code of the country as shown in the screenshot.

### DefaultLanguage
Here will be informed the default home language when connecting the language of the user device does not have in the database.

### DefaultRoute
Here you enter the node within the language that contains words that can be used on more than one screen as in the example below:

![Captura de Tela (102)](https://user-images.githubusercontent.com/22732544/65823703-b0438280-e231-11e9-846b-f94d1b6e1f10.png)

The first time you use firebase language you should do this:

    final language = LanguageBloc(
        child: 'languages',
        defaultLanguage: 'pt_BR',
        defaultRoute: 'default'
    );

    @override
    Widget build(BuildContext context) {
      return FirstLanguageStart(
        future: language.init(),
        builder: (c) => StreamLanguage(
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
            ),
          ),
        )
      );
    }

From the next you start using only the `StreamLanguage` widget, the first one is needed because the first app should download all language and start the default language from the user's mobile language.

## Widget StreamLanguage

### ScreenRoute
This is where the magic happens, as a parameter it receives the screen route within the language node, see that in the code above is as:
`screenRoute: ['screen-1']`, in firebase it looks like this:

![Captura de Tela (103)](https://user-images.githubusercontent.com/22732544/65823751-d74e8400-e232-11e9-8930-998e642da9f5.png)

If the route were a node within 'screen-1' you would go something like this: `screenRoute: ['screen-1', 'route_inside']`

### Builder
The builder receives as parameter 3 fields: **data**, **route** and **def**

#### Data
Data contains all node of current language.

#### Route
Contains all node passed by ScreenRoute.

#### Def
Contains all node passed as parameter in **LanguageBlo**c constructor in **DefaultRoute**

# Changing Language
For this, every language node must have a child named config with the following attributes:
![Captura de Tela (104)](https://user-images.githubusercontent.com/22732544/65823821-c5211580-e233-11e9-8df3-666120569cbf.png)

After that you can call the method:

    language.showAlertChangeLanguage(
        context: context,
        title: def['change-language']['title'],
        btnNegative: def['change-language']['btn-negative']
    )

This will show an alert dialog like this (Language and flag listing is done automatically from the data passed in the **config** node):

![Captura de Tela (105)](https://user-images.githubusercontent.com/22732544/65823835-116c5580-e234-11e9-8e4c-059f2fc163c7.png)

To change the language programmatically, just call this method passing as the language prefix ex:

    languageBloc.changeLanguage('pt_BR');

## Help Maintenance

I've been maintaining quite many repos these days and burning out slowly. If you could help me cheer up, buying me a cup of coffee will make my life really happy and get much energy out of it.

<a href="https://www.buymeacoffee.com/RtrHv1C" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: auto !important;width: auto !important;" ></a>