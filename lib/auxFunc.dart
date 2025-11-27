import 'dart:ui' as ui;
import 'package:flutter/material.dart';

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