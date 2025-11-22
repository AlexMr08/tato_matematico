import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tato_matematico/alumno.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/pictograma.dart';
import 'package:tato_matematico/edicion/imagenStorage.dart';

class ConfigSecuenciaScreen extends StatefulWidget {
  final Alumno alumno;

  const ConfigSecuenciaScreen({
    super.key,
    required this.alumno,
  });

  @override
  State<ConfigSecuenciaScreen> createState() => _ConfigSecuenciaScreenState();
}

class _ConfigSecuenciaScreenState extends State<ConfigSecuenciaScreen> {
  // Referencia a firebase
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // ESTADO DE LA PANTALLA
  int _currentStep = 1;

  // PARAMETROS PARA CONFIGURACION
  int _gridSize = 6;
  int _sequenceLength = 3;
  bool _isRandom = true;

  // PARAMETROS PARA SELECCION
  final List<String> _orderedSequenceIds = [];
  final Map<String, bool> _selectedDistractoras = {};

  // DATOS DE LA BIBLIOTECA DE PICTOGRAMAS
  List<Pictograma> _biblioteca = [];
  bool _isLoadingLibrary = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarBiblioteca();
  }

  Future<void> _cargarBiblioteca() async {
    try {
      final snapshot = await _dbRef.child('tato').child('bibliotecaImagenes').get();
      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
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

  Future<void> _guardarConfiguracion() async {
    setState(() => _isSaving = true);
    try {
      // 1. Convertimos la lista ordenada en un Mapa para Firebase
      // Ejemplo: { "paso_01": "id_gato", "paso_02": "id_perro" }
      Map<String, String> secuenciaMap = {};
      for (int i = 0; i < _orderedSequenceIds.length; i++) {
        // Usamos padding left para que quede "paso_01"
        String key = "paso_0${i + 1}";
        secuenciaMap[key] = _orderedSequenceIds[i];
      }

      Map<String, dynamic> loginConfig = {
        "tipoLogin": "secuenciaImagenes",
        "secuenciaImagenes": {
          "secuenciaCorrecta": secuenciaMap,
          "totalImagenes": _gridSize,
          "distractorasAleatorias": _isRandom,
          "imagenesDistractoras": _isRandom ? null : _selectedDistractoras,
        },
        // Limpiamos los otros
        "alfanumerica": null,
        "seleccionImagen": null,
      };

      await _dbRef.child('tato').child('login').child(widget.alumno.id).set(loginConfig);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text("Secuencia guardada correctamente"),
              backgroundColor: Theme.of(context).colorScheme.primary
          )
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- LÓGICA DE CLICK INTELIGENTE ---
  void _manejarClickImagen(Pictograma img) {
    setState(() {
      // 1. Si ya es parte de la secuencia -> Quitarla
      if (_orderedSequenceIds.contains(img.id)) {
        _orderedSequenceIds.remove(img.id);
        return;
      }

      // 2. Si es distractora -> Quitarla
      if (_selectedDistractoras.containsKey(img.id)) {
        _selectedDistractoras.remove(img.id);
        return;
      }

      // 3. Si la secuencia NO está llena -> Añadir al final
      if (_orderedSequenceIds.length < _sequenceLength) {
        _orderedSequenceIds.add(img.id);
        return;
      }

      // 4. Si secuencia llena...
      if (_isRandom) {
        // Modo Aleatorio: Reemplazar el último paso (comportamiento opcional)
        _orderedSequenceIds.removeLast();
        _orderedSequenceIds.add(img.id);
      } else {
        // Modo Manual: Añadir a distractores si cabe
        int totalHuecos = _gridSize - _sequenceLength;
        if (_selectedDistractoras.length < totalHuecos) {
          _selectedDistractoras[img.id] = true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Todos los huecos están llenos."), duration: Duration(milliseconds: 800))
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldComun(
      titulo: widget.alumno.nombre,
      subtitulo: _currentStep == 1 ? "Ajustes de Secuencia" : "Definir Orden",
      funcionSalir: () {
        if (_currentStep == 2) {
          setState(() => _currentStep = 1);
        } else {
          Navigator.pop(context);
        }
      },
      cuerpo: Column(
        children: [
          if (_currentStep == 1) _buildPaso1Config() else _buildPaso2Seleccion(),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // VISTA PASO 1: CONFIGURACIÓN
  // ---------------------------------------------------
  Widget _buildPaso1Config() {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TAMAÑO DEL GRID
            const Text("Tamaño total del Grid (Opciones + Distractores)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _gridSize,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
              ),
              items: const [
                DropdownMenuItem(value: 6, child: Text("6 Imágenes")),
                DropdownMenuItem(value: 9, child: Text("9 Imágenes")),
                DropdownMenuItem(value: 12, child: Text("12 Imágenes")),
              ],
              onChanged: (v) => setState(() {
                _gridSize = v!;
                _selectedDistractoras.clear();
              }),
            ),

            const SizedBox(height: 25),

            // 2. LONGITUD DE SECUENCIA (NUEVO)
            const Text("Longitud de la Secuencia Correcta", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _sequenceLength,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
              ),
              items: const [
                DropdownMenuItem(value: 2, child: Text("2 Pasos")),
                DropdownMenuItem(value: 3, child: Text("3 Pasos (Máximo)")),
              ],
              onChanged: (v) => setState(() {
                _sequenceLength = v!;
                // Si reducimos longitud, cortamos la lista si ya había seleccionados
                if (_orderedSequenceIds.length > _sequenceLength) {
                  _orderedSequenceIds.removeRange(_sequenceLength, _orderedSequenceIds.length);
                }
                _selectedDistractoras.clear();
              }),
            ),

            const SizedBox(height: 25),

            // 3. TIPO DE DISTRACCIÓN
            const Text("Tipo de selección de distractores", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<bool>(
              initialValue: _isRandom,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHigh,
              ),
              items: const [
                DropdownMenuItem(value: true, child: Text("Aleatorias")),
                DropdownMenuItem(value: false, child: Text("Seleccionar manualmente")),
              ],
              onChanged: (v) {
                setState(() {
                  _isRandom = v!;
                  _selectedDistractoras.clear();
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primaryContainer,
                  foregroundColor: colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: const Text("Siguiente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------
  // VISTA PASO 2: SELECCIÓN VISUAL
  // ---------------------------------------------------
  Widget _buildPaso2Seleccion() {
    final colorScheme = Theme.of(context).colorScheme;

    // Cálculos
    int distractoresNecesarios = _gridSize - _sequenceLength;
    int distractoresActuales = _selectedDistractoras.length;
    bool secuenciaCompleta = _orderedSequenceIds.length == _sequenceLength;
    bool listo = secuenciaCompleta && (_isRandom || distractoresActuales == distractoresNecesarios);

    return Expanded(
      child: Column(
        children: [
          // ZONA SUPERIOR: SECUENCIA + DISTRACTORES
          Container(
            padding: const EdgeInsets.all(12),
            color: colorScheme.surfaceContainerLow,
            child: Column(
              children: [
                // 1. LOS HUECOS DE LA SECUENCIA (NUMERADOS)
                Text("SECUENCIA CORRECTA ($_sequenceLength PASOS)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_sequenceLength, (index) {
                    // Ver si este paso está lleno
                    String? idPaso;
                    if (index < _orderedSequenceIds.length) {
                      idPaso = _orderedSequenceIds[index];
                    }

                    // Flecha entre pasos (solo visual)
                    return Row(
                      children: [
                        InkWell(
                          onTap: idPaso != null ? () => setState(() => _orderedSequenceIds.removeAt(index)) : null,
                          child: Column(
                            children: [
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    border: Border.all(
                                      // Borde azul/primario si está lleno, gris si espera
                                        color: idPaso != null ? colorScheme.primary : colorScheme.outlineVariant,
                                        width: idPaso != null ? 3 : 2
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [if(idPaso != null) BoxShadow(color: colorScheme.primary.withOpacity(0.2), blurRadius: 5)]
                                ),
                                child: idPaso != null
                                    ? _previewImagen(idPaso)
                                    : Center(child: Text("${index + 1}", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.outlineVariant))),
                              ),
                              const SizedBox(height: 4),
                              Text("Paso ${index+1}", style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ),
                        // Flechita excepto en el último
                        if (index < _sequenceLength - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20), // Ajustado para centrar con la caja
                            child: Icon(Icons.arrow_right_alt, color: colorScheme.outline),
                          ),
                      ],
                    );
                  }),
                ),

                const SizedBox(height: 15),

                // 2. LOS DISTRACTORES (SOLO MANUAL)
                if (!_isRandom) ...[
                  Text("DISTRACTORES ($distractoresActuales / $distractoresNecesarios)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: distractoresNecesarios,
                      itemBuilder: (context, index) {
                        String? id;
                        if (index < _selectedDistractoras.keys.length) {
                          id = _selectedDistractoras.keys.elementAt(index);
                        }
                        return InkWell(
                          onTap: id != null ? () => setState(() => _selectedDistractoras.remove(id)) : null,
                          child: Container(
                              width: 50, height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                border: Border.all(
                                  color: id != null ? colorScheme.error : colorScheme.outlineVariant,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: id != null
                                  ? _previewImagen(id)
                                  : Icon(Icons.add, color: colorScheme.outlineVariant)
                          ),
                        );
                      },
                    ),
                  )
                ] else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("El resto se rellena automáticamente.", style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.secondary)),
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: colorScheme.outlineVariant),

          // ZONA INFERIOR: BIBLIOTECA
          Expanded(
            child: _isLoadingLibrary
                ? const Center(child: CircularProgressIndicator())
                : _biblioteca.isEmpty
                ? const Center(child: Text("Biblioteca vacía"))
                : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8
              ),
              itemCount: _biblioteca.length,
              itemBuilder: (context, index) {
                final picto = _biblioteca[index];

                // Comprobamos estados
                int indexSecuencia = _orderedSequenceIds.indexOf(picto.id); // -1 si no está
                bool esParteSecuencia = indexSecuencia != -1;
                bool esDistractor = _selectedDistractoras.containsKey(picto.id);

                return InkWell(
                  onTap: () => _manejarClickImagen(picto),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: esParteSecuencia
                              ? Border.all(color: colorScheme.primary, width: 4)
                              : esDistractor
                              ? Border.all(color: colorScheme.error, width: 3)
                              : null,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: ImagenStorage(rutaGs: picto.url, fit: BoxFit.cover),
                        ),
                      ),
                      // Badge con el número del paso o X
                      if (esParteSecuencia || esDistractor)
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                                color: esParteSecuencia ? colorScheme.primary : colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5)
                            ),
                            child: Center(
                              child: esParteSecuencia
                                  ? Text("${indexSecuencia + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
                                  : const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),

          // BOTÓN GUARDAR
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: listo && !_isSaving ? _guardarConfiguracion : null,
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12)
              ),
              child: _isSaving
                  ? CircularProgressIndicator(color: colorScheme.onPrimary)
                  : Text(listo ? "GUARDAR SECUENCIA" : "Completa la secuencia...", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

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