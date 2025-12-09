import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/login/loginImagenService.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';

class AlumnoLoginSecuencia extends StatefulWidget {
  final String alumnoId;

  const AlumnoLoginSecuencia({super.key, required this.alumnoId});

  @override
  State<AlumnoLoginSecuencia> createState() => _AlumnoLoginSecuenciaState();
}

class _AlumnoLoginSecuenciaState extends State<AlumnoLoginSecuencia> {
  final _service = LoginImagenService();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool cargando = true;
  List<Pictograma> imagenesMostradas = [];

  List<String> idsSecuenciaOrdenada = [];
  final List<String> _seleccionUsuario = [];

  @override
  void initState() {
    super.initState();
    _iniciarLogin();
  }

  Future<void> _iniciarLogin() async {
    try {
      // 1. LEER CONFIGURACIÓN ESPECÍFICA (Secuencia)
      final snap = await _dbRef
          .child("tato")
          .child("login")
          .child(widget.alumnoId)
          .child("secuenciaImagenes")
          .get();

      if (!snap.exists || snap.value == null || snap.value is! Map) {
        if (mounted) setState(() => cargando = false);
        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(snap.value as Map);

      // A. Parsear la secuencia correcta (La contraseña)
      if (data["secuenciaCorrecta"] != null && data["secuenciaCorrecta"] is Map) {
        Map<String, String> secuenciaMap = Map<String, String>.from(data["secuenciaCorrecta"]);
        // Ordenamos las claves (paso_01, paso_02...)
        var clavesOrdenadas = secuenciaMap.keys.toList()..sort();
        // Guardamos los IDs en orden para validar luego
        idsSecuenciaOrdenada = clavesOrdenadas.map((k) => secuenciaMap[k]!).toList();
      }

      // B. Parsear parámetros del grid
      int total = (data["totalImagenes"] is int)
          ? data["totalImagenes"] as int
          : int.tryParse("${data["totalImagenes"]}") ?? 9;

      bool aleatorio = data["distractorasAleatorias"] is bool
          ? data["distractorasAleatorias"] as bool
          : (data["distractorasAleatorias"]?.toString().toLowerCase() == 'true');

      // C. Parsear distractores manuales
      List<String> manuales = [];
      if (data["imagenesDistractoras"] != null && data["imagenesDistractoras"] is Map) {
        Map distractoresMap = data["imagenesDistractoras"];
        manuales = distractoresMap.keys.map((k) => k.toString()).toList();
      }

      // 2. PEDIR GRID AL SERVICIO (Lógica simplificada)
      if (idsSecuenciaOrdenada.isNotEmpty) {
        imagenesMostradas = await _service.generarGrid(
            idsCorrectos: idsSecuenciaOrdenada, // Pasamos la lista de la secuencia
            idsDistractoresManuales: manuales,
            totalImagenes: total,
            esAleatorio: aleatorio
        );
      }

    } catch (e) {
      debugPrint("Error inicializando secuencia: $e");
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  void _onImagenTap(String id) {
    setState(() {
      // Si ya estaba seleccionada, la quitamos (deshacer selección)
      if (_seleccionUsuario.contains(id)) {
        _seleccionUsuario.remove(id);
      } else {
        // Si no hemos llegado al límite de pasos, la añadimos
        if (_seleccionUsuario.length < idsSecuenciaOrdenada.length) {
          _seleccionUsuario.add(id);
        }
      }
    });
  }

  void _intentarLogin() {
    final alumnoHolder = context.read<AlumnoHolder>();
    String nombreAlumno = alumnoHolder.alumno?.nombre ?? "Alumno";

    // Validar longitud
    if (_seleccionUsuario.length != idsSecuenciaOrdenada.length) {
      // No debería pasar porque el botón estaría desactivado, pero por seguridad
      return;
    }

    // Validar orden estricto: El item 0 del usuario debe ser el item 0 de la secuencia
    bool esCorrecto = true;
    for (int i = 0; i < idsSecuenciaOrdenada.length; i++) {
      if (_seleccionUsuario[i] != idsSecuenciaOrdenada[i]) {
        esCorrecto = false;
        break;
      }
    }

    if (esCorrecto) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("¡Bienvenido $nombreAlumno!"), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GamesMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Secuencia incorrecta. Inténtalo de nuevo."), backgroundColor: Colors.red),
      );
      // Reiniciamos selección para que pruebe otra vez
      setState(() {
        _seleccionUsuario.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final Alumno? alumno = alumnoHolder.alumno;
    final colorScheme = Theme.of(context).colorScheme;

    if (alumno == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // --- LÓGICA DEL GRID 2xN ---
    // Calculamos las columnas para que siempre sean 2 filas aprox.
    int columnas = 3; // Valor por defecto (2x3)
    if (imagenesMostradas.length == 4) columnas = 2; // (2x2)
    if (imagenesMostradas.length == 8) columnas = 4; // (2x4)
    if (imagenesMostradas.length > 8) columnas = 4;  // Fallback para más grandes

    double maxWidth = columnas * 180.0;

    bool botonActivo = _seleccionUsuario.length == idsSecuenciaOrdenada.length;

    return ScaffoldComunV2(
        titulo: "Incio de Sesion por Secuencia",
        cuerpo: cargando
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        Text(
                          "Marca las imágenes en orden (${_seleccionUsuario.length}/${idsSecuenciaOrdenada.length})",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        if (imagenesMostradas.isEmpty)
                          const Text("Error cargando imágenes")
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columnas,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: imagenesMostradas.length,
                            itemBuilder: (context, index) {
                              final picto = imagenesMostradas[index];

                              // Comprobar si está seleccionada y en qué posición
                              int indexSeleccion = _seleccionUsuario.indexOf(picto.id);
                              bool isSelected = indexSeleccion != -1;

                              return GestureDetector(
                                onTap: () => _onImagenTap(picto.id),
                                child: Stack(
                                  children: [
                                    // LA IMAGEN (FONDO)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected ? colorScheme.primary : Colors.grey.shade300,
                                          width: isSelected ? 4 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                                            : [],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: ImagenStorage(rutaGs: picto.url, fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),

                                    // EL NÚMERO DE ORDEN (BADGE)
                                    if (isSelected)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          width: 32, height: 32,
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${indexSeleccion + 1}",
                                              style: TextStyle(
                                                  color: colorScheme.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 40),

                        // BOTONERA
                        Row(
                          children: [
                            // BOTÓN BORRAR
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 55,
                                child: OutlinedButton(
                                  onPressed: _seleccionUsuario.isEmpty ? null : () {
                                    setState(() => _seleccionUsuario.clear());
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                  child: const Icon(Icons.refresh),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // BOTÓN ENTRAR
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: botonActivo ? _intentarLogin : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text("Entrar"),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
        ),
    );

    /*return Scaffold(
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
    );*/
  }
}