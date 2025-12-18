import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tato_matematico/widgetsAuxiliares/ScaffoldComunV2.dart';

/// **Nombre de la Clase: `AjustesSonidosProfesor`**
///
/// **Descripción:** clase que permite editar los sonidos del alumno al profesor.
///
/// ---
/// **Metadatos de Control:**
/// * **Autor Original:** Alejandro Molina Ruiz
/// * **Última modificación por:** Alejandro Molina Ruiz
/// * **Fecha de modificación:** 14/12/2025
/// * **Último cambio:** Se ha creado en base a la version antigua

class AjustesSonidosProfesor extends StatefulWidget {
  const AjustesSonidosProfesor({super.key});

  @override
  _AjustesSonidosProfesorState createState() => _AjustesSonidosProfesorState();
}

class _AjustesSonidosProfesorState extends State<AjustesSonidosProfesor> {
  final FlutterTts _flutterTts = FlutterTts();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  late Alumno _alumno;

  // TTS specific settings
  double _rate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;

  // Placeholder sound settings
  String _audioAcierto = 'Pim';
  bool _audioAciertoActivado = true;
  String _audioFallo = 'Pton';
  bool _audioFalloActivado = true;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    _alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;

    _rate = _alumno.ttsRateJuego1;
    _volume = _alumno.ttsVolumeJuego1;
    _pitch = _alumno.ttsPitchJuego1;

    _audioAcierto = _alumno.sonidoAciertoJuego1;
    _audioAciertoActivado = _alumno.sonidoAciertoActivadoJuego1;
    _audioFallo = _alumno.sonidoFalloJuego1;
    _audioFalloActivado = _alumno.sonidoFalloActivadoJuego1;
  }

  void _guardarAjustes() async {
    final updates = {
      'ttsRateJuego1': _rate,
      'ttsVolumeJuego1': _volume,
      'ttsPitchJuego1': _pitch,
      'sonidoAciertoJuego1': _audioAcierto,
      'sonidoAciertoActivadoJuego1': _audioAciertoActivado,
      'sonidoFalloJuego1': _audioFallo,
      'sonidoFalloActivadoJuego1': _audioFalloActivado,
    };

    try {
      await _dbRef.child('tato/alumnos/${_alumno.id}').update(updates);

      _alumno.ttsRateJuego1 = _rate;
      _alumno.ttsVolumeJuego1 = _volume;
      _alumno.ttsPitchJuego1 = _pitch;
      _alumno.sonidoAciertoJuego1 = _audioAcierto;
      _alumno.sonidoAciertoActivadoJuego1 = _audioAciertoActivado;
      _alumno.sonidoFalloJuego1 = _audioFallo;
      _alumno.sonidoFalloActivadoJuego1 = _audioFalloActivado;
      context.read<AlumnoHolder>().setAlumno(_alumno);

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumno = context.watch<AlumnoHolder>().alumno!;

    final Color textColor = getTextColorForBackground(
      alumno.colorFondo ?? Theme.of(context).colorScheme.surface,
    );
    final Color buttonColor =
        alumno.colorBotones ?? Theme.of(context).colorScheme.primary;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: getTextColorForBackground(buttonColor),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );

    return ScaffoldComunV2(
      titulo: "Ajustes de Sonido",
      cuerpo: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Voz (TTS)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildSliderTile(
            "Velocidad",
            _rate,
            0.0,
            1.0,
            (val) => setState(() => _rate = val),
            textColor,
          ),
          _buildSliderTile(
            "Volumen",
            _volume,
            0.0,
            1.0,
            (val) => setState(() => _volume = val),
            textColor,
          ),
          _buildSliderTile(
            "Tono",
            _pitch,
            0.5,
            2.0,
            (val) => setState(() => _pitch = val),
            textColor,
          ),
          const Divider(height: 40, thickness: 1),
          Text(
            'Sonidos de la aplicación',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSoundEffectDropdown(
            label: 'Audio de acierto:',
            value: _audioAcierto,
            isActivated: _audioAciertoActivado,
            onChanged: (val) => setState(() => _audioAcierto = val!),
            onActivationChanged: (val) =>
                setState(() => _audioAciertoActivado = val!),
            cardColor: buttonColor,
          ),
          _buildSoundEffectDropdown(
            label: 'Audio de fallo:',
            value: _audioFallo,
            isActivated: _audioFalloActivado,
            onChanged: (val) => setState(() => _audioFallo = val!),
            onActivationChanged: (val) =>
                setState(() => _audioFalloActivado = val!),
            cardColor: buttonColor,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: buttonStyle,
            onPressed: _guardarAjustes,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    Color textColor,
  ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        label: value.toStringAsFixed(2),
        divisions: 10,
        onChanged: onChanged,
      ),
      trailing: Text(
        value.toStringAsFixed(2),
        style: TextStyle(color: textColor, fontSize: 16),
      ),
    );
  }

  Widget _buildSoundEffectDropdown({
    required String label,
    required String value,
    required bool isActivated,
    required ValueChanged<String?> onChanged,
    required ValueChanged<bool?> onActivationChanged,
    required Color cardColor,
  }) {
    final Color contentColor = getTextColorForBackground(cardColor);
    return Card(
      color: cardColor,
      child: SwitchListTile(
        title: Text(label, style: TextStyle(color: contentColor, fontSize: 18)),
        value: isActivated,
        onChanged: onActivationChanged,
        activeColor: contentColor,
        activeTrackColor: contentColor.withOpacity(0.5),
        secondary: DropdownButton<String>(
          value: value,
          style: TextStyle(color: contentColor, fontSize: 16),
          dropdownColor: cardColor,
          iconEnabledColor: contentColor,
          items: ['Pim', 'Pam', 'Pton'].map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: isActivated ? onChanged : null,
        ),
      ),
    );
  }
}
