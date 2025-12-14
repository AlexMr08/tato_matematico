import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/juegos/juego2/juego2Ajustes.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

import 'juegos/juego2/juego2.dart';

/// **Nombre de la Clase: `ConfigColorAlumno**
///
/// **Descripción:** clase que permite cambiar distintos colores de la interfaz de un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha cambiado el boton
///

class ConfigColorAlumno extends StatefulWidget {
  final Alumno? alum;

  @override
  ConfigColorAlumnoState createState() => ConfigColorAlumnoState();

  const ConfigColorAlumno({super.key, this.alum});
}

class ConfigColorAlumnoState extends State<ConfigColorAlumno> {
  late AlumnoHolder alumnoHolder;
  @override
  void initState() {
    super.initState();
  }

  void _showColorPicker(String ref, String cadena, Color color) {
    Color pickerColor = color;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cadena),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() => pickerColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () {
              var dbref = FirebaseDatabase.instance.ref();
              dbref
                  .child("tato")
                  .child("alumnos")
                  .child(alumnoHolder.alumno!.id)
                  .update({ref: pickerColor.toHex(leadingHashSign: false)});
              setState(() {
                switch (ref) {
                  case "colorFondo":
                    alumnoHolder.setColorFondo(pickerColor);
                    break;
                  case "colorBarraNav":
                    alumnoHolder.setBarraNav(pickerColor);
                    break;
                  case "colorBotones":
                    alumnoHolder.setColorBotones(pickerColor);
                    break;
                  case "colorSeleccion":
                    alumnoHolder.setColorSeleccion(pickerColor);
                    break;
                  default:
                    break;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _colorTile(String ref, String label, Color color, Color background) {
    var colorTexto = getTextColorForBackground(background);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: colorTexto)),
        InkWell(
          onTap: () => _showColorPicker(ref, label, color),
          child: Container(
            width: 128,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: colorTexto, width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Alumno alumno;
    alumnoHolder = context.read<AlumnoHolder>();
    alumno = alumnoHolder.alumno!;
    Map<String, Juego> listaJuegos = alumnoHolder.listaJuegos;

    PosicionBarra posicionBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Ajustes de color",
      hasAjustes: false,
      hasEstadisticas: false,
      onAjustes: () {},
      onEstadisticas: () {},
      onVolver: () {
        Navigator.pop(context);
      },
      posicion: posicionBarra,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              _colorTile(
                "colorFondo",
                "Color de fondo",
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              SizedBox(height: 8),
              _colorTile(
                "colorBarraNav",
                "Color de la barra de navegacion",
                alumno.colorBarraNav != null
                    ? alumno.colorBarraNav!
                    : Theme.of(context).colorScheme.primary,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              SizedBox(height: 8),
              _colorTile(
                "colorBotones",
                "Color de los botones",
                alumno.colorBotones != null
                    ? alumno.colorBotones!
                    : Theme.of(context).colorScheme.primaryContainer,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              SizedBox(height: 8),
              _colorTile(
                "colorSeleccion",
                "Color del boton seleccionado",
                alumno.colorSeleccion != null
                    ? alumno.colorSeleccion!
                    : Theme.of(context).colorScheme.onPrimaryContainer,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              BotonSinIconoAlumno(
                texto: "AJUSTES JUEGO 2",
                onPressed: alumno.permisoAjustesJuego2
                    ? () {
                        navegar(
                          Juego2Ajustes(
                            juego:
                                listaJuegos["juego2"]!,
                          ),
                          context,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
