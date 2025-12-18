import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldAlumno.dart';

class AjustesSonidosScreen extends StatefulWidget {
  const AjustesSonidosScreen({Key? key}) : super(key: key);

  @override
  _AjustesSonidosScreenState createState() => _AjustesSonidosScreenState();
}

class _AjustesSonidosScreenState extends State<AjustesSonidosScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  late Alumno _alumno;

  // State for global sounds - Ahora no son nulos
  String _sonidoEleccion = 'ninguno';
  String _sonidoVictoria = 'ninguno';
  String _sonidoFallo = 'ninguno';

  // State for global TTS
  double _ttsRate = 0.5;
  double _ttsVolume = 1.0;
  double _ttsPitch = 1.0;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, String>> availableSounds = [
    {'name': 'ninguno', 'asset': 'assets/images/silencio.png'},
    {'name': 'campana', 'asset': 'assets/images/campana.png'},
    {'name': 'electricidad', 'asset': 'assets/images/electricidad.png'},
    {'name': 'gota', 'asset': 'assets/images/gota.png'},
    {'name': 'estrella', 'asset': 'assets/images/estrella.png'},
    {'name': 'piano', 'asset': 'assets/images/piano.png'},
    {'name': 'juego', 'asset': 'assets/images/juego.png'},
  ];

  final List<Map<String, dynamic>> ttsRateOptions = [
    {'value': 0.5, 'asset': 'assets/images/tortuga.png'},
    {'value': 0.8, 'asset': 'assets/images/liebre.png'},
    {'value': 1.0, 'asset': 'assets/images/leopardo.png'},
  ];

  final List<Map<String, dynamic>> ttsVolumeOptions = [
    {'value': 0.33, 'asset': 'assets/images/volumen_1.png'},
    {'value': 0.66, 'asset': 'assets/images/volumen_2.png'},
    {'value': 1.0, 'asset': 'assets/images/volumen_3.png'},
  ];

  final List<Map<String, dynamic>> ttsPitchOptions = [
    {'value': 0.8, 'asset': 'assets/images/hombre.png'},
    {'value': 1.5, 'asset': 'assets/images/mujer.png'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _setupTts();
  }

  void _setupTts() async {
    await _flutterTts.awaitSpeakCompletion(true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _initializeSettings() {
    _alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;

    _sonidoEleccion = (_alumno.sonidoEleccion?.isNotEmpty ?? false) ? _alumno.sonidoEleccion! : 'ninguno';
    _sonidoVictoria = _alumno.sonidoAciertoActivado && _alumno.sonidoAcierto.isNotEmpty ? _alumno.sonidoAcierto : 'ninguno';
    _sonidoFallo = _alumno.sonidoFalloActivado && _alumno.sonidoFallo.isNotEmpty ? _alumno.sonidoFallo : 'ninguno';

    _ttsRate = _alumno.ttsRate;
    _ttsVolume = _alumno.ttsVolume;
    _ttsPitch = _alumno.ttsPitch;
  }

  void _speakPreview() async {
    await _flutterTts.setVolume(_ttsVolume);
    await _flutterTts.setSpeechRate(_ttsRate);
    await _flutterTts.setPitch(_ttsPitch);
    await _flutterTts.speak("Hola");
  }

  void _guardarAjustes() async {
    final isVictoriaNone = _sonidoVictoria == 'ninguno';
    final isFalloNone = _sonidoFallo == 'ninguno';
    final isEleccionNone = _sonidoEleccion == 'ninguno';

    final updates = {
      'sonidoEleccion': isEleccionNone ? null : _sonidoEleccion,
      'sonidoAcierto': isVictoriaNone ? '' : _sonidoVictoria,
      'sonidoAciertoActivado': !isVictoriaNone,
      'sonidoFallo': isFalloNone ? '' : _sonidoFallo,
      'sonidoFalloActivado': !isFalloNone,
      'ttsRate': _ttsRate,
      'ttsVolume': _ttsVolume,
      'ttsPitch': _ttsPitch,
    };

    try {
      await _dbRef.child('tato/alumnos/${_alumno.id}').update(updates);

      _alumno.sonidoEleccion = isEleccionNone ? null : _sonidoEleccion;
      _alumno.sonidoAcierto = isVictoriaNone ? '' : _sonidoVictoria;
      _alumno.sonidoAciertoActivado = !isVictoriaNone;
      _alumno.sonidoFallo = isFalloNone ? '' : _sonidoFallo;
      _alumno.sonidoFalloActivado = !isFalloNone;
      _alumno.ttsRate = _ttsRate;
      _alumno.ttsVolume = _ttsVolume;
      _alumno.ttsPitch = _ttsPitch;
      context.read<AlumnoHolder>().setAlumno(_alumno);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    final Color textColor = getTextColorForBackground(alumno.colorFondo ?? Theme.of(context).colorScheme.surface);
    final Color selectionColor = alumno.colorSeleccion ?? Theme.of(context).colorScheme.tertiaryContainer;

    return ScaffoldAlumno(
      alumno: alumno,
      textoCabecera: "Ajustes de sonido",
      hasAjustes: false,
      hasEstadisticas: false,
      onAjustes: (){},
      onEstadisticas: (){},
      posicion: getPosicionBarra(alumno.posicionBarra),
      onVolver: () {
        _guardarAjustes();
      },
      floatingActionButton: null,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildTtsColumn(context, textColor, selectionColor)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: _buildSoundsColumn(context, textColor, selectionColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsColumn(BuildContext context, Color textColor, Color selectionColor) {
    return Column(
      children: [
        Text("Voz", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTtsImageSelector(title: "Velocidad", options: ttsRateOptions, currentValue: _ttsRate, onSelected: (value) { setState(() { _ttsRate = value; }); _speakPreview(); }, textColor: textColor, selectionColor: selectionColor),
        const SizedBox(height: 30),
        _buildTtsImageSelector(title: "Volumen", options: ttsVolumeOptions, currentValue: _ttsVolume, onSelected: (value) { setState(() { _ttsVolume = value; }); _speakPreview(); }, textColor: textColor, selectionColor: selectionColor),
        const SizedBox(height: 30),
        _buildTtsImageSelector(title: "Tono", options: ttsPitchOptions, currentValue: _ttsPitch, onSelected: (value) { setState(() { _ttsPitch = value; }); _speakPreview(); }, textColor: textColor, selectionColor: selectionColor),
      ],
    );
  }

  Widget _buildSoundsColumn(BuildContext context, Color textColor, Color selectionColor) {
    return Column(
      children: [
        Text("Sonidos", style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildSoundEffectSelector(title: 'Elección', icon: Icons.touch_app, selectedSound: _sonidoEleccion, onSoundSelected: (sound) => setState(() => _sonidoEleccion = sound), textColor: textColor, selectionColor: selectionColor),
        const SizedBox(height: 30),
        _buildSoundEffectSelector(title: 'Victoria', icon: Icons.check, selectedSound: _sonidoVictoria, onSoundSelected: (sound) => setState(() => _sonidoVictoria = sound), textColor: textColor, selectionColor: selectionColor),
        const SizedBox(height: 30),
        _buildSoundEffectSelector(title: 'Fallo', icon: Icons.close, selectedSound: _sonidoFallo, onSoundSelected: (sound) => setState(() => _sonidoFallo = sound), textColor: textColor, selectionColor: selectionColor),
      ],
    );
  }

  Widget _buildSoundEffectSelector({ required String title, required IconData icon, required String selectedSound, required Function(String sound) onSoundSelected, required Color textColor, required Color selectionColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Icon(icon, color: textColor)]),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: availableSounds.map((sound) {
            final soundName = sound['name']!;
            final isSelected = selectedSound == soundName;
            return GestureDetector(
              onTap: () async {
                onSoundSelected(soundName);
                if (soundName != 'ninguno') {
                  try {
                    await _audioPlayer.play(AssetSource('sounds/$soundName.mp3'));
                  } catch (e) {
                    print('Error al reproducir el sonido: $e');
                  }
                }
              },
              child: _buildImageFrame(asset: sound['asset']!, isSelected: isSelected, selectionColor: selectionColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTtsImageSelector({ required String title, required List<Map<String, dynamic>> options, required double currentValue, required Function(double) onSelected, required Color textColor, required Color selectionColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: options.map((option) {
            final isSelected = currentValue == option['value'];
            return GestureDetector(
              onTap: () => onSelected(option['value']),
              child: _buildImageFrame(asset: option['asset']!, isSelected: isSelected, selectionColor: selectionColor),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImageFrame({ required String asset, required bool isSelected, required Color selectionColor}) {
    return Container(
      width: 85,
      height: 85,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: isSelected ? selectionColor : Colors.grey, width: isSelected ? 4.0 : 2.0), borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(asset, fit: BoxFit.contain),
      ),
    );
  }
}
