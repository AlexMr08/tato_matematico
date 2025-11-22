import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/alumnoScaffold.dart';
import 'holders/alumnoHolder.dart';
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
  ];

  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    //Seccion hecha con chatgpt
    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) navigator.pop();
      });
      return const SizedBox.shrink();
    }
    //Fin seccion hecha con chatgpt
    alumno = alumnoHolder.alumno!;

    if (kDebugMode) {
      print(alumno);
    }

    PosicionBarra posicionBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    //PopScope hecho con chatgpt, el resto no
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return; // Ya se hizo pop automáticamente, no hacemos nada

        // Mostrar el diálogo de confirmación
        mostrarDialogoSiNoAlumno(context, "Salir", "¿Seguro que salir?").then((
          confirmed,
        ) {
          salirFunc(confirmed, alumnoHolder, navigator);
        });
      },
      child: AlumnoScaffold(
        alumno: alumno,
        posicion: posicionBarra,
        hasEstadisticas: true,
        hasAjustes: true,
        onVolver: () {
          mostrarDialogoSiNoAlumno(
            context,
            "Salir",
            "¿Seguro que quieres salir?",
          ).then((confirmed) {
            salirFunc(confirmed, alumnoHolder, navigator);
          });
        },
        onAjustes: () {
          navegar(ConfigColor(), context);
        },
        onEstadisticas: () {},
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
                      }, alumno.colorBotones),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[1].widgetJuego(context, () {
                        navegar(listaJuegos[1].actividad, context);
                      }, alumno.colorBotones),
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
                      }, alumno.colorBotones),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[3].widgetJuego(context, () {
                        navegar(listaJuegos[3].actividad, context);
                      }, alumno.colorBotones),
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

void salirFunc(
  bool? confirmed,
  AlumnoHolder alumnoHolder,
  NavigatorState navigator,
) {
  if (confirmed == true) {
    alumnoHolder.clear();
    navigator.pop();
  }
}
