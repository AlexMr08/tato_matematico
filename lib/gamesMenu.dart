import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/alumnLogIn.dart';
import 'package:tato_matematico/auxFunc.dart';

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
      home: const GamesMenu(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GamesMenu extends StatefulWidget {
  const GamesMenu({super.key});
  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

class _GamesMenuState extends State<GamesMenu> {
  int selectedTab = 0;
  final List<Alumno> usuarios = [
    Alumno(id: 1, nombre: 'Ana', imagen: 'assets/user1.png'),
    Alumno(id: 2, nombre: 'Luis', imagen: 'assets/user2.png'),
    Alumno(id: 3, nombre: 'Marta', imagen: 'assets/user3.png'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? InkWell(child: const Icon(Icons.arrow_back), onTap: () => {Navigator.pop(context)}) : const Icon(Icons.menu),
        title: const Text('Label', style: TextStyle(fontSize: 20)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(Icons.access_time_filled, color: Colors.grey.shade400),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Alumnado'),
                selected: selectedTab == 0,
                onSelected: (_) => setState(() => selectedTab = 0),
                selectedColor: Colors.deepPurple.shade200,
                labelStyle: TextStyle(
                  color: selectedTab == 0 ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Profesorado'),
                selected: selectedTab == 1,
                onSelected: (_) => setState(() => selectedTab = 1),
                selectedColor: Colors.deepPurple.shade200,
                labelStyle: TextStyle(
                  color: selectedTab == 1 ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Expanded(
            child: selectedTab == 0
                ? AlumnLogIn()
                : const Center(child: Text('Profesorado Tab Content')),
          ),
        ],
      )),
    );
  }
}
