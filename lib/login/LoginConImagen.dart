import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';
import 'package:tato_matematico/gamesMenu.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/datos/alumno.dart';

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
  List<String> _idsDistractorasManuales = [];

  String? _idCorrecta;
  String? _idSeleccionada;
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
        debugPrint("No hay configuración de login por imagen o formato inválido.");
        if (mounted) {
          setState(() => cargando = false);
        }
        return;
      }

      final Map<String, dynamic> data = Map<String, dynamic>.from(snap.value as Map);

      _idCorrecta = data["idImagenCorrecta"]?.toString();
      total = (data["totalImagenes"] is int)
          ? data["totalImagenes"] as int
          : int.tryParse("${data["totalImagenes"]}") ?? total;

      aleatorio = data["distractorasAleatorias"] is bool
          ? data["distractorasAleatorias"] as bool
          : (data["distractorasAleatorias"]?.toString().toLowerCase() == 'true');

      _idsDistractorasManuales = [];
      if (data["imagenesDistractoras"] != null && data["imagenesDistractoras"] is Map) {
        Map distractoresMap = data["imagenesDistractoras"];
        _idsDistractorasManuales = distractoresMap.keys.map((k) => k.toString()).toList();
      }

      if (!aleatorio && _idCorrecta != null) {
        await _cargarGridManual();
      }
      else {
        _cargarGridAleatorio();
      }

      if (mounted) setState(() => cargando = false);

    } catch (e, st) {
      debugPrint("ERROR en _cargarConfiguracion: $e\n$st");
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> _cargarGridManual() async{
    List<String> todosLosIds = [_idCorrecta!, ..._idsDistractorasManuales];

    // Usamos un Set para evitar duplicados si la BD tuviera errores
    todosLosIds = todosLosIds.toSet().toList();

    List<Pictograma> listaFinal = [];

    // Creamos una lista de "promesas" (Futures) para pedirlas todas a la vez
    // Esto es mucho más rápido que pedirlas una por una en un bucle
    List<Future<DataSnapshot>> futuros = todosLosIds.map((id) {
      return db.child("tato/bibliotecaImagenes/$id").get();
    }).toList();

    // Esperamos a que todas bajen en paralelo
    List<DataSnapshot> snapshots = await Future.wait(futuros);

    for (var snap in snapshots) {
      if (snap.exists && snap.value != null) {
        try {
          // El 'key' del snapshot es el ID del pictograma
          listaFinal.add(Pictograma.fromMap(snap.key!, snap.value as Map));
        } catch (e) {
          debugPrint("Error parseando pictograma: $e");
        }
      }
    }

    // Mezclamos para que la contraseña no salga siempre primera
    listaFinal.shuffle();

    if (mounted) {
      setState(() {
        imagenesMostradas = listaFinal;
      });
    }
  }

  Future<void> _cargarGridAleatorio() async {
    final snapBiblioteca = await db.child("tato").child("bibliotecaImagenes").get();
    List<Pictograma> biblioteca = [];

    if (snapBiblioteca.exists && snapBiblioteca.value != null && snapBiblioteca.value is Map) {
      final map = Map<String, dynamic>.from(snapBiblioteca.value as Map);
      map.forEach((key, value) {
        biblioteca.add(Pictograma.fromMap(key, value));
      });
    }

    if (biblioteca.isEmpty || _idCorrecta == null) return;

    imagenesMostradas = [];

    // 1. Buscar Correcta
    try {
      final correcta = biblioteca.firstWhere((p) => p.id == _idCorrecta);
      imagenesMostradas.add(correcta);
    } catch (e) {
      debugPrint("Imagen correcta no encontrada");
      return;
    }

    // 2. Rellenar con aleatorios
    List<Pictograma> restantes = List.from(biblioteca)
      ..removeWhere((p) => p.id == _idCorrecta);
    restantes.shuffle();

    final int objetivo = total.clamp(1, biblioteca.length);
    while (imagenesMostradas.length < objetivo && restantes.isNotEmpty) {
      imagenesMostradas.add(restantes.removeAt(0));
    }

    // 3. Mezclar
    imagenesMostradas.shuffle();

    if (mounted) setState(() {});
  }

  void _intentarLogin() {
    if (_idSeleccionada == null) return;

    // Recuperamos el nombre del alumno para el mensaje
    final alumnoHolder = context.read<AlumnoHolder>();
    String nombreAlumno = alumnoHolder.alumno?.nombre ?? "Alumno";

    if (_idSeleccionada == _idCorrecta) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Bienvenido $nombreAlumno!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GamesMenu()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contraseña incorrecta, inténtalo de nuevo"),
          backgroundColor: Colors.red,
        ),
      );
      // Opcional: Quitar selección tras error
      setState(() => _idSeleccionada = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumnoHolder = context.watch<AlumnoHolder>();
    final Alumno? alumno = alumnoHolder.alumno;
    final colorScheme = Theme.of(context).colorScheme;

    if (alumno == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- LÓGICA DEL GRID 2xN ---
    // Calculamos las columnas para que siempre sean 2 filas aprox.
    int columnas = 3; // Valor por defecto (2x3)
    if (imagenesMostradas.length == 4) columnas = 2; // (2x2)
    if (imagenesMostradas.length == 8) columnas = 4; // (2x4)
    if (imagenesMostradas.length > 8) columnas = 4;  // Fallback para más grandes

    // Ajustamos el ancho máximo de la caja según las columnas para que no queden huecos gigantes
    double maxWidth = columnas * 180.0;

    return ScaffoldComunV2(
      titulo: "Incio de sesión por Imagen",
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

                  // 1. INSTRUCCIÓN (Ahora es lo primero)
                  Text(
                    "Elige la imagen que es tu contraseña",
                    style: TextStyle(
                      fontSize: 24, // Un poco más grande para destacar
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // 2. GRID DE IMÁGENES
                  if (imagenesMostradas.isEmpty)
                    const Text("No se pudieron cargar las imágenes")
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnas,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: imagenesMostradas.length,
                      itemBuilder: (context, index) {
                        final picto = imagenesMostradas[index];
                        final bool isSelected = _idSeleccionada == picto.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_idSeleccionada == picto.id) {
                                _idSeleccionada = null;
                              } else {
                                _idSeleccionada = picto.id;
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? colorScheme.primary : Colors.grey.shade300,
                                width: isSelected ? 5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                                  : [],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ImagenStorage(
                                  rutaGs: picto.url,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 40),

                  // 3. BOTÓN ENTRAR
                  SizedBox(
                    width: 300,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _idSeleccionada == null ? null : _intentarLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text("Entrar"),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}