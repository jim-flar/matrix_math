import 'term.dart';
import 'constants.dart';
import 'products.dart';
import 'sums.dart';
import 'vecmath3.dart';

/// A 4-value homogeneous coordinate representing X, Y, Z, and a homogeneous factor W.
class Vector4 {
  final Term xVal, yVal, zVal, wVal;

  Vector4([this.xVal = zero, this.yVal = zero, this.zVal = zero, this.wVal = one]);

  /// Add this Vector4 to the other and return a new result object.
  Vector4 add(Vector4 other) {
    return Vector4(
      Sum.add([this.xVal, other.xVal]),
      Sum.add([this.yVal, other.yVal]),
      Sum.add([this.zVal, other.zVal]),
      Sum.add([this.wVal, other.wVal]),
    );
  }

  /// Subtract the other Vector4 from this Vector4 and return a new result object.
  Vector4 sub(Vector4 other) {
    return Vector4(
      Sum.sub(this.xVal, other.xVal),
      Sum.sub(this.yVal, other.yVal),
      Sum.sub(this.zVal, other.zVal),
      Sum.sub(this.wVal, other.wVal),
    );
  }

  /// Multiply the coordinates of this Vector4 by a common Term and return a new result object.
  Vector4 multiplyFactor(Term factor) {
    return Vector4(
      Product.mul(xVal, factor),
      Product.mul(yVal, factor),
      Product.mul(zVal, factor),
      Product.mul(wVal, factor),
    );
  }

  /// Divide the coordinates of this Vector4 by a common Term and return a new result object.
  Vector4 divideFactor(Term factor) {
    return Vector4(
      Division.div(xVal, factor),
      Division.div(yVal, factor),
      Division.div(zVal, factor),
      Division.div(wVal, factor),
    );
  }

  /// Return a new vector with the normalized homogeneous version of this Vector4.
  Vector4 normalize() => Vector4(
    Division.div(xVal, wVal),
    Division.div(yVal, wVal),
    Division.div(zVal, wVal),
  );

  @override
  String toString() => 'Vector4($xVal, $yVal, $zVal, $wVal)';
}

/// A 4x4 coordinate matrix
class Matrix4x4 {
  final List<List<Term>> elements;

  Matrix4x4(this.elements) {
    assert(elements.length == 4 &&
        elements[0].length == 4 &&
        elements[1].length == 4 &&
        elements[2].length == 4 &&
        elements[3].length == 4);
  }

  /// Transform a Vector4 by this matrix by post-multiplying it as a column vector and
  /// return a new result object:
  ///
  /// [ mat[0][0] mat[0][1] mat[0][2] mat[0][3] ]   [ vec.xVal ]
  /// [ mat[1][0] mat[1][1] mat[1][2] mat[1][3] ] x [ vec.yVal ]
  /// [ mat[2][0] mat[2][1] mat[2][2] mat[2][3] ]   [ vec.zVal ]
  /// [ mat[3][0] mat[3][1] mat[3][2] mat[3][3] ]   [ vec.wVal ]
  Vector4 transform(Vector4 vec) {
    Term xN = vec.xVal;
    Term yN = vec.yVal;
    Term zN = vec.zVal;
    Term wN = vec.wVal;
    return Vector4(
      Sum.add([
        Product.mul(xN, elements[0][0]),
        Product.mul(yN, elements[0][1]),
        Product.mul(zN, elements[0][2]),
        Product.mul(wN, elements[0][3]),
      ]),
      Sum.add([
        Product.mul(xN, elements[1][0]),
        Product.mul(yN, elements[1][1]),
        Product.mul(zN, elements[1][2]),
        Product.mul(wN, elements[1][3]),
      ]),
      Sum.add([
        Product.mul(xN, elements[2][0]),
        Product.mul(yN, elements[2][1]),
        Product.mul(zN, elements[2][2]),
        Product.mul(wN, elements[2][3]),
      ]),
      Sum.add([
        Product.mul(xN, elements[3][0]),
        Product.mul(yN, elements[3][1]),
        Product.mul(zN, elements[3][2]),
        Product.mul(wN, elements[3][3]),
      ]),
    );
  }

  /// Multiply all elements of this matrix by a common Term factor and return a new result object.
  Matrix4x4 multiplyFactor(Term factor) {
    factor = factor;
    if (factor == one) return this;
    return Matrix4x4(
      [
        for (var row in elements) [
          for (var term in row)
            Product.mul(term, factor),
        ],
      ],
    );
  }

  /// Divide all elements of this matrix by a common Term factor and return a new result object.
  Matrix4x4 divideFactor(Term factor) {
    factor = factor;
    if (factor == one) return this;
    return Matrix4x4(
      [
        for (var row in elements) [
          for (var term in row)
            Division.div(term, factor),
        ],
      ],
    );
  }

  /// Multiply this matrix by another matrix and return a new result object:
  ///
  /// [ mat[0][0] mat[0][1] mat[0][2] mat[0][3] ]   [ oth[0][0] oth[0][1] oth[0][2] oth[0][3] ]
  /// [ mat[1][0] mat[1][1] mat[1][2] mat[1][3] ] x [ oth[1][0] oth[1][1] oth[1][2] oth[1][3] ]
  /// [ mat[2][0] mat[2][1] mat[2][2] mat[2][3] ]   [ oth[2][0] oth[2][1] oth[2][2] oth[2][3] ]
  /// [ mat[3][0] mat[3][1] mat[3][2] mat[3][3] ]   [ oth[3][0] oth[3][1] oth[3][2] oth[3][3] ]
  Matrix4x4 multiplyMatrix(Matrix4x4 other) {
    return Matrix4x4(
      [
        for (int row = 0; row < 4; row++) [
          for (int col = 0; col < 4; col++)
            crossMultiply(this, row, other, col),
        ],
      ],
    );
  }

  /// Cross-multiply a row from the first matrix with a column from the second
  /// and return a Term object for the result.
  ///
  /// (rowMatrix[row][0] * colMatrix[0][col] +
  ///  rowMatrix[row][1] * colMatrix[1][col] +
  ///  rowMatrix[row][2] * colMatrix[2][col] +
  ///  rowMatrix[row][3] * colMatrix[3][col])
  static Term crossMultiply(Matrix4x4 rowMatrix, int row, Matrix4x4 colMatrix, int col) {
    return Sum.add([
      Product.mul(rowMatrix.elements[row][0], colMatrix.elements[0][col]),
      Product.mul(rowMatrix.elements[row][1], colMatrix.elements[1][col]),
      Product.mul(rowMatrix.elements[row][2], colMatrix.elements[2][col]),
      Product.mul(rowMatrix.elements[row][3], colMatrix.elements[3][col]),
    ]);
  }

  /// Return a 2x2 determinant consisting of the four elements of this matrix taken as:
  ///
  /// [ mat[row1][col1]  mat[row1][col2] ]
  /// [ mat[row2][col1]  mat[row2][col2] ]
  Term determinant2x2(int row1, int row2, int col1, int col2) {
    return Sum.sub(Product.mul(elements[row1][col1], elements[row2][col2]),
                   Product.mul(elements[row1][col2], elements[row2][col1]));
  }

  List<int> _allBut(int rc) => [...[0,1,2,3].where((i) => i != rc)];

  /// Return the minor for the indicated row and column.
  Term minor(int row, int col) {
    var r = _allBut(row);
    var c = _allBut(col);
    return Sum.add([
      Product.mul(elements[r[0]][c[0]],
          determinant2x2(r[1], r[2], c[1], c[2])),
      Product.mul(elements[r[0]][c[1]],
          determinant2x2(r[1], r[2], c[2], c[0])),
      Product.mul(elements[r[0]][c[2]],
          determinant2x2(r[1], r[2], c[0], c[1])),
    ]);
  }

  /// Return the determinant of this matrix.
  Term determinant() {
    List<Term> terms = [];
    for (int col = 0; col < 4; col++) {
      Term m = minor(0, col);
      if ((col & 1) == 1) m = m.negate();
      terms.add(Product.mul(elements[0][col], m));
    }
    return Sum.add(terms);
  }

  /// Return a new matrix consisting of the minors for every element in this matrix.
  Matrix4x4 minors() {
    return Matrix4x4(
      [
        for (int row = 0; row < 4; row++) [
          for (int col = 0; col < 4; col++)
            minor(row, col),
        ]
      ],
    );
  }

  /// Return a new matrix consisting of the cofactors for every element in this matrix.
  Matrix4x4 cofactors() {
    return Matrix4x4(
      [
        for (int row = 0; row < 4; row++) [
          for (int col = 0; col < 4; col++)
            (((row^col)&1) == 0)
                ? elements[row][col]
                : elements[row][col].negate(),
        ],
      ],
    );
  }

  /// Return a new matrix consisting of the elements of this matrix transposed.
  Matrix4x4 transpose() {
    return Matrix4x4(
      [
        for (int row = 0; row < 4; row++) [
          for (int col = 0; col < 4; col++)
            elements[col][row],
        ],
      ],
    );
  }

  /// Return a 3x3 matrix consisting of every row and column in this matrix except
  /// for the specified skipRow and skipCol.
  Matrix3x3 without({int skipRow, int skipCol}) {
    return Matrix3x3(
      [
        for (int rowIndex in _allBut(skipRow)) [
          for (int colIndex in _allBut(skipCol))
            elements[rowIndex][colIndex],
        ],
      ],
    );
  }

  /// Print out the matrix in a format that might be pretty if the terms are short and
  /// similar in length.
  void printOut(String label) {
    var m = elements;
    print('$label =');
    print('  [ ${m[0][0]}  ${m[0][1]}  ${m[0][2]}  ${m[0][3]} ]');
    print('  [ ${m[1][0]}  ${m[1][1]}  ${m[1][2]}  ${m[1][3]} ]');
    print('  [ ${m[2][0]}  ${m[2][1]}  ${m[2][2]}  ${m[2][3]} ]');
    print('  [ ${m[3][0]}  ${m[3][1]}  ${m[3][2]}  ${m[3][3]} ]');
  }
}
