import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/colorPicker.dart';

import 'alumno.dart';
import 'fab.dart';

class PruebaProfe extends StatefulWidget {
  const PruebaProfe({super.key});
  @override
  State<PruebaProfe> createState() => _PruebaProfeState();
}

class _PruebaProfeState extends State<PruebaProfe> {
  int currentPageIndex = 0;
  bool esDirector = true;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Future<List<Alumno>>? _futureAlumnos;

  @override
  initState() {
    super.initState();
    _futureAlumnos = _loadAlumnos();
  }

  Future<List<Alumno>> _loadAlumnos() async {
    final snapshot = await _dbRef.child("tato").child("alumnos").get();
    if (!snapshot.exists) return [];

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    final tempDir = await getTemporaryDirectory();

    final List<Alumno> alumnos = [];
    for (final entry in data.entries) {
      final alumnoData = Map<dynamic, dynamic>.from(entry.value);
      final alumno = Alumno.fromMap(entry.key, alumnoData);
      await alumno.descargarImagen(tempDir);
      print('Alumno cargado: $alumno');
      alumnos.add(alumno);
    }
    return alumnos;
  }

  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return ScaffoldComun(
      titulo: "Panel de profesor",
      fab: Visibility(
          visible: esDirector && currentPageIndex != 2,
          child: M3FabMenu(
        actions: [
          M3FabAction(
            icon: Icons.account_circle,
            label: 'Añadir alumno',
            onPressed: () {},
          ),
          M3FabAction(
            icon: Icons.supervisor_account_rounded,
            label: 'Añadir profesor',
            onPressed: () {},
          ),
        ],
        direction: FabDirection.up,
        showLabels: true,
      )),
      navBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: esDirector
            ? <Widget>[
                const NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Alumnos',
                ),
                const NavigationDestination(
                  icon: const Icon(Icons.notifications_sharp),
                  label: 'Profesores',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.messenger_sharp),
                  label: 'Perfil',
                ),
              ]
            : <Widget>[
                const NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Alumnos',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.messenger_sharp),
                  label: 'Perfil',
                ),
              ],
      ),
      cuerpo: <Widget>[
        /// Alumnos page

        FutureBuilder(
          future: _futureAlumnos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay alumnos'));
            }
            final alumnos = snapshot.data!;
            final double fabOverlapPadding = 88.0 + MediaQuery.of(context).padding.bottom;

            return ListView.builder(
              reverse: false,
              padding: EdgeInsets.only(bottom: fabOverlapPadding, top: 8),
              itemCount: alumnos.length,
              itemBuilder: (BuildContext context, int index) {
                return alumnos[index].widgetProfesor(context, () {
                  context.read<AlumnoHolder>().setAlumno(alumnos[index]);
                  navegar(ConfigColor(), context);});
              },
            );
          },
        ),

        /// Profesores page
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text('Home page', style: theme.textTheme.titleLarge),
            ),
          ),
        ),

        /// Perfil page
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),

      ][currentPageIndex],
    );
  }
}
