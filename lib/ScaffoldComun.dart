import 'package:flutter/material.dart';
import 'package:tato_matematico/fab.dart';

/// Widget que crea un Scaffold personalizado para las pantallas comunes

class ScaffoldComun extends StatelessWidget {
  final String titulo;
  final NavigationBar? navBar;
  final Widget cuerpo;
  final Widget? fab;
  final VoidCallback? funcionSalir;

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
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 16))],
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      bottomNavigationBar: navBar,
      body: SafeArea(child: cuerpo),
      floatingActionButton: fab,
    );
  }
}
