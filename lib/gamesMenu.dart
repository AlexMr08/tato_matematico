import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/configColorAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/estadisticasAlumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2Screen.dart';
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
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha añadido un mapa de juegos
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
  late Map<String, Juego> listaJuegos;

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final navigator = Navigator.of(context);

    if (alumnoHolder.alumno == null || !alumnoHolder.areGamesLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    alumno = alumnoHolder.alumno!;
    listaJuegos = alumnoHolder.listaJuegos;

    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

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
      onEstadisticas: () {
        navegar(EstadisticasAlumno(), context);
      },
      child:
          alumnoHolder.areGamesLoaded &&
              alumnoHolder.listaJuegos["juego2"] != null
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: JuegoCard(
                            juego: listaJuegos["juego1"]!,
                            onTap: () {
                              navegar(Juego1Screen(), context);
                            },
                            color: alumno.colorBotones,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: JuegoCard(
                            juego: listaJuegos["juego2"]!,
                            onTap: () {
                              navegar(
                                Juego2Screen(
                                  juego: listaJuegos["juego2"]!,
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
                            juego: listaJuegos["juego3"]!,
                            onTap: () {
                              navegar(Placeholder(), context);
                            },
                            color: alumno.colorBotones,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: JuegoCard(
                            juego: listaJuegos["juego4"]!,
                            onTap: null,
                            color: alumno.colorBotones,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
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
