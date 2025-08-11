self.onmessage = function (e) {
    const { size, matrixA, matrixB, startRow, endRow, index } = e.data;
  
    function multiplyMatrices(A, B, size, startRow, endRow) {
      const C = Array.from({ length: endRow - startRow }, () =>
        Array(size).fill(0)
      );
      for (let i = startRow; i < endRow; i++) {
        for (let j = 0; j < size; j++) {
          for (let k = 0; k < size; k++) {
            C[i - startRow][j] += A[i][k] * B[k][j];
          }
        }
      }
      return C;
    }
  
    const result = multiplyMatrices(matrixA, matrixB, size, startRow, endRow);
    self.postMessage({ result, index });
  };
  