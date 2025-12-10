import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/configColorAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';
import 'package:tato_matematico/juegos/juego2/juego2Main.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'holders/alumnoHolder.dart';
import 'auxFunc.dart';
import 'datos/juego.dart';

/// **Nombre de la Clase: `GamesMenu**
///
/// **Descripción:** clase que muestra el menu principal del alumno
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 07/12/2025
/// * **Último cambio:** Se ha añadido el juego 2 correctamente
///

class GamesMenu extends StatefulWidget {
  const GamesMenu({super.key});
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
      nombre: 'Juego 1',
      min: 10,
      max: 20,
      cantidad: 5,
      usaImagenes: false,
      tipoImagenes: "",
    ),
    Juego2(
      min: 1,
      max: 20,
      cantidad: 12,
      ordenDescendente: true,
      usaImagenes: false,
      tipoImagenes: "",
    ),
    Juego(
      id: 'juego3',
      nombre: 'Juego 3',
      min: 10,
      max: 20,
      cantidad: 5,
      usaImagenes: false,
      tipoImagenes: "",
    ),
    Juego(
      id: 'juego4',
      nombre: 'Juego 4',
      min: 10,
      max: 20,
      cantidad: 5,
      usaImagenes: false,
      tipoImagenes: "",
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

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    if (alumnoHolder.isLoaded == false || alumnoHolder.juego2 == null) {
      return ScaffoldAlumno(
        alumno: alumno,
        posicion: posicionBarra,
        textoCabecera: "Menu principal",
        hasEstadisticas: true,
        hasAjustes: true,
        onVolver: () {},
        onAjustes: () {},
        onEstadisticas: () {},
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    listaJuegos[1] = alumnoHolder.juego2!;

    return ScaffoldAlumno(
      alumno: alumno,
      posicion: posicionBarra,
      textoCabecera: "Menu principal",
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
        navegar(ConfigColorAlumno(alum: alumno), context);
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
                    child: JuegoCard(
                      juego: listaJuegos[0],
                      onTap: () {
                        navegar(Juego1Screen(), context);
                      },
                      color: alumno.colorBotones,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: JuegoCard(
                      juego: alumnoHolder.juego2!,
                      onTap: () {
                        navegar(
                          Juego2Screen(
                            juego: alumnoHolder.juego2!,
                            alumno: alumno,
                          ),
                          context,
                        );
                      },
                      color: alumno.colorBotones,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: JuegoCard(
                      juego: listaJuegos[2],
                      onTap: () {
                        navegar(Placeholder(), context);
                      },
                      color: alumno.colorBotones,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: JuegoCard(
                      juego: listaJuegos[3],
                      onTap: () {
                        navegar(Placeholder(), context);
                      },
                      color: alumno.colorBotones,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
