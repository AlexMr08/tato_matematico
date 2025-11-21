import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImagenStorage extends StatefulWidget {
  final String rutaGs;
  final double? alto;
  final double? ancho;
  final BoxFit fit;

  const ImagenStorage({
    super.key,
    required this.rutaGs,
    this.alto,
    this.ancho,
    this.fit = BoxFit.cover,
  });

  @override
  State<ImagenStorage> createState() => _ImagenStorageState();
}

class _ImagenStorageState extends State<ImagenStorage> {
  String? _urlPublica;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _obtenerUrlPublica();
  }

  Future<void> _obtenerUrlPublica() async {
    if (widget.rutaGs.isEmpty) return;

    try {
      // Crear referencia ruta gs
      final ref = FirebaseStorage.instance.ref().child(widget.rutaGs);

      // Obtenemos url de descarga
      final url = await ref.getDownloadURL();

      if(mounted) {
        setState(() {
          _urlPublica = url;
          _loading = false;
        });
      }
    }
    catch (e) {
      print("Error cargando imagen ${widget.rutaGs}: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si está cargando, mostramos un spinner pequeñito
    if (_loading) {
      return SizedBox(
        width: widget.ancho,
        height: widget.alto,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Si tenemos URL, mostramos la imagen
    if (_urlPublica != null) {
      return Image.network(
        _urlPublica!,
        width: widget.ancho,
        height: widget.alto,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red),
      );
    }

    // Si no funciona nada, mostramos icono roto
    return Container(
      width: widget.ancho,
      height: widget.alto,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}