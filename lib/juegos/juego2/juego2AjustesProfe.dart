import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';
import 'package:tato_matematico/juegos/tarjetaJuego.dart';

import '../../datos/juego.dart';

/// **Nombre de la Clase: `Juego2AjustesProfe**
///
/// **Descripción:** Clase con el widget de ajustes del juego 2 para el profesor
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se creado la clase
///

class Juego2AjustesProfe extends StatefulWidget {
  final Juego juego;
  const Juego2AjustesProfe({super.key, required this.juego});

  @override
  State<Juego2AjustesProfe> createState() => _Juego2AjustesProfeState();
}

class _Juego2AjustesProfeState extends State<Juego2AjustesProfe> {
  // Estados
  late int _rangoSeleccionado;
  late bool _ordenSeleccionado;
  late int _cantidadPreguntas;
  late String _temaSeleccionado;
  late Alumno alum;
  late Juego2 juego2;

  @override
  void initState() {
    super.initState();
    juego2 = widget.juego as Juego2;
    _rangoSeleccionado = juego2.max;
    _ordenSeleccionado = juego2.ordenDescendente;
    _cantidadPreguntas = juego2.cantidad;
    _temaSeleccionado = juego2.tipoImagenes;
  }

  @override
  Widget build(BuildContext context) {
    alum = context.read<AlumnoHolder>().alumno!;

    // 1. Detectar tamaño de pantalla
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 800; // Punto de corte

    return ScaffoldComunV2(
      titulo: "Juego 2 - Ajustes",
      subtitulo: alum.nombre,
      iconoLeading: Icons.arrow_back,
      funcionLeading: () {
        juego2.guardarAjustes(
          idAlumno: alum.id,
          rango: _rangoSeleccionado,
          cantidad: _cantidadPreguntas,
          tema: _temaSeleccionado,
          dbRef: FirebaseDatabase.instance.ref(),
          orden: _ordenSeleccionado,
        );
        if (mounted) {
          setState(() {
            Navigator.pop(context);
          });
        }
      },
      cuerpo: Padding(
        // Menos padding en móvil para aprovechar espacio
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 32.0,
          vertical: isMobile ? 16.0 : 24.0,
        ),
        child: isMobile ? _buildMobileLayout() : _buildTabletLayout(),
      ),
    );
  }

  // --- LAYOUT MÓVIL (Vertical, Sin Scroll, Compacto) ---
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. INTERVALOS
        _titulo("Intervalo de números"),
        const SizedBox(height: 8),
        Expanded(
          flex: 3, // Peso vertical
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _itemIntervalo(10, "0-10", Icons.filter_1, true),
                    const SizedBox(width: 10),
                    _itemIntervalo(20, "0-20", Icons.filter_2, true),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  children: [
                    _itemIntervalo(100, "0-100", Icons.filter_9_plus, true),
                    const SizedBox(width: 10),
                    _itemIntervalo(1000, "0-1000", Icons.all_inclusive, true),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. ORDEN
        _titulo("Orden"),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              _itemOrden(false, "Menor a mayor", Icons.trending_down, true),
              const SizedBox(width: 10),
              _itemOrden(true, "Mayor a menor", Icons.trending_up, true),
            ],
          ),
        ),

        // 3. CANTIDAD (Stepper)
        _titulo("Número de opciones"),
        const SizedBox(height: 8),
        SizedBox(
          height: 80, // Altura fija compacta
          child: Row(
            children: [
              _botonStepper(
                Icons.remove,
                "MENOS",
                () {
                  if (_cantidadPreguntas > 2) {
                    setState(() => _cantidadPreguntas--);
                  }
                },
                true,
                isEnabled: _cantidadPreguntas > 2,
              ),
              const SizedBox(width: 16),

              TarjetaJuego(
                label: _cantidadPreguntas.toString(),
                isButton: false,
                isEnabled: true,
                onTap: () {},
                colorFondo: Colors.white,
                imagenes: _temaSeleccionado != "numeros",
                tipoImagen: _temaSeleccionado,
                numero: _cantidadPreguntas,
                tamano: 120,
                radio: 20,
              ),

              const SizedBox(width: 16),
              _botonStepper(
                Icons.add,
                "MAS",
                () {
                  if (_cantidadPreguntas < _rangoSeleccionado &&
                      _cantidadPreguntas < 12) {
                    setState(() => _cantidadPreguntas++);
                  }
                },
                true,
                isEnabled:
                    _cantidadPreguntas < _rangoSeleccionado &&
                    _cantidadPreguntas < 12,
              ),
            ],
          ),
        ),

        // 4. TEMÁTICA
        _titulo("Temática del juego"),
        const SizedBox(height: 8),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Fila 1 (3 elementos)
              Expanded(
                child: Row(
                  children: [
                    _itemTema("numeros", "Números", Icons.onetwothree, true),
                    const SizedBox(width: 10),
                    _itemTema("apple", "Manzana", Icons.apple, true),
                    const SizedBox(width: 10),
                    _itemTema("ball", "Balón", Icons.sports_soccer, true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Fila 2 (2 elementos)
              Expanded(
                child: Row(
                  children: [
                    _itemTema("car", "Coche", Icons.directions_car, true),
                    const SizedBox(width: 10),
                    _itemTema("flower", "Flor", Icons.circle, true),
                    const SizedBox(width: 10),
                    _itemTema("turtle", "Tortuga", Icons.bug_report, true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- LAYOUT TABLET (Original) ---
  Widget _buildTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ZONA SUPERIOR (Intervalos + Orden y Cantidad)
        Expanded(
          flex:
              1, // Ajusta este flex si quieres que la parte de arriba sea más alta
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IZQUIERDA: Intervalo de números (4 items)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titulo("Intervalo de números"),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Column(
                        children: [
                          // FILA 1: Envuelta en Expanded para ocupar el 50% de la altura
                          Expanded(
                            child: Row(
                              children: [
                                _itemIntervalo(
                                  10,
                                  "0-10",
                                  Icons.filter_1,
                                  false,
                                ),
                                const SizedBox(width: 10), // Espacio horizontal
                                _itemIntervalo(
                                  20,
                                  "0-20",
                                  Icons.filter_2,
                                  false,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ), // Espacio vertical entre filas
                          // FILA 2: Envuelta en Expanded para ocupar el otro 50%
                          Expanded(
                            child: Row(
                              children: [
                                _itemIntervalo(
                                  100,
                                  "0-100",
                                  Icons.filter_9_plus,
                                  false,
                                ),
                                const SizedBox(width: 10), // Espacio horizontal
                                _itemIntervalo(
                                  1000,
                                  "0-1000",
                                  Icons.all_inclusive,
                                  false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // DERECHA: Orden y Cantidad
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN ORDEN
                    _titulo("Orden"),
                    const SizedBox(height: 10),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          _itemOrden(
                            false,
                            "Menor a mayor",
                            Icons.trending_down,
                            false,
                          ),
                          const SizedBox(width: 10),
                          _itemOrden(
                            true,
                            "Mayor a menor",
                            Icons.trending_up,
                            false,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // SECCIÓN CANTIDAD
                    Expanded(
                      flex: 2, // Le damos más altura a la sección del stepper
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _titulo("Número de opciones"),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Row(
                              children: [
                                _botonStepper(
                                  Icons.remove,
                                  "MENOS",
                                  () {
                                    if (_cantidadPreguntas > 2) {
                                      setState(() => _cantidadPreguntas--);
                                    }
                                  },
                                  false,
                                  isEnabled: _cantidadPreguntas > 2,
                                ),
                                const SizedBox(width: 20),
                                TarjetaJuego(
                                  label: _cantidadPreguntas.toString(),
                                  isButton: false,
                                  isEnabled: true,
                                  onTap: () {},
                                  colorFondo: Colors.white,
                                  imagenes: _temaSeleccionado != "numeros",
                                  tipoImagen: _temaSeleccionado,
                                  numero: _cantidadPreguntas,
                                  tamano: 120,
                                  radio: 20,
                                ),
                                const SizedBox(width: 20),
                                _botonStepper(
                                  Icons.add,
                                  "MAS",
                                  () {
                                    if (_cantidadPreguntas <
                                            _rangoSeleccionado &&
                                        _cantidadPreguntas < 12) {
                                      setState(() => _cantidadPreguntas++);
                                    }
                                  },
                                  false,
                                  isEnabled:
                                      _cantidadPreguntas < _rangoSeleccionado &&
                                      _cantidadPreguntas < 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ZONA INFERIOR (Temática)
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _titulo("Temática del juego"),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _itemTema("numeros", "Números", Icons.onetwothree, false),
                    const SizedBox(width: 8),
                    _itemTema("apple", "Manzana", Icons.apple, false),
                    const SizedBox(width: 8),
                    _itemTema("ball", "Balón", Icons.sports_soccer, false),
                    const SizedBox(width: 8),
                    _itemTema("turtle", "Tortuga", Icons.bug_report, false),
                    const SizedBox(width: 8),
                    _itemTema("car", "Coche", Icons.directions_car, false),
                    const SizedBox(width: 8),
                    _itemTema("flower", "Flor", Icons.circle, false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGETS PERSONALIZADOS ---

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.black54,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _espacio() => const SizedBox(width: 10);

  // Modificado: Acepta 'isMobile' para ajustar tamaños
  Widget _cardBase({
    required bool selected,
    required VoidCallback onTap,
    IconData? icon, // Ahora es opcional
    String? imagePath, // Nuevo parámetro para la imagen
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
                // LOGICA: Si hay imagen, muéstrala. Si no, muestra el icono.
                if (imagePath != null)
                  Image.asset(
                    imagePath,
                    width: isMobile ? 32 : 48, // Tamaño adaptable
                    height: isMobile ? 32 : 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error, size: isMobile ? 24 : 32),
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

  Widget _itemIntervalo(int valor, String label, IconData icon, bool isMobile) {
    bool isEnabled = valor == 10 || _temaSeleccionado == 'numeros';

    return _cardBase(
      selected: _rangoSeleccionado == valor,
      onTap: () => setState(() => _rangoSeleccionado = valor),
      icon: icon,
      label: label,
      colorSelected: const Color(0xFFD1FAE5),
      isMobile: isMobile,
      isEnabled: isEnabled,
    );
  }

  Widget _itemOrden(bool valor, String label, IconData icon, bool isMobile) {
    return _cardBase(
      selected: _ordenSeleccionado == valor,
      onTap: () => setState(() {
        _ordenSeleccionado = valor;
      }),
      icon: icon,
      label: label,
      colorSelected: const Color(0xFFE0E7FF),
      isMobile: isMobile,
    );
  }

  Widget _itemTema(String valor, String label, IconData icon, bool isMobile) {
    String? imagePath;
    if (valor != 'numeros') {
      imagePath = "assets/images/1$valor.png";
    }

    return _cardBase(
      selected: _temaSeleccionado == valor,
      onTap: () => setState(() {
        _temaSeleccionado = valor;
        if (_temaSeleccionado != "numeros") {
          _rangoSeleccionado = 10;
          if (_cantidadPreguntas > 10) _cantidadPreguntas = 10;
        }
      }),
      icon: icon,
      imagePath: imagePath,
      label: label,
      colorSelected: const Color(0xFFFCE7F3),
      isMobile: isMobile,
    );
  }

  Widget _botonStepper(
    IconData icon,
    String label,
    VoidCallback onTap,
    bool isMobile, {
    bool isEnabled = true,
  }) {
    return Expanded(
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        child: Opacity(
          // Si no está habilitado, se ve transparente
          opacity: isEnabled ? 1.0 : 0.3,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: isMobile ? 20 : 48.0),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 22.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
