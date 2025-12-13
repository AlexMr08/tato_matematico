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
import 'package:tato_matematico/widgetsAuxiliares/botones.dart';
import 'package:tato_matematico/widgetsAuxiliares/loginStatusCard.dart';

/// Pantalla de inicio de sesión mediante secuencia de imágenes.
///
/// En esta pantalla se le muestra un grid de imágenes al alumno y debe pulsarlas
/// en orden para acceder a los juegos.
///
/// Se utiliza [LoginImagenService] para generar el grid de imágenes.
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

  EstadoLogin _estado = EstadoLogin.normal;

  @override
  void initState() {
    super.initState();
    _iniciarLogin();
  }

  /// Carga la configuración de login de secuencia desde Firebase.
  ///
  /// Recupera:
  /// 1. La secuencia correcta (ordenada).
  /// 2. Configuración del grid (total de imágenes, modo aleatorio).
  /// 3. Distractores manuales (si existen).
  ///
  /// Se delega la generación del grid a [_service]
  Future<void> _iniciarLogin() async {
    try {
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

      // Obtenemos la secuencia correcta
      if (data["secuenciaCorrecta"] != null && data["secuenciaCorrecta"] is Map) {
        Map<String, String> secuenciaMap = Map<String, String>.from(data["secuenciaCorrecta"]);
        var clavesOrdenadas = secuenciaMap.keys.toList()..sort();
        idsSecuenciaOrdenada = clavesOrdenadas.map((k) => secuenciaMap[k]!).toList();
      }

      // Obtenemos total de imagenes y modo aleatorio
      int total = (data["totalImagenes"] is int)
          ? data["totalImagenes"] as int
          : int.tryParse("${data["totalImagenes"]}") ?? 9;

      bool aleatorio = data["distractorasAleatorias"] is bool
          ? data["distractorasAleatorias"] as bool
          : (data["distractorasAleatorias"]?.toString().toLowerCase() == 'true');

      // Obtenemos las distractoras manuales
      List<String> manuales = [];
      if (data["imagenesDistractoras"] != null && data["imagenesDistractoras"] is Map) {
        Map distractoresMap = data["imagenesDistractoras"];
        manuales = distractoresMap.keys.map((k) => k.toString()).toList();
      }

      // Pedimos el grid al servicio de imagenes
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

  /// Maneja la interacción al tocar una imagen del grid.
  ///
  /// Si la imagen estaba seleccionada, se desmarca.
  /// Si no estaba seleccionada, se añade al final de la selección.
  void _onImagenTap(String id) {
    // Si el usuario toca algo, volvemos al estado normal (quitamos mensaje de error)
    if (_estado != EstadoLogin.normal) {
      setState(() => _estado = EstadoLogin.normal);
    }

    setState(() {
      if (_seleccionUsuario.contains(id)) {
        _seleccionUsuario.remove(id);
      } else {
        if (_seleccionUsuario.length < idsSecuenciaOrdenada.length) {
          _seleccionUsuario.add(id);
        }
      }
    });
  }

  /// Compara la contraseña correcta con la selección del usuario.
  ///
  /// Comprueba longitud y coincidencia exacta en cada posición.
  void _intentarLogin() {
    final alumnoHolder = context.read<AlumnoHolder>();
    // Validar longitud
    if (_seleccionUsuario.length != idsSecuenciaOrdenada.length) {
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
      // EXITO
      setState(() => _estado = EstadoLogin.exito);

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GamesMenu()),
          );
        }
      });
    }
    else {
      // ERROR
      setState(() {
        _estado = EstadoLogin.error;
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
    // Calculamos las columnas para que siempre sean 2 filas.
    int columnas = 3;
    if (imagenesMostradas.length == 4) columnas = 2; // (2x2)
    if (imagenesMostradas.length == 8) columnas = 4; // (2x4)
    if (imagenesMostradas.length > 8) columnas = 4;  // Fallback para más grandes

    double maxWidth = columnas * 180.0;

    bool botonEntrarActivo = _seleccionUsuario.length == idsSecuenciaOrdenada.length;
    bool botonBorrarActivo = _seleccionUsuario.isNotEmpty;

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

                        // BARRA DE ESTADO
                        LoginStatusCard(
                          estado: _estado,
                          mensajeNormal: "Pulsa las imágenes en orden.",
                        ),

                        const SizedBox(height: 10,),

                        // INDICADOR DE PROGRESO PARA LAS SELECCIONADAS
                        _buildSecuenciaVisual(colorScheme),

                        const SizedBox(height: 15),

                        // GRID DE IMAGENES
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
                                onTap: () {
                                  _onImagenTap(picto.id);
                                },
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
                                            ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)]
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

                                    // EL NÚMERO DE ORDEN
                                    if (isSelected)
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          width: 40, height: 40,
                                          margin: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: colorScheme.primary,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${indexSeleccion + 1}",
                                              style: TextStyle(
                                                  color: colorScheme.onPrimary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22
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

                        const SizedBox(height: 20),

                        // BOTONERA
                        Row(
                          children: [
                            // 1. BOTÓN BORRAR
                            Expanded(
                              child: SizedBox(
                                height: 55, // Altura cómoda
                                child: BotonConIcono(
                                  icono: Icons.delete_outline_rounded,
                                  texto: "BORRAR",
                                  fontSize: 18,
                                  radio: 27,
                                  onPressed: botonBorrarActivo ? () {
                                    setState(() => _seleccionUsuario.clear());
                                  } : null,
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            // 2. BOTÓN ENTRAR
                            Expanded(
                              child: SizedBox(
                                height: 55,
                                child: BotonConIcono(
                                  icono: Icons.login_rounded,
                                  texto: "ENTRAR",
                                  fontSize: 18,
                                  radio: 27,
                                  onPressed: botonEntrarActivo ? _intentarLogin : null,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
        ),
    );
  }
  /// Construye la fila de cajas con imágenes seleccionadas y flechas.
  Widget _buildSecuenciaVisual(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(idsSecuenciaOrdenada.length, (index) {

          // Verificar si este paso ya tiene imagen seleccionada
          String? idSeleccionado;
          Pictograma? picto;

          if (index < _seleccionUsuario.length) {
            idSeleccionado = _seleccionUsuario[index];
            // Buscamos el objeto Pictograma correspondiente al ID seleccionado
            try {
              picto = imagenesMostradas.firstWhere((p) => p.id == idSeleccionado);
            } catch (e) {
              // Si no está en imagenesMostradas (raro), picto se queda null
            }
          }

          return Row(
            children: [
              // CAJA DEL PASO
              Container(
                key: ValueKey("${index}_${idSeleccionado ?? 'vacio'}"),
                width: 70, height: 70,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: idSeleccionado != null ? colorScheme.primary : colorScheme.outlineVariant,
                        width: idSeleccionado != null ? 3 : 2
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: idSeleccionado != null
                        ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.2), blurRadius: 5)]
                        : []
                ),
                child: picto != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: ImagenStorage(rutaGs: picto.url, fit: BoxFit.cover),
                )
                    : Center(
                  child: Text(
                      "${index + 1}",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.outlineVariant
                      )
                  ),
                ),
              ),

              // FLECHA (si no es el último)
              if (index < idsSecuenciaOrdenada.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}