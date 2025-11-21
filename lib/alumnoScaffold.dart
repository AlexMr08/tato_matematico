import 'package:flutter/material.dart';
import 'package:tato_matematico/alumno.dart';

enum PosicionBarra { arriba, abajo, izquierda, derecha }

class AlumnoScaffold extends StatelessWidget {
  final Widget child; // El juego en sí (el contenido central)
  final PosicionBarra posicion; // Dónde queremos la barra
  final Alumno alumno;

  // Callbacks para los botones
  final VoidCallback onVolver;
  final VoidCallback onAjustes;
  final VoidCallback onEstadisticas;
  final bool hasAjustes;
  final bool hasEstadisticas;

  const AlumnoScaffold({
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
    // 1. Construimos la barra de navegación
    final barra = _construirBarra(context);

    // 2. Decidimos el Layout según la posición
    Widget body;
    switch (posicion) {
      case PosicionBarra.arriba:
        body = Column(
          children: [
            barra,
            Expanded(child: child),
          ],
        );
        break;
      case PosicionBarra.abajo:
        body = Column(
          children: [
            Expanded(child: child),
            barra,
          ],
        );
        break;
      case PosicionBarra.izquierda:
        body = Row(
          children: [
            barra,
            Expanded(child: child),
          ],
        );
        break;
      case PosicionBarra.derecha:
        body = Row(
          children: [
            Expanded(child: child),
            barra,
          ],
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary,
        foregroundColor: alumno.colorBarraNav != null
            ? alumno.colorBarraNav!.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white
            : Theme.of(context).colorScheme.onPrimary,
        title: Text(alumno.nombre),
        centerTitle: true,
      ),
      backgroundColor:
          alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
      body: SafeArea(child: body),
    );
  }
  //Se han cambiado los botones con IA :)
  Widget _construirBarra(BuildContext context) {
    final bool esHorizontal =
        posicion == PosicionBarra.arriba || posicion == PosicionBarra.abajo;

    // Definimos la lista de widgets.
    final List<Widget> botones = [
      // 1. Botón Volver (Siempre presente)
      _BotonNav(
        icon: Icons.arrow_back,
        label: "Volver",
        onTap: onVolver,
        esHorizontal: esHorizontal,
        color: alumno.colorBarraNav,
      ),

      // 2. Botón Ajustes o Espacio vacío
      hasAjustes
          ? _BotonNav(
        icon: Icons.settings,
        label: "Ajustes",
        onTap: onAjustes,
        esHorizontal: esHorizontal,
        color: alumno.colorBarraNav,
      )
          : const SizedBox(), // <--- Relleno invisible

      // 3. Botón Estadísticas o Espacio vacío
      hasEstadisticas
          ? _BotonNav(
        icon: Icons.bar_chart,
        label: "Estadísticas",
        onTap: onEstadisticas,
        esHorizontal: esHorizontal,
        color: alumno.colorBarraNav,
      )
          : const SizedBox(), // <--- Relleno invisible
    ];

    return Container(
      width: esHorizontal ? double.infinity : 80,
      height: esHorizontal ? 80 : double.infinity,
      color: alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary,
      child: esHorizontal
          ? Row(
        // Al envolver el SizedBox en Expanded, actúa como un "Spacer"
        children: botones.map((b) => Expanded(child: b)).toList(),
      )
          : Column(
        children: botones.map((b) => Expanded(child: b)).toList(),
      ),
    );
  }
}

// Widget auxiliar para los botones (Icono + Texto)
class _BotonNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool esHorizontal;
  final Color? color;

  const _BotonNav({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.esHorizontal,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    Color colorTexto = color != null
        ? color!.computeLuminance() > 0.5
              ? Colors.black
              : Colors.white
        : Theme.of(context).colorScheme.onPrimary;

    return Material(
      // Agregamos Material para que el efecto visual se vea bien sobre el color
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        // No usamos borderRadius fijo para que llene el rectángulo del Expanded
        child: Container(
          alignment: Alignment
              .center, // <--- Centra el contenido en el espacio disponible
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // El contenido se mantiene compacto en el centro
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: colorTexto),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: colorTexto,
                ), // Reduje un poco la fuente para evitar desbordes
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
