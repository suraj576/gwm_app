import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groundwater_management/provider/locale_provider.dart';
import 'package:groundwater_management/screens/welcome.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());  // Remove 'new', add 'const'
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Add const constructor

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => LocaleProvider(),
    builder: (context, child) {
    final provider = Provider.of<LocaleProvider>(context);
  
    return MaterialApp(
        locale: provider.locale,
        supportedLocales: L10n.all,
        localizationsDelegates: const [  // Add const
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.purple,
          scaffoldBackgroundColor: Colors.white
        ),
        home: WelcomeScreen(),  // Add const
    );
    },
  ); 
}
