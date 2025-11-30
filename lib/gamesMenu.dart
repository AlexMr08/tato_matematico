import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/alumnoScaffold.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'holders/alumnoHolder.dart';
import 'auxFunc.dart';
import 'juego.dart';
import 'colorPicker.dart';

class GamesMenu extends StatefulWidget {
  GamesMenu({super.key});
  @override
  State<GamesMenu> createState() => _GamesMenuState();
}

/*
  Se han hecho pruebas unitarias para asegurar que funciona correctamente:
  - De momento, al pulsar en los juegos no lleva a nada (no estan implementados)
  - Al pulsar volver, sale la interfaz de confirmar la accion
  - Si en la interfaz de confirmar salir pulsas que no, no cierra sesion
  - Si en la interfaz de confirmar salir pulsas que si, cierra sesion
  - Si se pulsa ajustes, se accede directamente a los ajustes de colores
   */

class _GamesMenuState extends State<GamesMenu> {
  late Alumno alumno;
  late final List<Juego> listaJuegos = [
    Juego(
      id: 'juego1',
      actividad: const Juego1Screen(),
      nombre: 'Juego 1',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego2',
      actividad: const Placeholder(),
      nombre: 'Juego 2',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego3',
      actividad: const Placeholder(),
      nombre: 'Juego 3',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
    Juego(
      id: 'juego4',
      actividad: const Placeholder(),
      nombre: 'Juego 4',
      color: Theme.of(context).colorScheme.primaryContainer,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    if (alumnoHolder.alumno == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigator.canPop()) navigator.pop();
      });
      return const SizedBox.shrink();
    }
    alumno = alumnoHolder.alumno!;

    PosicionBarra posicionBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        mostrarDialogoSiNoAlumnoV2(context, "Salir", "¿Seguro que quieres salir?").then((
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

          final currentFocus = FocusScope.of(context).focusedChild;

          mostrarDialogoSiNoAlumnoV2(
            context,
            "Salir",
            "¿Seguro que quieres salir?",
          ).then((confirmed) {

            if (confirmed != true && currentFocus != null) {
              currentFocus.requestFocus();
            }

            salirFunc(confirmed, alumnoHolder, navigator);
          });
        },
        onAjustes: () {
          navegar(ConfigColor(alum: alumno), context);
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: listaJuegos[1].widgetJuego(context, () {
                        navegar(listaJuegos[1].actividad, context);
                      }, alumno.colorBotones),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: listaJuegos[2].widgetJuego(context, () {
                        navegar(listaJuegos[2].actividad, context);
                      }, alumno.colorBotones),
                    ),
                    const SizedBox(width: 16),
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
