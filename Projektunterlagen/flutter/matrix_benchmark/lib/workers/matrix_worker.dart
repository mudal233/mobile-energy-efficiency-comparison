import 'dart:isolate';

class MatrixIsolateData {
  final List<List<int>> matrixA;
  final List<List<int>> matrixB;
  final int size;
  final int startRow;
  final int endRow;

  MatrixIsolateData(this.matrixA, this.matrixB, this.size, this.startRow, this.endRow);
}

void matrixWorker(List<dynamic> args) {
  SendPort sendPort = args[0];
  MatrixIsolateData data = args[1];

  final result = List.generate(data.endRow - data.startRow,
          (_) => List.filled(data.size, 0));

  for (int i = data.startRow; i < data.endRow; i++) {
    for (int j = 0; j < data.size; j++) {
      int sum = 0;
      for (int k = 0; k < data.size; k++) {
        sum += data.matrixA[i][k] * data.matrixB[k][j];
      }
      result[i - data.startRow][j] = sum;
    }
  }

  sendPort.send(result);
}
