import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../auxFunc.dart';

/// **Nombre de la Clase: `TarjetaJuego`**
///
/// **Descripción:** Clase que muestra los botones de los juegos.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 05/12/2025
/// * **Último cambio:** Se ha creado la clase
///
/// /// @param label El texto que se mostrará en la tarjeta.
/// @param isButton Indica si la tarjeta es un botón.
/// @param isEnabled Indica si la tarjeta está habilitada.
/// @param onTap La acción a realizar cuando se toca la tarjeta.
/// @param colorFondo El color de fondo de la tarjeta.
/// @param imagenes Indica si se mostrarán imágenes.
/// @param tipoImagen El tipo de imagen a mostrar.
/// @param numero El número que se mostrará en la tarjeta.
/// @param tamano El tamaño de la tarjeta.
/// @param radio El radio de las esquinas de la tarjeta.

class TarjetaJuego extends StatelessWidget {
  final String label;
  final bool isButton;
  final bool isEnabled;
  final VoidCallback onTap;
  final Color colorFondo;
  final bool imagenes;
  final String tipoImagen;
  final int? numero;
  final double tamano;
  final double radio;

  const TarjetaJuego({
    super.key,
    required this.label,
    required this.isButton,
    required this.isEnabled,
    required this.onTap,
    required this.colorFondo,
    required this.imagenes,
    required this.tipoImagen,
    required this.numero,
    required this.tamano,
    required this.radio,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tamano,
      height: tamano,
      child: Semantics(
        label: label,
        button: isButton,
        enabled: isEnabled,
        excludeSemantics: true,
        child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            color: colorFondo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radio),
            ),
            child: InkWell(
              onTap: isEnabled? onTap : null,
              borderRadius: BorderRadius.circular(radio),
              child: Center(
              child: numero != null
                  ? Container(
                      padding: const EdgeInsets.all(4.0),
                      child: imagenes
                          ? Image.asset("assets/images/$numero$tipoImagen.png")
                          : AutoSizeText(
                              numero.toString(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: getTextColorForBackground(colorFondo)
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
