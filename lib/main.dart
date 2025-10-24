import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tato_matematico/login/alumnLogIn.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'alumno.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

void initializeFirebaseDatabase() {
  FirebaseDatabase database = FirebaseDatabase.instance;
  database.setPersistenceEnabled(true);
  database.setPersistenceCacheSizeBytes(10000000); // 10 MB
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    bool tablet = isTablet(context);
    SystemChrome.setPreferredOrientations(tablet ? [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight] : [DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'Tato Aventuras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Alumno> _alumnos = [];

  @override
  void initState() {
    super.initState();
    _loadAlumnos().whenComplete(
      () => debugPrint('Usuarios cargados: ${_alumnos}'),
    );
  }

  /*
  * Hecha por ChatGPT
  * */

  Future<List<Alumno>> _loadAlumnos() async {
    final snapshot = await _dbRef.child("tato").child("alumnos").get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data.entries.map((entry) {
          final alumnoData = Map<dynamic, dynamic>.from(entry.value);
          return Alumno.fromMap(entry.key, alumnoData);
        }).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Alumno>>(future: _loadAlumnos(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text('No hay alumnos'));
      }

      final alumnos = snapshot.data!;
      return AlumnLogIn(alumnos: alumnos);
    });
  }
}
