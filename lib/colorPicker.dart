import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tato_matematico/ScaffoldComun.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/holders/alumnoHolder.dart';
import 'package:tato_matematico/auxFunc.dart';

class ConfigColor extends StatefulWidget {
  final Alumno? alum;

  _ConfigColorState createState() => _ConfigColorState();

  const ConfigColor({super.key, this.alum});
}

class _ConfigColorState extends State<ConfigColor> {
  late AlumnoHolder alumnoHolder;
  @override
  void initState() {
    super.initState();
  }

  void _showColorPicker(String ref, String cadena, Color color) {
    Color pickerColor = color;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(cadena),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setState(() => pickerColor = color);
                },
                pickerAreaHeightPercent: 0.8,
              ),
            );
          },
        ),
        actions: [
          ElevatedButton(
            child: const Text('Select'),
            onPressed: () {
              var dbref = FirebaseDatabase.instance.ref();
              dbref
                  .child("tato")
                  .child("alumnos")
                  .child(alumnoHolder.alumno!.id)
                  .update({ref: pickerColor.toHex(leadingHashSign: false)});
              setState(() {
                switch (ref) {
                  case "colorFondo":
                    alumnoHolder.setColorFondo(pickerColor);
                    break;
                  case "colorBarraNav":
                    alumnoHolder.setBarraNav(pickerColor);
                    break;
                  case "colorBotones":
                    alumnoHolder.setColorBotones(pickerColor);
                    break;
                  default:
                    break;
                }
              });
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _colorTile(String ref, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        InkWell(
          onTap: () => _showColorPicker(
            ref,
            label,
            color,
          ),
          child: Container(
            width: 128,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Alumno alumno;
    alumnoHolder = context.read<AlumnoHolder>();
    if(widget.alum != null){
      alumno = widget.alum!;
    }else{
      alumno = alumnoHolder.alumno!;
    }


    return ScaffoldComun(
      titulo: 'Ajustes comunes de color',
      navBar: null,
      funcionSalir: (){Navigator.pop(context);},
      cuerpo: Padding(padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            _colorTile("colorFondo", "Color de fondo", alumno.colorFondo != null
                ? alumno.colorFondo!
                : Theme.of(context).colorScheme.surface),
            SizedBox(height: 8,),
            _colorTile("colorBarraNav", "Color de la barra de navegacion", alumno.colorBarraNav != null
                ? alumno.colorBarraNav!
                : Theme.of(context).colorScheme.primary),
            SizedBox(height: 8,),
            _colorTile("colorBotones", "Color de los botones", alumno.colorBotones != null
                ? alumno.colorBotones!
                : Theme.of(context).colorScheme.primaryContainer),
          ],
        ),
      ),)
    );
  }
}
