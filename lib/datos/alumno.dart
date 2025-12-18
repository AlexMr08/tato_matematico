import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';
import 'package:tato_matematico/widgetsAuxiliares/fotoPerfil.dart';

import '../juegos/juego_1/juego1_settings.dart';

/// **Nombre de la Clase: `Alumno`**
///
/// **Descripción:** clase que representa a un alumno en el sistema.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha eliminado el volverDerecha
///

class Alumno {
  String id;
  String nombre;
  String? _imagen;
  String imagenLocal = '';
  File? foto;

  // --- COLORES ---
  Color? colorFondo;
  Color? colorBarraNav;
  Color? colorBotones;
  Color? colorSeleccion;
  Color? colorContenedor;

  // --- AJUSTES DE INTERFAZ ---
  bool volverDerecha = false;
  int? posicionBarra;

  // --- AJUSTES GLOBALES DE SONIDO Y VOZ (Lógica Source A - Centralizada) ---
  String? sonidoEleccion;
  String sonidoAcierto;
  bool sonidoAciertoActivado;
  String sonidoFallo;
  bool sonidoFalloActivado;
  String? voz;
  double ttsRate;
  double ttsVolume;
  double ttsPitch;

  // --- PERMISOS GLOBALES ---
  bool permisoColor;
  bool permisoSonido;

  // --- AJUSTES Y PERMISOS POR JUEGO ---
  bool permisoAjustesJuego1;
  bool permisoAjustesJuego2;
  bool permisoAjustesJuego3;
  bool permisoAjustesJuego4;

  Alumno({
    required this.id,
    required this.nombre,
    String? imagen, // Se pasa al inicializador
    this.colorFondo,
    this.colorBarraNav,
    this.colorBotones,
    this.colorSeleccion,
    this.colorContenedor,
    this.volverDerecha = false,
    this.posicionBarra,

    // Globales
    this.permisoColor = true,
    this.permisoSonido = true,
    this.sonidoEleccion,
    this.sonidoAcierto = 'Pim',
    this.sonidoAciertoActivado = true,
    this.sonidoFallo = 'Pton',
    this.sonidoFalloActivado = true,
    this.voz,
    this.ttsRate = 0.5,
    this.ttsVolume = 1.0,
    this.ttsPitch = 1.0,

    // Juego 1
    this.permisoAjustesJuego1 = true,
    Juego1Settings? juego1Settings,

    // Otros juegos
    this.permisoAjustesJuego2 = true,
    this.permisoAjustesJuego3 = true,
    this.permisoAjustesJuego4 = true,
  }) : _imagen = imagen;

  // --- GETTERS Y SETTERS DE IMAGEN (Lógica Source B) ---
  String? get imagen => _imagen;

  set imagen(String? value) {
    if (_imagen != value) {
      _imagen = value;
      // Al cambiar la URL, invalidamos la caché en memoria y disco
      foto = null;
      _cachedImage = null;
    }
  }

  // --- COMPATIBILIDAD HACIA ATRÁS (Mapping Source A) ---
  // Estos getters permiten que el código antiguo que busca "ttsRateJuego1" siga funcionando,
  // pero leyendo/escribiendo en la variable global.

  Color? get colorTextos => colorSeleccion;
  set colorTextos(Color? value) => colorSeleccion = value;

  double get ttsRateJuego1 => ttsRate;
  set ttsRateJuego1(double value) => ttsRate = value;

  double get ttsVolumeJuego1 => ttsVolume;
  set ttsVolumeJuego1(double value) => ttsVolume = value;

  double get ttsPitchJuego1 => ttsPitch;
  set ttsPitchJuego1(double value) => ttsPitch = value;

  String? get vozJuego1 => voz;
  set vozJuego1(String? value) => voz = value;

  String get sonidoAciertoJuego1 => sonidoAcierto;
  set sonidoAciertoJuego1(String value) => sonidoAcierto = value;

  bool get sonidoAciertoActivadoJuego1 => sonidoAciertoActivado;
  set sonidoAciertoActivadoJuego1(bool value) => sonidoAciertoActivado = value;

  String get sonidoFalloJuego1 => sonidoFallo;
  set sonidoFalloJuego1(String value) => sonidoFallo = value;

  bool get sonidoFalloActivadoJuego1 => sonidoFalloActivado;
  set sonidoFalloActivadoJuego1(bool value) => sonidoFalloActivado = value;

  String? get sonidoEleccionJuego1 => sonidoEleccion;
  set sonidoEleccionJuego1(String? value) => sonidoEleccion = value;

  // --- LOGICA DE IMAGEN Y CACHÉ (Source B) ---

  // Cache para widgetProfesor/widgetAlumno
  ImageProvider? _cachedImage;

  ImageProvider? get cachedImage {
    if (imagenLocal.isEmpty) _cachedImage = null;
    _cachedImage ??= FileImage(File(imagenLocal));
    return _cachedImage;
  }

  void invalidarCachedImage() {
    _cachedImage = null;
    foto = null;
  }

  Future<void> descargarImagen(
    Directory tempDir, {
    int maxBytes = 10 * 1024 * 1024,
  }) async {
    if (_imagen == null || _imagen!.isEmpty) {
      imagenLocal = '';
      return;
    }

    try {
      final storage = FirebaseStorage.instance;
      Reference ref = storage.refFromURL(_imagen!);
      final Uint8List? bytes = await ref.getData(maxBytes);
      if (bytes == null) {
        imagenLocal = '';
        return;
      }

      String nombreArchivo = ref.name;
      final file = File('${tempDir.path}/$nombreArchivo');

      await file.writeAsBytes(bytes, flush: true);
      imagenLocal = file.path;
    } catch (e) {
      imagenLocal = '';
      return;
    }
  }

  Future<File?> obtenerImagen(Directory tempDir) async {
    // 1. Caché en RAM
    if (foto != null) return foto;

    // 2. Caché en Disco
    if (imagenLocal.isNotEmpty) {
      final archivoDisco = File(imagenLocal);
      if (await archivoDisco.exists()) {
        foto = archivoDisco;
        return foto;
      }
    }

    // 3. Descarga
    await descargarImagen(tempDir);
    if (imagenLocal.isNotEmpty) {
      final archivoRecienDescargado = File(imagenLocal);
      if (await archivoRecienDescargado.exists()) {
        foto = archivoRecienDescargado;
      }
    }
    return foto;
  }

  // --- CONVERSIÓN DE DATOS (Fusión) ---

  factory Alumno.fromMap(String id, Map<dynamic, dynamic> data) {
    // Helper para parsear colores de forma segura (Source B)
    Color? parseColor(dynamic hexString) {
      if (hexString is String && hexString.isNotEmpty) {
        try {
          return Color(int.parse(hexString, radix: 16));
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    Juego1Settings? juego1Settings;
    if (data['juego1Settings'] != null) {
      final settingsMap = data['juego1Settings'] as Map<dynamic, dynamic>;
      juego1Settings = Juego1Settings(
        numeroOpciones: settingsMap['numeroOpciones'] ?? 4,
        numeroMayor: settingsMap['numeroMayor'] ?? 10,
        numeroMenor: settingsMap['numeroMenor'] ?? 0,
      );
    }

    // Retorna Alumno con lógica de fallback (si no existe global, busca el antiguo Juego1)
    return Alumno(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      imagen: data['imagen'],
      volverDerecha: data['volverDerecha'] ?? false,

      colorFondo: parseColor(data['colorFondo']),
      colorBarraNav: parseColor(data['colorBarraNav']),
      colorBotones: parseColor(data['colorBotones']),
      colorSeleccion: parseColor(data['colorSeleccion']),
      colorContenedor: parseColor(data['colorContenedor']),

      posicionBarra: data['posicionBarra'],

      permisoColor: data['permisoColor'] ?? true,
      permisoSonido: data['permisoSonido'] ?? true,

      permisoAjustesJuego1: data['permisoAjustesJuego1'] ?? true,
      permisoAjustesJuego2: data['permisoAjustesJuego2'] ?? true,
      permisoAjustesJuego3: data['permisoAjustesJuego3'] ?? true,
      permisoAjustesJuego4: data['permisoAjustesJuego4'] ?? true,

      // Mapeo inteligente: Usa el valor global nuevo, si no existe, usa el antiguo de juego1
      sonidoEleccion: data['sonidoEleccion'] ?? data['sonidoEleccionJuego1'],
      sonidoAcierto:
          data['sonidoAcierto'] ?? data['sonidoAciertoJuego1'] ?? 'Pim',
      sonidoAciertoActivado:
          data['sonidoAciertoActivado'] ??
          data['sonidoAciertoActivadoJuego1'] ??
          true,
      sonidoFallo: data['sonidoFallo'] ?? data['sonidoFalloJuego1'] ?? 'Pton',
      sonidoFalloActivado:
          data['sonidoFalloActivado'] ??
          data['sonidoFalloActivadoJuego1'] ??
          true,

      voz: data['voz'] ?? data['vozJuego1'],
      ttsRate: (data['ttsRate'] as num? ?? data['ttsRateJuego1'] as num? ?? 0.5)
          .toDouble(),
      ttsVolume:
          (data['ttsVolume'] as num? ?? data['ttsVolumeJuego1'] as num? ?? 1.0)
              .toDouble(),
      ttsPitch:
          (data['ttsPitch'] as num? ?? data['ttsPitchJuego1'] as num? ?? 1.0)
              .toDouble(),

      juego1Settings: juego1Settings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'imagen': _imagen,
      'colorFondo': colorFondo?.value.toRadixString(16),
      'colorBarraNav': colorBarraNav?.value.toRadixString(16),
      'colorBotones': colorBotones?.value.toRadixString(16),
      'colorSeleccion': colorSeleccion?.value.toRadixString(16),
      'colorContenedor': colorContenedor?.value.toRadixString(16),
      'volverDerecha': volverDerecha,
      'posicionBarra': posicionBarra,

      'permisoColor': permisoColor,
      'permisoSonido': permisoSonido,

      'permisoAjustesJuego1': permisoAjustesJuego1,

      'permisoAjustesJuego2': permisoAjustesJuego2,
      'permisoAjustesJuego3': permisoAjustesJuego3,
      'permisoAjustesJuego4': permisoAjustesJuego4,

      'sonidoEleccion': sonidoEleccion,
      'sonidoAcierto': sonidoAcierto,
      'sonidoAciertoActivado': sonidoAciertoActivado,
      'sonidoFallo': sonidoFallo,
      'sonidoFalloActivado': sonidoFalloActivado,
      'voz': voz,
      'ttsRate': ttsRate,
      'ttsVolume': ttsVolume,
      'ttsPitch': ttsPitch,
    };
  }

  @override
  String toString() {
    return 'Alumno{id: $id, nombre: $nombre, imagen: $_imagen}';
  }
}

/// **Nombre de la Clase: `AlumnViewCard`**
///
/// **Descripción:** clase que gestiona como se ve el widget del alumno en vista de alumno.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 30/11/2025
/// * **Último cambio:** Se ha añadido la descripcion y metadatos de control
///
class AlumnViewCard extends StatelessWidget {
  final Alumno alumno;
  final VoidCallback onTap;

  const AlumnViewCard({super.key, required this.alumno, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              Expanded(
                child: FotoPerfil(
                  key: ValueKey(alumno.imagen),
                  nombre: alumno.nombre,
                  idUnico: alumno.imagen ?? alumno.id,
                  onObtenerImagen: alumno.obtenerImagen,
                  radio: 56,
                ),
              ),
              Text(
                alumno.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **Nombre de la Clase: `TeacherViewCard`**
///
/// **Descripción:** clase que gestiona la vista de un alumno en la perspectiva del profesor.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 13/12/2025
/// * **Último cambio:** Se ha añadido un boton para acceder a las estadisticas
///

class TeacherViewCard extends StatefulWidget {
  final Alumno alumno;
  final Icon icono;
  final VoidCallback onTap;
  final VoidCallback onEstadisticasTap;
  final bool verStats;

  const TeacherViewCard({
    super.key,
    required this.alumno,
    required this.onTap,
    required this.icono,
    required this.onEstadisticasTap,
    this.verStats = false,
  });

  @override
  State<TeacherViewCard> createState() => _TeacherViewCardState();
}

class _TeacherViewCardState extends State<TeacherViewCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: FotoPerfil(
          key: ValueKey(widget.alumno.imagen ?? widget.alumno.id),
          nombre: widget.alumno.nombre,
          idUnico: widget.alumno.imagen ?? widget.alumno.id,
          onObtenerImagen: widget.alumno.obtenerImagen,
          radio: 28,
        ),
        title: Text(
          widget.alumno.nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Corrección de sintaxis: Collection-if estándar de Dart
            if (widget.verStats)
              IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Ver Estadísticas',
                onPressed: widget.onEstadisticasTap,
              ),
            IconButton(icon: widget.icono, onPressed: widget.onTap),
          ],
        ),
        onTap:
            null, // Si quieres que toda la tarjeta sea cliqueable, asigna widget.onTap aquí
      ),
    );
  }
}
