import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/configColorAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/juegos/juego2/juego2Main.dart';
import 'package:tato_matematico/juegos/juego3/juego3.dart';
import 'package:tato_matematico/juegos/juego3/juego3Main.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'holders/alumnoHolder.dart';
import 'auxFunc.dart';
import 'datos/juego.dart';


/// **Nombre de la Clase: `GamesMenu**
///
/// **Descripción:** clase que permite cambiar distintos colores de la interfaz de un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha cambiado la ruta de los ajustes
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
    Juego2(1, 10, 8, true, "", true),
    Juego3(1, 10, 3, false, "", 2),
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

    PosicionBarra posicionBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

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
                      juego: listaJuegos[1],
                      onTap: () {
                        navegar(
                          Juego2Screen(juego: listaJuegos[1], alumno: alumno),
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
                        navegar(
                          Juego3Screen(juego: listaJuegos[2], alumno: alumno),
                          context,
                        );
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
