import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

typedef ImagenLoader = Future<File?> Function(Directory tempDir);

/// **Nombre de la Clase: `FotoPerfil`**
///
/// **Descripción:** Clase que permite mostrar una foto de perfil circular.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class FotoPerfil extends StatefulWidget {
  final String nombre;
  final String idUnico;
  final ImagenLoader? onObtenerImagen;
  final double radio;

  const FotoPerfil({
    super.key,
    required this.nombre,
    required this.idUnico,
    this.onObtenerImagen,
    this.radio = 40,
  });

  @override
  State<FotoPerfil> createState() => _FotoPerfilState();
}

class _FotoPerfilState extends State<FotoPerfil> {
  File? _imagen;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarImagen();
  }

  // Detectamos cambios basándonos en el ID único (puede ser la URL de la imagen o el ID del usuario)
  @override
  void didUpdateWidget(covariant FotoPerfil oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia el ID o el nombre, intentamos recargar
    if (oldWidget.idUnico != widget.idUnico ||
        oldWidget.nombre != widget.nombre) {
      _cargarImagen();
    }
  }

  Future<void> _cargarImagen() async {
    // Si no nos pasan función de carga, no hacemos nada
    if (widget.onObtenerImagen == null) {
      if (mounted) {
        setState(() {
          _cargando = false;
          _imagen = null;
        });
      }
      return;
    }

    try {
      // Volvemos a poner cargando si estamos cambiando de perfil
      if (mounted) setState(() => _cargando = true);

      final tempDir = await getTemporaryDirectory();

      // EJECUTAMOS LA FUNCIÓN EXTERNA pasándole el directorio
      final archivo = await widget.onObtenerImagen!(tempDir);

      if (mounted) {
        setState(() {
          _imagen = archivo;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando imagen perfil: $e");
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _iniciales(String nombre) {
    String iniciales;
    if (nombre.isEmpty) iniciales = "";
    else {
      var parts = nombre.trim().split(" ");
      if (parts.length >= 2)
        iniciales = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      else
        iniciales = parts[0][0].toUpperCase(); // Caso solo un nombre
    }
    return iniciales;
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radio,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: _imagen != null ? FileImage(_imagen!) : null,
      child: _cargando
          ? SizedBox(
              width: widget.radio,
              height: widget.radio,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : _imagen == null
          ? Text(
              _iniciales(widget.nombre),
              style: TextStyle(
                fontSize: widget.radio * 0.8,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
