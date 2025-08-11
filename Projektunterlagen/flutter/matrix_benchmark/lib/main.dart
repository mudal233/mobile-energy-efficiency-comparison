import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:matrix_benchmark/workers/matrix_worker.dart';

void main() {
  runApp(const MatrixApp());
}

class MatrixApp extends StatelessWidget {
  const MatrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MatrixHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MatrixHomePage extends StatefulWidget {
  const MatrixHomePage({super.key});

  @override
  State<MatrixHomePage> createState() => _MatrixHomePageState();
}

class _MatrixHomePageState extends State<MatrixHomePage> {
  final TextEditingController _controller = TextEditingController(text: "1");
  bool _isRunning = false;
  int _completed = 0;
  double _elapsedTime = 0;
  String _lastDuration = "--";
  String _totalOps = "--";
  Timer? _timer;

  static const int size = 1500;
  final int cores = Platform.numberOfProcessors;

  late List<List<int>> _matrixA;
  late List<List<int>> _matrixB;

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startMultiplication(int times) async {
    setState(() {
      _isRunning = true;
      _completed = 0;
      _elapsedTime = 0;
      _lastDuration = "--";
      _totalOps = (size * size * size).toString();
    });

    final Stopwatch globalWatch = Stopwatch()..start();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _elapsedTime = globalWatch.elapsedMilliseconds.toDouble();
      });
    });

    // Matrizen nur EINMAL erzeugen
    _matrixA = _generateMatrix(size);
    _matrixB = _generateMatrix(size);

    for (int i = 0; i < times; i++) {
      final Stopwatch watch = Stopwatch()..start();
      await _runParallelMultiplication(_matrixA, _matrixB);
      watch.stop();

      setState(() {
        _completed++;
        _lastDuration = watch.elapsedMilliseconds.toString();
      });

      await Future.delayed(Duration.zero); // Damit der Garbage Collector atmen kann
    }

    _timer?.cancel();
    globalWatch.stop();

    setState(() {
      _elapsedTime = globalWatch.elapsedMilliseconds.toDouble();
      _isRunning = false;
    });
  }

  Future<void> _runParallelMultiplication(List<List<int>> matrixA, List<List<int>> matrixB) async {
    final chunkSize = (size / cores).ceil();
    final futures = <Future<List<List<int>>>>[];

    for (int i = 0; i < cores; i++) {
      final start = i * chunkSize;
      final end = (i + 1) * chunkSize > size ? size : (i + 1) * chunkSize;

      final data = MatrixIsolateData(
        matrixA,
        matrixB,
        size,
        start,
        end,
      );

      futures.add(_spawnIsolate(data));
    }

    final parts = await Future.wait(futures);

    // Ergebnis muss nicht zusammengesetzt werden, weil wir es nicht verwenden
    // Aber damit keine falschen Annahmen entstehen, hier korrekt:
    List<List<int>> finalResult = List.generate(size, (_) => List.filled(size, 0));
    int rowIndex = 0;
    for (var part in parts) {
      for (var row in part) {
        finalResult[rowIndex++] = row;
      }
    }
  }

  Future<List<List<int>>> _spawnIsolate(MatrixIsolateData data) async {
    final p = ReceivePort();
    await Isolate.spawn(matrixWorker, [p.sendPort, data]);
    return await p.first;
  }

  List<List<int>> _generateMatrix(int size) {
    final random = Random();
    return List.generate(
      size,
          (_) => List.generate(size, (_) => random.nextInt(100)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matrix Benchmark Flutter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Diese App multipliziert große Matrizen und misst die CPU-Last. '
                  'Sie nutzt alle verfügbaren CPU-Kerne (via Isolates).',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Anzahl der Multiplikationenn",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isRunning
                  ? null
                  : () {
                final n = int.tryParse(_controller.text.trim());
                if (n != null && n > 0) {
                  _startMultiplication(n);
                }
              },
              child: Text(_isRunning ? "Berechnung läuft..." : "Start"),
            ),
            const SizedBox(height: 30),
            Text("Abgeschlossene Multiplikationen: $_completed"),
            Text("Laufzeit: ${(_elapsedTime / 1000).toStringAsFixed(2)} Sekunden"),
            Text("Letzte Dauer: $_lastDuration ms"),
            Text("Operationen pro Multiplikation: $_totalOps"),
          ],
        ),
      ),
    );
  }
}
