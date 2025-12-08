import 'package:flutter_test/flutter_test.dart';
import 'package:tato_matematico/agregar/agregarAlumno.dart';
import 'package:tato_matematico/datos/alumno.dart';
import 'package:tato_matematico/datos/juego.dart';
import 'package:tato_matematico/juegos/juego2/juego2.dart';
import 'package:tato_matematico/juegos/juego2/juego2State.dart';

class TestAlumnoLogic with AlumnoLogic {}

void main() {
  group('Pruebas de los distintos juegos', () {
    test(
      'Unit Test: generarNumeroNuevo debe devolver un numero entre el intervalo dado',
      () {
        final logic = Juego(
          id: "",
          nombre: "",
          min: 10,
          max: 20,
          cantidad: 1,
          usaImagenes: false,
          tipoImagenes: "",
        );
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, greaterThanOrEqualTo(10));
        expect(resultado, lessThanOrEqualTo(20));
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver entre 0 y el maximo si el minimo es menor que 0',
      () {
        final logic = Juego(
          id: "",
          nombre: "",
          min: -5,
          max: 20,
          cantidad: 1,
          usaImagenes: false,
          tipoImagenes: "",
        );
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, greaterThanOrEqualTo(0));
        expect(resultado, lessThanOrEqualTo(20));
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver 0 si el maximo es menor que el minimo',
      () {
        final logic = Juego(
          id: "",
          nombre: "",
          min: 20,
          max: 10,
          cantidad: 1,
          usaImagenes: false,
          tipoImagenes: "",
        );
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, 0);
      },
    );

    test(
      'Unit Test: generarNumeroNuevo debe devolver el minimo/maximo si estos son iguales',
      () {
        final logic = Juego(
          id: "",
          nombre: "",
          min: 10,
          max: 10,
          cantidad: 1,
          usaImagenes: false,
          tipoImagenes: "",
        );
        int resultado = logic.generarNuevoNumero();
        expect(resultado, isA<int>());
        expect(resultado, 10);
      },
    );

    test(
      'Unit Test: El constructor omite el valor pasado por parametro para el uso de imagenes si el maximo es mayor que 10',
      () {
        final logic = Juego(
          id: "",
          nombre: "",
          min: 0,
          max: 15,
          cantidad: 1,
          usaImagenes: true,
          tipoImagenes: "ball",
        );
        expect(logic.usaImagenes, false);
      },
    );

    group('Pruebas de lógica de estado Juego2State', () {
      // 1. Preparación de objetos reales    // Creamos un alumno dummy (los datos no importan para la lógica del juego)
      final alumno = Alumno(id: "test_1", nombre: "Tester", imagen: '');

      // Creamos la configuración del juego: Ordenar 3 números entre 1 y 10
      final juegoConfig = Juego2(min: 1, max: 10, cantidad: 3, usaImagenes: false, tipoImagenes: "", ordenDescendente: true);

      test('iniciarJuego genera números y prepara el tablero vacío', () {
        final state = Juego2State(juegoConfig, alumno);

        state.iniciarJuego();

        // Verificamos que se generaron 3 números
        expect(state.numeros.length, 3);

        // Verificamos que el tablero de abajo tiene 3 huecos vacíos (null)
        expect(state.numerosAbajo.length, 3);
        expect(state.numerosAbajo.every((n) => n == null), true);

        // Verificamos que no empieza finalizado ni con fallos
        expect(state.finalizado, false);
        expect(state.fallo, false);
        expect(state.errores, 0);
        expect(state.aciertos, 0);
        expect(state.repeticionesCompletadas, 0);
      });

      test('moverNumero coloca la ficha y detecta si es correcta', () {
        final state = Juego2State(juegoConfig, alumno);
        state.iniciarJuego();

        // TRUCO: Como los números son aleatorios, miramos cuál es el correcto
        // leyendo la variable 'numerosOrdenados' del estado.
        int numeroCorrectoParaPosicion0 = state.numerosOrdenados[0];

        // Movemos ese número
        state.moverNumero(numeroCorrectoParaPosicion0);

        // Verificaciones:
        // 1. Ya no debe estar arriba
        expect(state.numeros.contains(numeroCorrectoParaPosicion0), false);
        // 2. Debe estar abajo en la posición 0
        expect(state.numerosAbajo[0], numeroCorrectoParaPosicion0);
        // 3. No debe haber error
        expect(state.falloActual, false);
      });

      test(
        'moverNumero detecta error si el número no corresponde a la posición',
        () {
          final state = Juego2State(juegoConfig, alumno);
          state.iniciarJuego();

          // Buscamos un número que NO sea el primero de la lista ordenada
          int numeroCorrecto = state.numerosOrdenados[0];
          int numeroIncorrecto = state.numeros.firstWhere(
            (n) => n != numeroCorrecto,
          );

          // Intentamos poner el número incorrecto en la primera posición vacía
          state.moverNumero(numeroIncorrecto);

          // Debe marcar fallo
          expect(state.falloActual, true);
          expect(state.errores, 1); // Debe haber sumado 1 error
        },
      );

      test(
        'El juego se marca finalizado solo al completar todo correctamente',
        () {
          final state = Juego2State(juegoConfig, alumno);
          state.iniciarJuego();

          // Simulamos una partida perfecta moviendo todos los números en orden
          for (int numero in state.numerosOrdenados) {
            expect(state.finalizado, false);
            state.moverNumero(numero);
          }

          // Al terminar el bucle, el tablero está lleno y correcto
          expect(state.numerosAbajo.contains(null), false);
          expect(state.finalizado, true);
        },
      );
    });
  });
}
