import 'package:flutter/material.dart';

/// Widget que crea un Scaffold personalizado para las pantallas comunes

class ScaffoldComun extends StatelessWidget {
  final String titulo;
  final Widget cuerpo;

  /// Constructor del ScaffoldComun
  /// @param key Clave del widget
  /// @param titulo Título de la pantalla
  /// @param cuerpo Cuerpo de la pantalla
  const ScaffoldComun({super.key, required this.titulo, required this.cuerpo});

  /// Construye el widget Scaffold con AppBar y cuerpo personalizado
  /// @param context Contexto de la aplicación
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context) ? InkWell(child: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary,), onTap: () => {Navigator.pop(context)}) : const Icon(Icons.menu),
        title: Text(titulo, style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.w500,
        ),),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: SafeArea(child: Column(
        children: [
          cuerpo
        ],
      )),
    );
  }
}