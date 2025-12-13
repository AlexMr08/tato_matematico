import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';

/// **Nombre de la Clase: `ConfigImagenUnicaScreen`**
///
/// **Descripción:** clase que permite configurar el login de selección de imagen única para un alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Joaquin Salas Castillo / Gonzalo Alganza Luque
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///

class ConfigImagenUnicaScreen extends StatefulWidget {
  final Alumno alumno;

  const ConfigImagenUnicaScreen({super.key, required this.alumno});

  @override
  State<ConfigImagenUnicaScreen> createState() =>
      _ConfigImagenUnicaScreenState();
}

class _ConfigImagenUnicaScreenState extends State<ConfigImagenUnicaScreen> {
  // Referencia a firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ESTADO DE LA PANTALLA
  int _currentStep = 1; // 1: Elegir Configuracion, 2: Elegir Imagenes

  // PARAMETROS PARA LA CONFIGURACION
  int _gridSize = 6; // Tamaño del grid
  bool _isRandom = true; // Imagenes distractoras aleatorias

  // PARAMETROS PARA LA SELECCION
  String? _selectedCorrectImageId; // ID imagen correcta
  final Map<String, bool> _selectedDistractoras = {}; // IDs imagenes distractoras

  // DATOS DE LA BIBLIOTECA DE PICTOGRAMAS
  List<Pictograma> _biblioteca = [];
  bool _isLoadingLibrary = true;
  bool _isSaving = false;

  @override
  @override
  void initState() {
    super.initState();
    _cargarBiblioteca();
  }

  /// Cargar la biblioteca de imagenes desde firebase
  Future<void> _cargarBiblioteca() async {
    try {
      final snapshot = await _dbRef
          .child('tato')
          .child('bibliotecaImagenes')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>,
        );

        final listaTemp = <Pictograma>[];

        data.forEach((key, value) {
          listaTemp.add(Pictograma.fromMap(key, value));
        });

        setState(() {
          _biblioteca = listaTemp;
          _isLoadingLibrary = false;
        });
      } else {
        setState(() => _isLoadingLibrary = false);
      }
    } catch (e) {
      print("Error cargando biblioteca: $e");
      setState(() => _isLoadingLibrary = false);
    }
  }

  /// Metodo para guardar la configuracion del login en firebase
  Future<void> _guardarConfiguracion() async {
    setState(() => _isSaving = true);

    try {
      Map<String, dynamic> loginConfig = {
        "tipoLogin": "seleccionImagen",
        "seleccionImagen": {
          "idImagenCorrecta": _selectedCorrectImageId,
          "totalImagenes": _gridSize,
          "distractorasAleatorias": _isRandom,
          "imagenesDistractoras": _isRandom ? null : _selectedDistractoras,
        },
        // Desactivamos los otros tipos de login
        "alfanumerica": null,
        "secuenciaImagenes": null,
      };

      await _dbRef
          .child('tato')
          .child('login')
          .child(widget.alumno.id)
          .set(loginConfig);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login guardado correctamente"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context); // Volver a editar alumno
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- INTERACCIÓN: CLICK EN UNA IMAGEN ---
  void _manejarClickImagen(Pictograma img) {
    setState(() {
      // 1. Deseleccionar si tocamos la que ya es correcta
      if (_selectedCorrectImageId == img.id) {
        _selectedCorrectImageId = null;
        return;
      }

      // 2. Deseleccionar si tocamos una distractora (Modo Manual)
      if (_selectedDistractoras.containsKey(img.id)) {
        _selectedDistractoras.remove(img.id);
        return;
      }

      // 3. Si no hay correcta, asignarla
      if (_selectedCorrectImageId == null) {
        _selectedCorrectImageId = img.id;
        return;
      }

      // 4. Si ya hay correcta, que se hace con la nueva
      if (_isRandom) {
        // En modo aleatorio, reemplazamos la correcta
        _selectedCorrectImageId = img.id;
      } else {
        // En modo manual, intentamos añadir como distractor
        // Solamente si hay hueco (total - 1 correcta = distractoras)
        if (_selectedDistractoras.length < (_gridSize - 1)) {
          _selectedDistractoras[img.id] = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Grid lleno. Deselecciona alguna para cambiarla."),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComunV2(
      titulo: widget.alumno.nombre,
      subtitulo: _currentStep == 1
          ? "Ajustes del Grid"
          : "Selección de Imágenes",
      cuerpo: Column(
        children: [
          // MOSTRAR FASE 1 O FASE 2
          if (_currentStep == 1)
            _buildPaso1Config()
          else
            _buildPaso2Seleccion(),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // VISTA PASO 1: CONFIGURACIÓN INICIAL (Grid y Modo)
  // ---------------------------------------------------
  Widget _buildPaso1Config() {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Center(
        // 1. Centramos el bloque horizontalmente
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ), // 2. Limitamos ancho para tablets
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20), // Margen superior
                        // 1. SELECTOR DE TAMAÑO
                        const Text(
                          "1. ¿Cuántas imágenes se mostrarán en total?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _gridSize,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 4,
                              child: Text("4 Imágenes (2x2)"),
                            ),
                            DropdownMenuItem(
                              value: 6,
                              child: Text("6 Imágenes (2x3)"),
                            ),
                            DropdownMenuItem(
                              value: 8,
                              child: Text("8 Imágenes (2x4)"),
                            ),
                          ],
                          onChanged: (v) => setState(() {
                            _gridSize = v!;
                            _selectedDistractoras.clear();
                          }),
                        ),

                        const SizedBox(height: 30),

                        // 2. SELECTOR DE MODO
                        const Text(
                          "2. ¿Cómo se eligen las imágenes incorrectas?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<bool>(
                          initialValue: _isRandom,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text("Aleatorias"),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text("Seleccionar las incorrectas"),
                            ),
                          ],
                          onChanged: (v) {
                            setState(() {
                              _isRandom = v!;
                              _selectedDistractoras.clear();
                            });
                          },
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            _isRandom
                                ? "La aplicación rellenará las imágenes incorrectas al azar."
                                : "Deberás seleccionar las imagenes incorrectas manualmente.",
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ), // Espacio extra al final del scroll
                      ],
                    ),
                  ),
                ),

                // BLOQUE INFERIOR
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _currentStep = 2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primaryContainer,
                      foregroundColor: colorScheme.onPrimaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "CONTINUAR A SELECCIÓN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // VISTA PASO 2: SELECCIÓN VISUAL
  // ---------------------------------------------------
  Widget _buildPaso2Seleccion() {
    // Colores del tema
    final colorScheme = Theme.of(context).colorScheme;

    // Cálculos para la UI
    int distractoresNecesarios = _gridSize - 1;
    int distractoresActuales = _selectedDistractoras.length;
    bool hayCorrecta = _selectedCorrectImageId != null;

    // Comprobacion para guardar
    bool listoParaGuardar =
        hayCorrecta &&
        (_isRandom || distractoresActuales == distractoresNecesarios);

    return Expanded(
      child: Column(
        children: [
          // --- ZONA SUPERIOR (RESUMEN) ---
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // HUECO IMAGEN CORRECTA
                const Text(
                  "IMAGEN CORRECTA (CONTRASEÑA)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 5),
                InkWell(
                  onTap: hayCorrecta
                      ? () => setState(() => _selectedCorrectImageId = null)
                      : null,
                  child: Container(
                    key: ValueKey("correct_${_selectedCorrectImageId ?? 'none'}"),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: hayCorrecta ? colorScheme.primary : colorScheme.outlineVariant,
                        width: hayCorrecta ? 4 : 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        if (hayCorrecta)
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: .2),
                            blurRadius: 5,
                          ),
                      ],
                    ),
                    child: hayCorrecta
                        ? _previewImagen(_selectedCorrectImageId!)
                        : Icon(
                            Icons.lock_outline,
                            size: 40,
                            color: colorScheme.outlineVariant,
                          ),
                  ),
                ),

                // HUECOS IMAGENES DISTRACTORAS (si es manual)
                if (!_isRandom) ...[
                  const SizedBox(height: 10),
                  Text(
                    "DISTRACTORES ($distractoresActuales / $distractoresNecesarios)",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 5),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(distractoresNecesarios, (index) {
                        String? id;
                        if (index < _selectedDistractoras.keys.length) {
                          id = _selectedDistractoras.keys.elementAt(index);
                        }

                        return InkWell(
                          onTap: id != null
                              ? () => setState(
                                () => _selectedDistractoras.remove(id),
                          )
                              : null,
                          child: Container(
                            key: ValueKey("dist_$index${id ?? 'none'}"),
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: id != null
                                    ? colorScheme.error
                                    : colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: id != null
                                ? _previewImagen(id)
                                : Icon(Icons.add, color: colorScheme.outlineVariant),
                          ),
                        );
                      }),
                    ),
                  ),
                ] else
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "El resto de imágenes serán aleatorias.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: colorScheme.outlineVariant),

          // --- ZONA INFERIOR (BIBLIOTECA GRID) ---
          Expanded(
            child: _isLoadingLibrary
                ? const Center(child: CircularProgressIndicator())
                : _biblioteca.isEmpty
                ? const Center(child: Text("No hay imágenes en la biblioteca"))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 4 columnas
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _biblioteca.length,
                    itemBuilder: (context, index) {
                      final picto = _biblioteca[index];
                      bool esCorrecta = _selectedCorrectImageId == picto.id;
                      bool esDistractor = _selectedDistractoras.containsKey(
                        picto.id,
                      );

                      return InkWell(
                        onTap: () => _manejarClickImagen(picto),
                        child: Stack(
                          children: [
                            // La Imagen
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: esCorrecta
                                    ? Border.all(color: colorScheme.primary, width: 4)
                                    : esDistractor
                                    ? Border.all(color: colorScheme.error, width: 3)
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                // USAMOS WIDGET CON CACHE
                                child: ImagenStorage(
                                  rutaGs: picto.url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Indicador visual (Check o X)
                            if (esCorrecta || esDistractor)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: esCorrecta ? colorScheme.primary : colorScheme.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: Icon(
                                    esCorrecta
                                        ? Icons.check
                                        : Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // --- BOTÓN GUARDAR ---
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: listoParaGuardar && !_isSaving
                  ? _guardarConfiguracion
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: .12),
              ),
              child: _isSaving
                  ? CircularProgressIndicator(color: colorScheme.onPrimary)
                  : Text(
                      listoParaGuardar
                          ? "GUARDAR CONFIGURACION"
                          : "SELECCIONA LAS IMÁGENES...",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Función auxiliar para buscar la foto en la lista local y pintarla
  Widget _previewImagen(String id) {
    try {
      final picto = _biblioteca.firstWhere((p) => p.id == id);
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: ImagenStorage(rutaGs: picto.url, fit: BoxFit.cover),
      );
    } catch (e) {
      return const Icon(Icons.error, size: 10);
    }
  }
}
