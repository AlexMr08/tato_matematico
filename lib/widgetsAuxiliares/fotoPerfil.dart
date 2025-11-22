import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tato_matematico/datos/profesor.dart'; // Tu modelo

//Clase hecha con ayuda de IA
class FotoPerfil extends StatefulWidget {
  final Profesor profesor;
  final double radio; // Para poder cambiar el tamaño si lo usas en drawer o perfil

  const FotoPerfil({
    super.key,
    required this.profesor,
    this.radio = 40
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

  // Si el profesor cambia (ej. actualización en tiempo real), recargamos
  @override
  void didUpdateWidget(covariant FotoPerfil oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profesor.id != widget.profesor.id ||
        oldWidget.profesor.imagen != widget.profesor.imagen) {
      _cargarImagen();
    }
  }

  Future<void> _cargarImagen() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archivo = await widget.profesor.obtenerImagen(tempDir);

      if (mounted) {
        setState(() {
          _imagen = archivo;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _cargando = false);
    }
  }

  String _iniciales(String nombre) {
    if (nombre.isEmpty) return "";
    var parts = nombre.trim().split(" ");
    if (parts.length >= 2) return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radio,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: _imagen != null ? FileImage(_imagen!) : null,
      child: _cargando
          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
          : _imagen == null
          ? Text(
        _iniciales(widget.profesor.nombre),
        style: TextStyle(
          fontSize: widget.radio * 0.8, // Tamaño dinámico de letra
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      )
          : null, // Si hay imagen, no mostramos texto
    );
  }
}
