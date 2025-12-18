import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';

import '../juegos/tarjetaJuego.dart';

/// **Nombre de la Clase: `ConfigColorAlumno**
///
/// **Descripción:** clase que permite cambiar distintos colores de la interfaz de un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha hecho que funcione en movil
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
                  case "colorContenedor":
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
    alumnoHolder = context.watch<AlumnoHolder>();
    alumno = alumnoHolder.alumno!;

    PosicionBarra posBarra = switch (alumno.posicionBarra) {
      0 => PosicionBarra.arriba,
      1 => PosicionBarra.abajo,
      2 => PosicionBarra.izquierda,
      3 => PosicionBarra.derecha,
      _ => PosicionBarra.abajo,
    };

    MediaQueryData mediaQuery = MediaQuery.of(context);
    var esMovil = mediaQuery.size.width < 600;

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
      posicion: posBarra,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            spacing: 8,
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

              _colorTile(
                "colorSeleccion",
                "Color del botón seleccionado",
                alumno.colorSeleccion != null
                    ? alumno.colorSeleccion!
                    : Theme.of(context).colorScheme.tertiaryContainer,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              _colorTile(
                "colorContenedor",
                "Color de los contenedores",
                alumno.colorContenedor != null
                    ? alumno.colorContenedor!
                    : Theme.of(context).colorScheme.surfaceContainer,
                alumno.colorFondo != null
                    ? alumno.colorFondo!
                    : Theme.of(context).colorScheme.surface,
              ),
              Text(
                "Vista previa",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: getTextColorForBackground(
                    alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  Expanded(
                    child: BotonSinIconoAlumno(
                      texto: "Botón activado",
                      onPressed: () {},
                      colorFondo:
                          alumno.colorBotones ??
                          Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  Expanded(
                    child: BotonSinIconoAlumno(
                      texto: "Boton desactivado",
                      onPressed: null,
                      colorFondo:
                          alumno.colorBotones ??
                          Theme.of(context).colorScheme.primaryContainer,
                      colorDisabled:
                          alumno.colorFondo ??
                          Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        alumno.colorContenedor ??
                        Theme.of(context).colorScheme.surfaceContainer,
                    border: Border.all(
                      color: getTextColorForBackground(
                        alumno.colorFondo ??
                            Theme.of(context).colorScheme.surface,
                      ),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: 28,
                    runSpacing: 0,
                    children: [
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(0),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                            imagenes: false,
                            tipoImagen: "numeros",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(1),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorSeleccion ??
                                Theme.of(context).colorScheme.tertiaryContainer,
                            imagenes: true,
                            tipoImagen: "apple",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(2),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                            imagenes: true,
                            tipoImagen: "ball",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(0),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                            imagenes: true,
                            tipoImagen: "turtle",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(0),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                            imagenes: true,
                            tipoImagen: "car",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          TarjetaJuego(
                            key: ValueKey(0),
                            tamano: esMovil ? 65 : 140,
                            radio: 12,
                            label: "Contenedor vacío",
                            isButton: false,
                            isEnabled: false,
                            onTap: () {},
                            colorFondo:
                                alumno.colorBotones ??
                                Theme.of(context).colorScheme.primaryContainer,
                            imagenes: true,
                            tipoImagen: "flower",
                            numero: 2,
                          ),
                          Icon(
                            Icons.cancel,
                            color: getTextColorForBackground(
                              alumno.colorContenedor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainer,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
