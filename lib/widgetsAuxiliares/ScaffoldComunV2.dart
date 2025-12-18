import 'package:flutter/material.dart';

/// **Nombre de la Clase: `ScaffoldComunV2`**
///
/// **Descripción:** Clase que genera un Scaffold personalizado con AppBar y cuerpo definido por el usuario.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ScaffoldComunV2 extends StatelessWidget {
  final String titulo;
  final NavigationBar? navBar;
  final Widget cuerpo;
  final Widget? fab;
  final VoidCallback? funcionLeading;
  final Widget? header;
  final String? subtitulo;
  final IconData? iconoLeading;

  /// Constructor del ScaffoldComun
  /// @param key Clave del widget
  /// @param titulo Título de la pantalla
  /// @param cuerpo Cuerpo de la pantalla
  /// @returns ScaffoldComun widget
  const ScaffoldComunV2({
    super.key,
    required this.titulo,
    required this.cuerpo,
    this.navBar,
    this.fab,
    this.funcionLeading,
    this.header,
    this.subtitulo,
    this.iconoLeading,
  });

  /// Construye el widget Scaffold con AppBar y cuerpo personalizado
  /// @param context Contexto de la aplicación
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: iconoLeading != null
            ? InkWell(
                onTap: funcionLeading,
                child: Icon(
                  iconoLeading,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : null,
        title: Column(
          spacing: 4,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            ?subtitulo != null
                ? Text(
                    subtitulo!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : null,
          ],
        ),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 16))],
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      bottomNavigationBar: navBar,
      body: SafeArea(
        child: Column(
          children: [
            if (header != null) header!,
            Expanded(child: cuerpo),
          ],
        ),
      ),
      floatingActionButton: fab,
    );
  }
}
