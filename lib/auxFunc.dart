import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';

/// **Nombre de la Clase: `auxFunc`**
///
/// **Descripción:** Archivo con funciones que tienen distintas funcionalidades.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Gonzalo Alganza Luque
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se han hecho cambios de calidad
///

// --- Función de utilidad para el color del texto ---
Color getTextColorForBackground(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

String obtenerSemana() {
  DateTime now = DateTime.now();

  DateTime lunes = now.subtract(Duration(days: now.weekday - 1));

  String f(int n) => n.toString().padLeft(2, '0');
  String inicio = "${(lunes.year)}-${f(lunes.month)}-${f(lunes.day)}";

  return inicio;
}

PosicionBarra getPosicionBarra(int? numBarra) {
  PosicionBarra posicionBarra = switch (numBarra) {
    0 => PosicionBarra.arriba,
    1 => PosicionBarra.abajo,
    2 => PosicionBarra.izquierda,
    3 => PosicionBarra.derecha,
    _ => PosicionBarra.abajo,
  };
  return posicionBarra;
}

///
/// @name mostrarDialogosSiNoAlumnoV2
///
/// @param context El contexto de la aplicación.
/// @param titulo El título del diálogo.
/// @param contenido El contenido del diálogo.
/// @description Muestra un diálogo de confirmación con dos opciones: "Sí" y "No".
/// Nos hemos apoyado en gemini para hacerla responsiva
///

Future<bool?> mostrarDialogoSiNoAlumnoV2(
  BuildContext context,
  String titulo,
  String contenido,
) async {
  Widget botonDialogo({
    required VoidCallback onTap,
    required Color colorBoton,
    required String iconPath,
    required String label,
    required double iconSize,
    required double textSize,
    required double padding,
  }) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(20),
      color: colorBoton,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: textSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Cerrar",
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Detectamos si es móvil
              bool esMovil = constraints.maxWidth < 600;

              // Ajustamos tamaños proporcionalmente
              double sizeIcono = esMovil ? 80 : 120.0;
              double sizeTitulo = 32.0;
              double sizeTexto = 24.0;
              double sizeBotonTexto = 28.0;

              // CAMBIO 1: Reducimos ligeramente el padding interno en móvil (de 16 a 12)
              double paddingBoton = esMovil ? 12.0 : 24.0;

              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: sizeTitulo,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Contenido
                      Text(
                        contenido,
                        style: TextStyle(fontSize: sizeTexto),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: esMovil ? 30 : 60),

                      // Fila de botones adaptables
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ----------------- BOTÓN NO -----------------
                          botonDialogo(
                            onTap: () => Navigator.of(context).pop(false),
                            colorBoton: Colors.red.shade50,
                            iconPath: 'assets/images/no.png',
                            label: "No",
                            iconSize: sizeIcono,
                            textSize: sizeBotonTexto,
                            padding: paddingBoton,
                          ),

                          // ----------------- BOTÓN SI -----------------
                          botonDialogo(
                            onTap: () => Navigator.of(context).pop(true),
                            colorBoton: Colors.green.shade50,
                            iconPath: 'assets/images/si.png',
                            label: "Si",
                            iconSize: sizeIcono,
                            textSize: sizeBotonTexto,
                            padding: paddingBoton,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _botonDialogo({
  required BuildContext context,
  required VoidCallback onTap,
  required Color colorBoton,
  required Color textColor,
  required String iconPath,
  required String label,
  required double iconSize,
  required double textSize,
  required double padding,
}) {
  return Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(20),
    color: colorBoton,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              color: textColor,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSize,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool?> mostrarDialogoSalirReiniciarAlumnoV2(
  BuildContext context,
  String titulo,
  String contenido,
  Color fondo,
  Color boton,
) async {
  var textFondo = getTextColorForBackground(fondo);
  var textBoton = getTextColorForBackground(boton);

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Cerrar",
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: fondo,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool esMovil = constraints.maxWidth < 600;
                double sizeIcono = esMovil ? 60.0 : 120.0;
                double sizeTitulo = esMovil ? 24.0 : 32.0;
                double sizeTexto = esMovil ? 18.0 : 24.0;
                double sizeBotonTexto = esMovil ? 18.0 : 28.0;
                double paddingBoton = esMovil ? 16.0 : 24.0;
                double sizeEmoji = esMovil ? 40.0 : 64.0;

                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "🥳🥳Lo has conseguido🥳🥳",
                            style: TextStyle(
                              fontSize: sizeEmoji,
                              fontWeight: FontWeight.bold,
                              color: getTextColorForBackground(fondo),
                            ),
                          ),
                          Text(
                            titulo,
                            style: TextStyle(
                              fontSize: sizeTitulo,
                              fontWeight: FontWeight.bold,
                              color: textFondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            contenido,
                            style: TextStyle(
                              fontSize: sizeTexto,
                              color: textFondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: esMovil ? 16 : 24),
                          Row(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _botonDialogo(
                                  context: context,
                                  onTap: () => Navigator.of(context).pop(false),
                                  colorBoton: boton,
                                  textColor: textBoton,
                                  iconPath: 'assets/images/boton_volver.png',
                                  label: "Volver al menú",
                                  iconSize: sizeIcono,
                                  textSize: sizeBotonTexto,
                                  padding: paddingBoton,
                                ),
                              ),

                              // ----------------- BOTÓN REINICIAR -----------------
                              Expanded(
                                child: _botonDialogo(
                                  context: context,
                                  onTap: () => Navigator.of(context).pop(true),
                                  colorBoton: boton,
                                  textColor: textBoton,
                                  iconPath: 'assets/images/de_nuevo2.png',
                                  label: "Empezar de nuevo",
                                  iconSize: sizeIcono,
                                  textSize: sizeBotonTexto,
                                  padding: paddingBoton,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<bool?> mostrarDialogoSiguienteAlumnoV2(
  BuildContext context,
  String titulo,
  String contenido,
  Color fondo,
  Color boton,
) async {
  var textFondo = getTextColorForBackground(fondo);
  var textBoton = getTextColorForBackground(boton);

  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Cerrar",
    barrierColor: Colors.black54,
    pageBuilder: (context, animation, secondaryAnimation) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: fondo,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool esMovil = constraints.maxWidth < 600;

                double sizeIcono = esMovil ? 60.0 : 120.0;
                double sizeTitulo = esMovil ? 24.0 : 32.0;
                double sizeTexto = esMovil ? 18.0 : 24.0;
                double sizeBotonTexto = esMovil ? 18.0 : 28.0;
                double paddingBoton = esMovil ? 16.0 : 24.0;
                double sizeEmoji = esMovil ? 40.0 : 64.0;

                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize:
                            MainAxisSize.min, // Importante para el scroll
                        children: [
                          Text(
                            "🥳🥳Ya estás mas cerca🥳🥳",
                            style: TextStyle(
                              fontSize: sizeEmoji,
                              fontWeight: FontWeight.bold,
                              color: getTextColorForBackground(fondo),
                            ),
                          ),
                          Text(
                            titulo,
                            style: TextStyle(
                              fontSize: sizeTitulo,
                              fontWeight: FontWeight.bold,
                              color: textFondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            contenido,
                            style: TextStyle(
                              fontSize: sizeTexto,
                              color: textFondo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: esMovil ? 16 : 24),
                          Row(
                            spacing: 16,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: _botonDialogo(
                                  context: context,
                                  onTap: () => Navigator.of(context).pop(false),
                                  colorBoton: boton,
                                  textColor: textBoton,
                                  iconPath: 'assets/images/boton_volver.png',
                                  label: "Volver al menú",
                                  iconSize: sizeIcono,
                                  textSize: sizeBotonTexto,
                                  padding: paddingBoton,
                                ),
                              ),
                              Expanded(
                                child: _botonDialogo(
                                  context: context,
                                  onTap: () => Navigator.of(context).pop(true),
                                  colorBoton: boton,
                                  textColor: textBoton,
                                  iconPath: 'assets/images/siguiente.png',
                                  label: "Siguiente",
                                  iconSize: sizeIcono,
                                  textSize: sizeBotonTexto,
                                  padding: paddingBoton,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

void navegar(Widget nuevo, BuildContext context) {
  Navigator.push(context, MaterialPageRoute<void>(builder: (context) => nuevo));
}

/// Devuelve true si el dispositivo es una tablet (umbral 600dp en el lado más corto).
/// Hecha con gpt-5 mini
bool isTabletV2() {
  // Requiere haber llamado antes a WidgetsFlutterBinding.ensureInitialized()
  final dispatcher = ui.PlatformDispatcher.instance;

  // Obtiene la primera vista disponible (compatible con multi‑view)
  final ui.FlutterView view = dispatcher.views.isNotEmpty
      ? dispatcher.views.first
      : (dispatcher.implicitView!);

  final double logicalWidth = view.physicalSize.width / view.devicePixelRatio;
  final double logicalHeight = view.physicalSize.height / view.devicePixelRatio;
  final double shortestSide = logicalWidth < logicalHeight
      ? logicalWidth
      : logicalHeight;

  return shortestSide >= 600.0;
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

List<String> generarListaAnos() {
  int currentYear = DateTime.now().year;
  List<String> lista = [];
  // Generar años desde el anterior hasta 3 años en el futuro
  for (int i = -1; i < 3; i++) {
    int y = currentYear + i;
    lista.add(
      "${y.toString().substring(2)}/${(y + 1).toString().substring(2)}",
    );
  }
  return lista;
}

String obtenerAnoAcademico() {
  final now = DateTime.now();
  final int currentYear = now.year;
  final int currentMonth = now.month;
  String anoAcademico;

  // Consideramos que el curso empieza en Septiembre
  if (currentMonth >= 9) {
    anoAcademico =
        "${currentYear.toString().substring(2)}/${(currentYear + 1).toString().substring(2)}";
  } else {
    anoAcademico =
        "${(currentYear - 1).toString().substring(2)}/${currentYear.toString().substring(2)}";
  }

  return anoAcademico;
}

void snackBarError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje,
        style: TextStyle(color: Theme.of(context).colorScheme.onError),
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

void snackBarExito(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    ),
  );
}

void snackBarAviso(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
}
