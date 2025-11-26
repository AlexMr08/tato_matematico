import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';

class AlumnoLoginSecuencia extends StatefulWidget {
  final String alumnoId;

  const AlumnoLoginSecuencia({super.key, required this.alumnoId});

  @override
  State<AlumnoLoginSecuencia> createState() => _AlumnoLoginSecuenciaState();
}

class _AlumnoLoginSecuenciaState extends State<AlumnoLoginSecuencia> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool cargando = true;
  List<Pictograma> biblioteca = [];
  List<Pictograma> imagenesMostradas = [];

  Map<String, String> secuenciaCorrecta = {};
  int pasoActual = 1;
  int total = 6;
  bool aleatorio = true;

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      // 1. Cargar configuración de login por secuencia
      final snap = await _dbRef
          .child("tato")
          .child("login")
          .child(widget.alumnoId)
          .child("secuenciaImagenes")
          .get();

      if (snap.exists && snap.value != null && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        final secuencia = data["secuenciaCorrecta"] as Map?;
        if (secuencia != null) {
          secuenciaCorrecta = secuencia.map((k, v) => MapEntry(k, v.toString()));
        }
        total = data["totalImagenes"] is int
            ? data["totalImagenes"]
            : int.tryParse("${data["totalImagenes"]}") ?? 6;
        aleatorio = data["distractorasAleatorias"]?.toString().toLowerCase() == "true";
      }

      // 2. Cargar biblioteca de pictogramas
      final snapBib = await _dbRef.child("tato").child("bibliotecaImagenes").get();
      if (snapBib.exists && snapBib.value != null && snapBib.value is Map) {
        final map = Map<String, dynamic>.from(snapBib.value as Map);
        biblioteca = map.entries.map((e) => Pictograma.fromMap(e.key, e.value)).toList();
      }

      _generarImagenes();
      if (mounted) setState(() => cargando = false);
    } catch (e) {
      debugPrint("Error cargando secuencia: $e");
      if (mounted) setState(() => cargando = false);
    }
  }

  void _generarImagenes() {
    if (biblioteca.isEmpty || secuenciaCorrecta.isEmpty) {
      imagenesMostradas = [];
      if (mounted) setState(() {});
      return;
    }

    // Añadir imágenes de la secuencia primero
    List<Pictograma> seleccionadas = [];
    for (var id in secuenciaCorrecta.values) {
      final picto = biblioteca.firstWhere((p) => p.id == id, orElse: () => Pictograma(id: id, url: '', descripcion: '', categoria: '',));
      seleccionadas.add(picto);
    }

    // Añadir distractoras
    List<Pictograma> restantes = List.from(biblioteca)..removeWhere((p) => secuenciaCorrecta.values.contains(p.id));
    while (seleccionadas.length < total && restantes.isNotEmpty) {
      seleccionadas.add(restantes.removeAt(0));
    }

    if (aleatorio) seleccionadas.shuffle();

    imagenesMostradas = seleccionadas;
    if (mounted) setState(() {});
  }

  void _tocarImagen(Pictograma picto) {
    String clavePaso = "paso_${pasoActual.toString().padLeft(2, '0')}";
    String? idEsperada = secuenciaCorrecta[clavePaso];

    if (idEsperada == null) return;

    if (picto.id == idEsperada) {
      pasoActual++;
      if (pasoActual > secuenciaCorrecta.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ha iniciado sesión correctamente"), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GamesMenu()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Paso correcto: $clavePaso"),
            backgroundColor: Colors.blue,
            duration: const Duration(milliseconds: 500),
          ),
        );
      }
    } else {
      pasoActual = 1;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Secuencia incorrecta, empieza de nuevo"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (imagenesMostradas.isEmpty) return const Scaffold(body: Center(child: Text("No se pudieron preparar las imágenes")));

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
              borderRadius: BorderRadius.circular(8),
              child: ImagenStorage(rutaGs: picto.url, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }
}