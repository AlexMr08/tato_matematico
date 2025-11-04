import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tato_matematico/login/alumnLogIn.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tato_matematico/theme.dart';

import 'holders/alumnoHolder.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import 'holders/profesorHolder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AlumnoHolder(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfesorHolder(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

FirebaseDatabase initializeFirebaseDatabase() {
  FirebaseDatabase database = FirebaseDatabase.instance;
  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(10000000); // 10 MB
  return database;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    bool tablet = isTablet(context);
    SystemChrome.setPreferredOrientations(
      tablet
          ? [
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : [DeviceOrientation.portraitUp],
    );

    final ThemeData appTheme = MaterialTheme(
      ThemeData.light().textTheme,
    ).light();

    return MaterialApp(
      title: 'Tato Aventuras',
      theme: appTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlumnLogIn();
  }
}
