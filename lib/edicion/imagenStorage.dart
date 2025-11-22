import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  Future<String?>? _futureUrl;

  @override
  void initState() {
    super.initState();
    _futureUrl = _obtenerUrlPublica();
  }

  Future<String?>? _obtenerUrlPublica() async {
    if (widget.rutaGs.isEmpty) return null;

    try {
      // Crear referencia ruta gs
      final ref = FirebaseStorage.instance.refFromURL(widget.rutaGs);

      // Obtenemos url de descarga
      return await ref.getDownloadURL();
    }
    catch (e) {
      print("Error cargando imagen ${widget.rutaGs}: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _futureUrl,
        builder: (context, snapshot) {
          // Carga inicial mientras obtenemos la url
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _placeholder();
          }

          // Si hay un error o no hay url
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return _errorWidget();
          }
          final url = snapshot.data!;

          // Libreria de cache
          return CachedNetworkImage(
            imageUrl: url,
            height: widget.alto,
            width: widget.ancho,
            fit: widget.fit,
            // Mientras se descarga la imagen si no esta en cache
            placeholder: (context, url) => _placeholder(),
            // Si falla la descarga
            errorWidget: (context, url, error) => _errorWidget(),

            fadeInDuration: const Duration(milliseconds: 300),
          );
        }
    );
  }
  /// Widget de carga mientras se descarga la imagen
  Widget _placeholder() {
    return Container(
      width: widget.ancho,
      height: widget.alto,
      color: Colors.grey[200],
      child: Center(
          child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400])
          )
      ),
    );
  }

  /// Widget auxiliar para mostrar si hay error (Icono roto)
  Widget _errorWidget() {
    return Container(
      width: widget.ancho,
      height: widget.alto,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}

