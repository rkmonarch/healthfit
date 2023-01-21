import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:interview/screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   bool _useDarkTheme = true;

   @override
  void initState() {
     var brightness = SchedulerBinding.instance.window.platformBrightness;
     print(">>>>>>>>>>>>>>>>>>>>>>>>>>>$brightness");
//  bool isDarkMode = brightness == Brightness.dark;
      // brightness = Theme.of(context).brightness;
    if (brightness == Brightness.light) {
      setState(() {
        _useDarkTheme = false;
      });
    } else if (brightness == Brightness.dark) {
     setState(() {
        _useDarkTheme = true;
    
     });
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {

    ThemeData myThemeLight = ThemeData(
      primaryColor: Colors.white,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    ThemeData myThemeDark = ThemeData(
      primaryColor: Colors.black,
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      theme: _useDarkTheme ? myThemeDark : myThemeLight, 
      home: SplashScreen(),
    );
  }
}
