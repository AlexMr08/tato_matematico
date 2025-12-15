import 'package:flutter/material.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';

enum PosicionBarra { arriba, abajo, izquierda, derecha }

class ScaffoldAlumno extends StatelessWidget {
  final Widget child;
  final PosicionBarra posicion;
  final Alumno alumno;
  final String textoCabecera;
  final VoidCallback onVolver;
  final VoidCallback onAjustes;
  final VoidCallback onEstadisticas;
  final bool hasAjustes;
  final bool hasEstadisticas;
  final Widget? floatingActionButton; // Nuevo parámetro

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
    this.floatingActionButton, // Añadido al constructor
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

    final Color appBarColor =
        alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appBarColor,
        foregroundColor: getTextColorForBackground(appBarColor),
        title: Text(
          textoCabecera,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor:
          alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) return;
          onVolver();
        },
        child: SafeArea(child: body),
      ),
      floatingActionButton: floatingActionButton, // Usar el nuevo parámetro aquí
    );
  }

  Widget _construirBarra(BuildContext context) {
    final bool esHorizontal =
        posicion == PosicionBarra.arriba || posicion == PosicionBarra.abajo;

    final Color navColor =
        alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;

    final List<Widget> botones = [
      _BotonNav(
        icon: Icons.arrow_back,
        label: "Volver",
        onTap: onVolver,
        color: navColor,
      ),
      if (hasAjustes)
        _BotonNav(
          icon: Icons.settings,
          label: "Ajustes",
          onTap: onAjustes,
          color: navColor,
        ),
      if (hasEstadisticas)
        _BotonNav(
          icon: Icons.bar_chart,
          label: "Estadísticas",
          onTap: onEstadisticas,
          color: navColor,
        ),
    ];

    return Container(
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
