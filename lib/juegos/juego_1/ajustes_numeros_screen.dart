import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/auxFunc.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/juegos/juego_1/juego_1_screen.dart';

class AjustesNumerosScreen extends StatefulWidget {
  final Juego1Settings initialSettings;
  final bool initialMostrarPuntuacion;

  const AjustesNumerosScreen({
    Key? key,
    required this.initialSettings,
    required this.initialMostrarPuntuacion,
  }) : super(key: key);

  @override
  _AjustesNumerosScreenState createState() => _AjustesNumerosScreenState();
}

class _AjustesNumerosScreenState extends State<AjustesNumerosScreen> {
  late TextEditingController _numeroMayorController;
  late TextEditingController _numeroMenorController;
  late double _numeroOpciones;
  late bool _mostrarPuntuacion;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _numeroMayorController =
        TextEditingController(text: widget.initialSettings.numeroMayor.toString());
    _numeroMenorController =
        TextEditingController(text: widget.initialSettings.numeroMenor.toString());
    _numeroOpciones = widget.initialSettings.numeroOpciones.toDouble();
    _mostrarPuntuacion = widget.initialMostrarPuntuacion;
  }

  @override
  void dispose() {
    _numeroMayorController.dispose();
    _numeroMenorController.dispose();
    super.dispose();
  }

  void _guardarAjustes() {
    if (_formKey.currentState!.validate()) {
      final int numeroMayor = int.tryParse(_numeroMayorController.text) ?? 1000;
      final int numeroMenor = int.tryParse(_numeroMenorController.text) ?? 0;

      if (numeroMenor >= numeroMayor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('El número menor debe ser inferior al número mayor.'),
              backgroundColor: Colors.red),
        );
        return;
      }
      
      final settings = Juego1Settings(
        numeroOpciones: _numeroOpciones.round(),
        numeroMayor: numeroMayor,
        numeroMenor: numeroMenor,
      );
      
      Navigator.of(context).pop({
        'settings': settings,
        'mostrarPuntuacion': _mostrarPuntuacion,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alumno = Provider.of<AlumnoHolder>(context, listen: false).alumno!;
    final Color appBarColor = alumno.colorBarraNav ?? Theme.of(context).colorScheme.primary;
    final Color appBarTextColor = getTextColorForBackground(appBarColor);
    final Color textColor = getTextColorForBackground(alumno.colorFondo ?? Theme.of(context).colorScheme.surface);

    final buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: alumno.colorBotones ?? Theme.of(context).colorScheme.primary,
        foregroundColor: getTextColorForBackground(alumno.colorBotones ?? Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));

    return Scaffold(
      backgroundColor: alumno.colorFondo,
      appBar: AppBar(
        title: Text('Ajustes Números Juego 1', style: TextStyle(color: appBarTextColor)),
        backgroundColor: appBarColor,
        iconTheme: IconThemeData(color: appBarTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _numeroMayorController,
                label: 'Número mayor (máx. 1000)',
                textColor: textColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un número';
                  }
                  final n = int.tryParse(value);
                  if (n == null) return 'Número inválido';
                  if (n > 1000) return 'El máximo es 1000';
                  if (n < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _numeroMenorController,
                label: 'Número menor',
                textColor: textColor,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Introduce un número';
                  }
                  final n = int.tryParse(value);
                  if (n == null) return 'Número inválido';
                  if (n < 0) return 'No puede ser negativo';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSliderTile(
                label: 'Número de opciones:',
                value: _numeroOpciones,
                min: 1,
                max: 10,
                divisions: 9,
                textColor: textColor,
                onChanged: (value) {
                  setState(() {
                    _numeroOpciones = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text('Mostrar Puntuación', style: TextStyle(color: textColor, fontSize: 18)),
                value: _mostrarPuntuacion,
                onChanged: (value) {
                  setState(() {
                    _mostrarPuntuacion = value;
                  });
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: buttonStyle,
                onPressed: _guardarAjustes,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Color textColor,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: validator,
    );
  }

  Widget _buildSliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Color textColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${value.round()}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
