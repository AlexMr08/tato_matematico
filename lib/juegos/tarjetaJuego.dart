import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

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
        child: InkWell(
          onTap: onTap,
          child: Card(
            elevation: 4,
            color: colorFondo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: numero != null
                  ? Container(
                      padding: const EdgeInsets.all(8.0),
                      child: imagenes
                          ? Image.asset("assets/images/$numero$tipoImagen.png")
                          : AutoSizeText(
                              numero.toString(),
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
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
