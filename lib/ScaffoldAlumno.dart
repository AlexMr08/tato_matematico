import 'package:flutter/material.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';

enum PosicionBarra { arriba, abajo, izquierda, derecha }

/// **Nombre de la Clase: `AlumnoScaffold`**
///
/// **Descripción:** Clase que genera el Scaffold común para las pantallas del alumno,
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ScaffoldAlumno extends StatelessWidget {
  final Widget child;
  final PosicionBarra posicion;
  final Alumno alumno;
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
    required this.onVolver,
    required this.onAjustes,
    required this.onEstadisticas,
    required this.hasAjustes,
    required this.hasEstadisticas,
  });

  @override
  Widget build(BuildContext context) {
    final barra = _construirBarra(context);

    Widget body;
    switch (posicion) {
      case PosicionBarra.arriba:
        body = Column(children: [barra, Expanded(child: child)]);
        break;
      case PosicionBarra.abajo:
        body = Column(children: [Expanded(child: child), barra]);
        break;
      case PosicionBarra.izquierda:
        body = Row(children: [barra, Expanded(child: child)]);
        break;
      case PosicionBarra.derecha:
        body = Row(children: [Expanded(child: child), barra]);
        break;
    }

    final Color appBarColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        foregroundColor: getTextColorForBackground(appBarColor),
        title: Text(alumno.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
      body: SafeArea(child: body),
    );
  }

  Widget _construirBarra(BuildContext context) {
    final bool esHorizontal =
        posicion == PosicionBarra.arriba || posicion == PosicionBarra.abajo;

    final Color navColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;

    final List<Widget> botones = [
      //if (alumno.volverDerecha == false)
        _BotonNav(
          icon: Icons.arrow_back,
          label: "Volver",
          onTap: onVolver,
          color: navColor,
        ),
      hasAjustes ?
        _BotonNav(
          icon: Icons.settings,
          label: "Ajustes",
          onTap: onAjustes,
          color: navColor,
        ): SizedBox(),
      hasEstadisticas ?
        _BotonNav(
          icon: Icons.bar_chart,
          label: "Estadísticas",
          onTap: onEstadisticas,
          color: navColor,
        ): SizedBox(),
      /*if (alumno.volverDerecha == true)
       _BotonNav(
          icon: Icons.arrow_back,
          label: "Volver",
          onTap: onVolver,
          color: navColor,
        ),
       */
    ];

    return Container(
      width: esHorizontal ? double.infinity : 100, // Barra lateral más ancha
      height: esHorizontal ? 90 : double.infinity, // Barra horizontal más alta
      color: navColor,
      child: esHorizontal
          ? Row(children: botones.map((b) => Expanded(child: b)).toList())
          : Column(children: botones.map((b) => Expanded(child: b)).toList()),
    );
  }
}

class _BotonNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BotonNav({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

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
              Icon(icon, color: contentColor, size: 36), // Icono más grande
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16, // Texto más grande
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
