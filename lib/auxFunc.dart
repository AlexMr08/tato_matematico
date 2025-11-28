import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Función de utilidad para el color del texto ---
Color getTextColorForBackground(Color backgroundColor) {
  return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Future<bool?> mostrarDialogoSiNoAlumno(
  BuildContext context,
  String titulo,
  String contenido,
) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(contenido),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        actionsAlignment:
            MainAxisAlignment.spaceEvenly, // Distribuye el espacio
        actions: <Widget>[
          // ----------------- BOTÓN NO -----------------
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(15),
            color: Colors.red.shade50,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/no.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "No",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ----------------- BOTÓN SI -----------------
          Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(15),
            color: Colors.green.shade50,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/si.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Si",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final orientation = MediaQuery.of(context).orientation;
  print('Tamaño: ${size.height}, Orientación: $orientation');

  // Tablet real: ancho grande incluso en vertical
  if (orientation == Orientation.portrait && size.width >= 600) return true;

  // En horizontal, evitamos confundir móvil rotado con tablet
  if (orientation == Orientation.landscape && size.height >= 600) return true;

  return false;
}

void navegar(Widget nuevo, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => nuevo),
  );
}

/// Devuelve true si el dispositivo es una tablet (umbral 600dp en el lado más corto).
/// Hecha con gpt-5 mini
bool isTabletV2() {
  // Requiere haber llamado antes a WidgetsFlutterBinding.ensureInitialized()
  final dispatcher = ui.PlatformDispatcher.instance;

  // Obtiene la primera vista disponible (compatible con multi‑view)
  final ui.FlutterView view =
  dispatcher.views.isNotEmpty ? dispatcher.views.first : (dispatcher.implicitView!);

  final double logicalWidth = view.physicalSize.width / view.devicePixelRatio;
  final double logicalHeight = view.physicalSize.height / view.devicePixelRatio;
  final double shortestSide = logicalWidth < logicalHeight ? logicalWidth : logicalHeight;

  return shortestSide >= 600.0;
}


extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
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

  // Consideramos que el curso empieza en Septiembre
  if (currentMonth >= 9) {
    return "${currentYear.toString().substring(2)}/${(currentYear + 1).toString().substring(2)}";
  } else {
    return "${(currentYear - 1).toString().substring(2)}/${currentYear.toString().substring(2)}";
  }
}

void snackBarError(BuildContext context, String mensaje){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.error,
    ),
  );
}

void snackBarExito(BuildContext context, String mensaje){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        mensaje,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primaryContainer,
    ),
  );
}
