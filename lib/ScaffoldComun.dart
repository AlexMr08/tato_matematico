import 'package:flutter/material.dart';

/// Widget que crea un Scaffold personalizado para las pantallas comunes

class ScaffoldComun extends StatelessWidget {
  final String titulo;
  final NavigationBar? navBar;
  final Widget cuerpo;
  final Widget? fab;
  final VoidCallback? funcionSalir;
  final Widget? header;
  final String? subtitulo;

  /// Constructor del ScaffoldComun
  /// @param key Clave del widget
  /// @param titulo Título de la pantalla
  /// @param cuerpo Cuerpo de la pantalla
  /// @returns ScaffoldComun widget
  const ScaffoldComun({
    super.key,
    required this.titulo,
    required this.cuerpo,
    this.navBar,
    this.fab,
    this.funcionSalir,
    this.header,
    this.subtitulo,
  });

  /// Construye el widget Scaffold con AppBar y cuerpo personalizado
  /// @param context Contexto de la aplicación
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: funcionSalir,
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
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
