import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';


//Parte del codigo se ha hecho con asistencia de IA

class LoginConImagen extends StatefulWidget {
  final String alumnoId;

  const LoginConImagen({super.key, required this.alumnoId});

  @override
  State<LoginConImagen> createState() => _LoginConImagenState();
}

class _LoginConImagenState extends State<LoginConImagen> {
  final db = FirebaseDatabase.instance.ref();

  bool cargando = true;
  List<Pictograma> biblioteca = [];
  List<Pictograma> imagenesMostradas = [];

  String? idCorrecta;
  int total = 6;
  bool aleatorio = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      // 1. Cargar configuración de login
      final snap = await db
          .child("tato")
          .child("login")
          .child(widget.alumnoId)
          .child("seleccionImagen")
          .get();

      if (!snap.exists || snap.value == null || snap.value is! Map) {
        // No hay configuración válida
        debugPrint("No hay configuración de login por "
            "imagen o formato inválido.");
        if (mounted) {
          setState(() => cargando = false);
        }
        return;
      }

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(snap.value as Map);

      idCorrecta = data["idImagenCorrecta"]?.toString();
      total = (data["totalImagenes"] is int) ? data["totalImagenes"] as int :
      int.tryParse("${data["totalImagenes"]}") ?? total;
      aleatorio = data["distractorasAleatorias"] is bool ?
      data["distractorasAleatorias"] as bool :
      (data["distractorasAleatorias"]?.toString().toLowerCase() == 'true');

      // 2. Cargar biblioteca completa
      final snapBib = await db.child("tato").child("bibliotecaImagenes").get();

      final List<Pictograma> listaTemp = [];

      if (snapBib.exists && snapBib.value != null && snapBib.value is Map) {
        final map = Map<String, dynamic>.from(snapBib.value as Map);
        map.forEach((key, value) {
          try {
            listaTemp.add(Pictograma.fromMap(key, value));
          } catch (e) {
            debugPrint("Error parseando pictograma $key: $e");
          }
        });
      } else {
        debugPrint("Biblioteca vacía o formato inválido.");
      }

      if (listaTemp.isEmpty) {
        // Si no hay imágenes, no podemos continuar
        if (mounted) {
          setState(() {
            biblioteca = [];
            cargando = false;
          });
        }
        return;
      }

      // Asignar biblioteca y generar imágenes
      if (mounted) {
        setState(() {
          biblioteca = listaTemp;
        });
      }

      _generarImagenes();

      if (mounted) setState(() => cargando = false);
    } catch (e, st) {
      debugPrint("ERROR en _cargarConfiguracion: $e\n$st");
      if (mounted) setState(() => cargando = false);
    }
  }

  void _generarImagenes() {
    imagenesMostradas = []; // limpiar primero

    if (biblioteca.isEmpty) return;

    // Buscar la imagen correcta (si no existe, abortamos)
    final correcta = biblioteca.firstWhere(
          (p) => p.id == idCorrecta
    );

    if (correcta.isEmpty) {
      debugPrint("Imagen correcta no encontrada en la biblioteca: $idCorrecta");
      // Si no encontramos la correcta, no generamos nada
      if (mounted) {
        setState(() {
          imagenesMostradas = [];
        });
      }
      return;
    }

    imagenesMostradas.add(correcta);

    List<Pictograma> restantes = List.from(biblioteca)
      ..removeWhere((p) => p.id == idCorrecta);

    restantes.shuffle();

    // Si hay menos imágenes de las que se piden, ajustamos el total
    final int objetivo = total.clamp(1, biblioteca.length);

    while (imagenesMostradas.length < objetivo && restantes.isNotEmpty) {
      imagenesMostradas.add(restantes.removeAt(0));
    }

    imagenesMostradas.shuffle();

    if (mounted) setState(() {});
  }

  void _tocarImagen(Pictograma picto) {
    if (picto.id == idCorrecta) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ha iniciado sesion correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GamesMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contraseña incorrecta"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (biblioteca.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Selecciona tu imagen")),
        body: const Center(child: Text("No hay imágenes disponibles.")),
      );
    }

    if (imagenesMostradas.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Selecciona tu imagen")),
        body: const Center(child: Text("No se pudo preparar las imágenes.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio de sesion de Alumno',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        actions: [Padding(padding: const EdgeInsets.only(right: 16))],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10,
            childAspectRatio: 1.4),
        itemCount: imagenesMostradas.length,
        itemBuilder: (context, index) {
          final picto = imagenesMostradas[index];

          return InkWell(
            onTap: () => _tocarImagen(picto),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ImagenStorage(
                rutaGs: picto.url,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}