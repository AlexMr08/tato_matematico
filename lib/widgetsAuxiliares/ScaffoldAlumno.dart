import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- Importante para SystemUiOverlayStyle
import 'package:flutter_svg/svg.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';

enum PosicionBarra { arriba, abajo, izquierda, derecha }

/// **Nombre de la Clase: `AlumnoScaffold`**
///
/// **Descripción:** Clase que genera el Scaffold común para las pantallas del alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Cambio en el boton para permitir svg y icon
///

class ScaffoldAlumno extends StatefulWidget {
  final Widget child;
  final PosicionBarra posicion;
  final Alumno alumno;
  final String textoCabecera;
  final VoidCallback onVolver;
  final VoidCallback onAjustes;
  final VoidCallback onEstadisticas;
  final bool hasAjustes;
  final bool hasEstadisticas;

  const ScaffoldAlumno({
    super.key,
    required this.child,
    required this.posicion,
    required this.alumno,
    required this.textoCabecera,
    required this.onVolver,
    required this.onAjustes,
    required this.onEstadisticas,
    required this.hasAjustes,
    required this.hasEstadisticas,
  });

  @override
  State<ScaffoldAlumno> createState() => _ScaffoldAlumnoState();
}

class _ScaffoldAlumnoState extends State<ScaffoldAlumno> {
  @override
  Widget build(BuildContext context) {
    var posicionFinal = widget.posicion;
    if (MediaQuery.of(context).size.width < 600) {
      posicionFinal = PosicionBarra.arriba;
    }

    final barra = _construirBarra(context, posicionFinal);

    Widget body;
    switch (posicionFinal) {
      case PosicionBarra.arriba:
        body = Column(
          children: [
            barra,
            Expanded(child: widget.child),
          ],
        );
        break;
      case PosicionBarra.abajo:
        body = Column(
          children: [
            Expanded(child: widget.child),
            barra,
          ],
        );
        break;
      case PosicionBarra.izquierda:
        body = Row(
          children: [
            barra,
            Expanded(child: widget.child),
          ],
        );
        break;
      case PosicionBarra.derecha:
        body = Row(
          children: [
            Expanded(child: widget.child),
            barra,
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            widget.alumno.colorBarraNav ??
            Theme.of(context).colorScheme.primary,
        foregroundColor: getTextColorForBackground(
          widget.alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          widget.textoCabecera,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor:
          widget.alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          widget.onVolver();
        },
        child: SafeArea(child: body),
      ),
    );
  }

  Widget _construirBarra(BuildContext context, PosicionBarra posicionActual) {
    final bool esHorizontal =
        posicionActual == PosicionBarra.arriba ||
        posicionActual == PosicionBarra.abajo;

    final Color navColor =
        widget.alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;

    final List<Widget> botones = [
      _BotonNav(
        svgPath: "assets/icons/undo.svg",
        label: "Volver",
        onTap: widget.onVolver,
        color: navColor,
      ),
      widget.hasAjustes
          ? _BotonNav(
              icon: Icons.settings,
              label: "Ajustes",
              onTap: widget.onAjustes,
              color: navColor,
            )
          : const SizedBox(),
      widget.hasEstadisticas
          ? _BotonNav(
              icon: Icons.bar_chart,
              label: "Estadísticas",
              onTap: widget.onEstadisticas,
              color: navColor,
            )
          : const SizedBox(),
    ];

    return Container(
      // Si es horizontal, ancho infinito. Si es vertical, ancho fijo (100).
      // Si es horizontal, alto fijo (90). Si es vertical, alto infinito.
      width: esHorizontal ? double.infinity : 100,
      height: esHorizontal ? 90 : double.infinity,
      color: navColor,
      child: esHorizontal
          ? Row(children: botones.map((b) => Expanded(child: b)).toList())
          : Column(children: botones.map((b) => Expanded(child: b)).toList()),
    );
  }
}

class _BotonNav extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String label; // <--- Este campo es obligatorio
  final VoidCallback onTap;
  final Color? color;

  const _BotonNav({
    super.key,
    this.icon,
    this.svgPath,
    required this.label, // Requerimos el label aquí
    required this.onTap,
    this.color,
  }) : assert(
         icon != null || svgPath != null,
         'Debes proporcionar un icon o un svgPath',
       );

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    final Color contentColor = getTextColorForBackground(effectiveColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (svgPath != null)
                SvgPicture.asset(
                  svgPath!,
                  width: 36,
                  height: 36,
                  colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
                  semanticsLabel: label, // Usa el label para accesibilidad
                )
              else
                Icon(icon, color: contentColor, size: 36),

              const SizedBox(height: 4),

              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: contentColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
