import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego1/juego1.dart';
import 'package:tato_matematico/widgetsAuxiliares/tarjetaJuego.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';

/// **Nombre de la Clase: `Juego1AjustesProfe**
///
/// **Descripción:** Clase usada para la configuracion del juego 1 en el profesor
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Rubi Rodríguez Anguita
/// * **Última modificación por:** Rubi Rodríguez Anguita
/// * **Fecha de modificación:** 18/12/2025
/// * **Último cambio:** Creacion de la clase e implementacion
///
class Juego1AjustesProfe extends StatefulWidget {
  const Juego1AjustesProfe({Key? key}) : super(key: key);

  @override
  State<Juego1AjustesProfe> createState() => _Juego1AjustesProfeState();
}

class _Juego1AjustesProfeState extends State<Juego1AjustesProfe> {
  late Alumno alumno;
  late Juego1 juego;

  // Estado local de ajustes
  late int _numOpciones;
  late int _rangoMax;
  late int _rangoMin;
  late String _temaSeleccionado; // Nuevo estado para el tema

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final tempAlumno = context.read<AlumnoHolder>().alumno!;
    final tempJuego1 =
    context.read<AlumnoHolder>().listaJuegos["juego1"] as Juego1;
    _numOpciones = tempJuego1.cantidad;
    _rangoMax = tempJuego1.max;
    _rangoMin = tempJuego1.min;
    // Inicializamos con el valor actual del juego o por defecto "numeros"
    _temaSeleccionado = tempJuego1.tipoImagenes;
  }

  Future<void> _guardar() async {
    setState(() => _isLoading = true);

    // Determinar si usa imágenes basado en el tema
    bool usaImagenes = _temaSeleccionado != "numeros";


    final dbRef = FirebaseDatabase.instance.ref();

    try {
      // 1. Guardar usando el método de la clase base Juego
      juego.guardarAjustes(
        idAlumno: alumno.id,
        rango: _rangoMax,
        cantidad: _numOpciones,
        tema: _temaSeleccionado,
        dbRef: dbRef,
      );

      // 2. Actualizar objeto localmente para que se vea al volver sin recargar
      juego.tipoImagenes = _temaSeleccionado;
      juego.usaImagenes = usaImagenes;
      juego.max = _rangoMax;
      juego.cantidad = _numOpciones;

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error guardando: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    alumno = context.watch<AlumnoHolder>().alumno!;
    juego = context.watch<AlumnoHolder>().listaJuegos["juego1"] as Juego1;
    PosicionBarra posicionBarra = getPosicionBarra(alumno.posicionBarra);

    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    final Color colorTexto = getTextColorForBackground(
        alumno.colorFondo ?? Theme.of(context).colorScheme.surface);

    return ScaffoldComunV2(
      titulo: "Ajustes - Encuentra el número",
      cuerpo: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SECCIÓN 1: RANGO DE NÚMEROS ---
            _titulo("Rango de números", colorTexto),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _itemRango(10, "0 - 10", Icons.filter_1, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(20, "0 - 20", Icons.filter_2, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(100, "0 - 100", Icons.filter_5, isMobile),
                  const SizedBox(width: 10),
                  _itemRango(1000, "0 - 1000", Icons.filter_9_plus, isMobile),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- SECCIÓN 2: CANTIDAD DE OPCIONES ---
            _titulo("Cantidad de opciones", colorTexto),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _botonStepper(
                    Icons.remove,
                    "MENOS",
                        () {
                      if (_numOpciones > 2) {
                        setState(() => _numOpciones--);
                      }
                    },
                    isMobile,
                    isEnabled: _numOpciones > 2,
                  ),
                  const SizedBox(width: 20),
                  TarjetaJuego(
                    label: _numOpciones.toString(),
                    isButton: false,
                    isEnabled: true,
                    onTap: () {},
                    colorFondo: Colors.white,
                    // Mostramos la imagen seleccionada en el preview si no son números
                    imagenes: _temaSeleccionado != "numeros",
                    tipoImagen: _temaSeleccionado,
                    numero: _numOpciones,
                    tamano: isMobile ? 80 : 100,
                    radio: 20,
                  ),
                  const SizedBox(width: 20),
                  _botonStepper(
                    Icons.add,
                    "MÁS",
                        () {
                      // No permitir más opciones que el rango disponible
                      if (_numOpciones < 12 && _numOpciones < _rangoMax) {
                        setState(() => _numOpciones++);
                      }
                    },
                    isMobile,
                    isEnabled: _numOpciones < 12 && _numOpciones < _rangoMax,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- SECCIÓN 3: TEMÁTICA (NUEVO) ---
            _titulo("Temática del juego", colorTexto),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // Fila 1
                  Expanded(
                    child: Row(
                      children: [
                        _itemTema("numeros", "Números", Icons.onetwothree, isMobile),
                        const SizedBox(width: 8),
                        _itemTema("apple", "Manzana", Icons.apple, isMobile),
                        const SizedBox(width: 8),
                        _itemTema("ball", "Balón", Icons.sports_soccer, isMobile),
                        const SizedBox(width: 8),
                        _itemTema("turtle", "Tortuga", Icons.bug_report, isMobile),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Fila 2
                  Expanded(
                    child: Row(
                      children: [
                        _itemTema("car", "Coche", Icons.directions_car, isMobile),
                        const SizedBox(width: 8),
                        _itemTema("flower", "Flor", Icons.circle, isMobile),
                        const SizedBox(width: 8),
                        // Espaciadores para mantener alineación si faltan items
                        const Spacer(),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _titulo(String texto, Color color) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _itemRango(int maxVal, String label, IconData icon, bool isMobile) {
    // Si hay tema seleccionado (imagenes), solo permitimos rango 10
    bool isEnabled = maxVal == 10 || _temaSeleccionado == 'numeros';
    bool selected = _rangoMax == maxVal;

    return _cardBase(
      selected: selected,
      onTap: () => setState(() => _rangoMax = maxVal),
      icon: icon,
      label: label,
      colorSelected: const Color(0xFFD1FAE5),
      isMobile: isMobile,
      isEnabled: isEnabled,
    );
  }

  Widget _itemTema(String valor, String label, IconData icon, bool isMobile) {
    String? imagePath;
    if (valor != 'numeros') {
      // Usamos el '1' como ejemplo para el icono
      imagePath = "assets/images/1$valor.png";
    }

    return _cardBase(
      selected: _temaSeleccionado == valor,
      onTap: () => setState(() {
        _temaSeleccionado = valor;
        // Si elige imágenes, forzamos rango a 10 y ajustamos cantidad si es necesario
        if (_temaSeleccionado != "numeros") {
          _rangoMax = 10;
          if (_numOpciones > 10) _numOpciones = 10;
        }
      }),
      icon: icon,
      imagePath: imagePath,
      label: label,
      colorSelected: const Color(0xFFFCE7F3),
      isMobile: isMobile,
    );
  }

  Widget _cardBase({
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    String? imagePath,
    required String label,
    Color? colorSelected,
    required bool isMobile,
    bool isEnabled = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.3,
          child: Container(
            decoration: BoxDecoration(
              color: selected
                  ? (colorSelected ?? const Color(0xFFE0E7FF))
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imagePath != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.error, size: isMobile ? 24 : 30),
                      ),
                    ),
                  )
                else
                  Icon(icon, size: isMobile ? 24 : 32, color: Colors.black54),

                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonStepper(
      IconData icon,
      String label,
      VoidCallback onTap,
      bool isMobile, {
        bool isEnabled = true,
      }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.3,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: isMobile ? 24 : 30),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}