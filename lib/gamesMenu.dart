import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/alumno.dart';
import 'alumnoHolder.dart';
import 'auxFunc.dart';
import 'juego.dart';
import 'colorPicker.dart';

class GamesMenu extends StatefulWidget {
  GamesMenu({super.key});
  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

class _GamesMenuState extends State<GamesMenu> {
  late Alumno alumno;
  late final List<Juego> listaJuegos = [
    Juego(
      id: 'juego1',
      actividad: Placeholder(),
      nombre: 'Juego 1',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego2',
      actividad: Placeholder(),
      nombre: 'Juego 2',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego3',
      actividad: Placeholder(),
      nombre: 'Juego 3',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego4',
      actividad: Placeholder(),
      nombre: 'Juego 4',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'estadisticas',
      actividad: Placeholder(),
      nombre: 'estadisticas',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'volver',
      actividad: Placeholder(),
      nombre: 'volver',
      color: Theme.of(context).colorScheme.primaryContainer,
      icono: Icon(
        Icons.arrow_back,
        size: 64,
        color: Color.fromARGB(255, 50, 50, 60),
      ),
    ),
  ];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!context.watch<AlumnoHolder>().hasAlumno){
      Navigator.pop(context);
    }
    alumno = context.watch<AlumnoHolder>().alumno!;
    if (kDebugMode) {
      print(alumno);
    }
    Color colorTextoSup = alumno.colorPrincipal != null
        ? alumno.colorPrincipal!.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white
        : Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
      backgroundColor: alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? InkWell(
                child: Icon(Icons.arrow_back, color: colorTextoSup),
                onTap: () => {Navigator.pop(context)},
              )
            : Icon(Icons.menu, color: colorTextoSup),
        title: Column(
          children: [
            Text(
              'Seleccion de juego',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(alumno.nombre, style: TextStyle(fontSize: 16)),
          ],
        ),
        centerTitle: true,
        backgroundColor: alumno.colorPrincipal ?? Theme.of(context).colorScheme.primary,
        titleTextStyle: TextStyle(color: colorTextoSup),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[0].widgetJuego(context, () {
                        navegar(listaJuegos[0].actividad, context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[1].widgetJuego(context, () {
                        navegar(listaJuegos[1].actividad, context);
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[2].widgetJuego(context, () {
                        navegar(listaJuegos[2].actividad, context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[3].widgetJuego(context, () {
                        navegar(listaJuegos[3].actividad, context);
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[4].widgetJuego(context, () {
                        navegar(ColorPickerExample(), context);
                      }),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[5].widgetJuego(context, () {
                        Navigator.canPop(context)
                            ? Navigator.pop(context)
                            : navegar(ColorPickerExample(), context);
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
