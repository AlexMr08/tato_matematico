import 'package:flutter_test/flutter_test.dart';
import 'package:tato_matematico/agregar/agregarAlumno.dart';
import 'package:tato_matematico/datos/juego.dart';

class TestAlumnoLogic with AlumnoLogic {}

void main() {
  group('Pruebas de los distintos juegos', () {
    test(
      'Unit Test: generarNumeroNuevo debe devolver un numero entre el intervalo dado',
      () {
        final logic = Juego(id: "", nombre: "", min: 10, max: 20, cantidad: 1);
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, greaterThanOrEqualTo(10));
        expect(resultado, lessThanOrEqualTo(20));
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver entre 0 y el maximo si el minimo es menor que 0',
      () {
        final logic = Juego(id: "", nombre: "", min: -5, max: 20, cantidad: 1);
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, greaterThanOrEqualTo(0));
        expect(resultado, lessThanOrEqualTo(20));
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver 0 si el maximo es menor que el minimo',
      () {
        final logic = Juego(id: "", nombre: "", min: 20, max: 10, cantidad: 1);
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, 0);
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver el minimo/maximo si estos son iguales',
      () {
        final logic = Juego(id: "", nombre: "", min: 10, max: 10, cantidad: 1);
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, 10);
      },
    );
  });
}
