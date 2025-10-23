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