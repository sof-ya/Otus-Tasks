import 'scanner.dart';

class Parser {
  late final List<ScannedToken> expression;

  Parser (List<ScannedToken> expression) {
    this.expression = expression;
  }

  List<ScannedToken> parse() {
    TokenType? prev = null;
    TokenType? curr = null;
    TokenType? next = null;

    List<ScannedToken> properlyParsedExpression = [];

    List<TokenType> types = [];

    for (int i = 0; i < expression.length; i++) {
      TokenType curr = expression.elementAt(i).typeOf();
      types.add(curr);
    }
    List<int> indexes = [];
    List<ScannedToken> negativeValues = [];

    for (int i = 0; i < types.length - 1; i++) {
      prev = i == 0 ? null : types.elementAt(i - 1);
      curr = types.elementAt(i);
      next = types.elementAt(i + 1);
      if (prev == null && curr == TokenType.SUB && next == TokenType.VALUE) {
        ScannedToken negativeValue = new ScannedToken("" + (-1 * double.parse(expression.elementAt(i + 1).expression())).toString(), TokenType.VALUE);
        print("new token at index $i");
        indexes.add(i);
        negativeValues.add(negativeValue);
      } else if (prev == TokenType.LPAR && curr == TokenType.SUB && next == TokenType.VALUE) {
        ScannedToken negativeValue = new ScannedToken("" + (-1 * double.parse(expression.elementAt(i + 1).expression())).toString(), TokenType.VALUE);
        print("new token at index $i");
        indexes.add(i);
        negativeValues.add(negativeValue);
      }
    }
    int maxIterations = expression.length;
    int i = 0;
    int j = 0;
    while (i < maxIterations) {
      if (indexes.contains(i) && j < negativeValues.length) {
        properlyParsedExpression.add(negativeValues.elementAt(j));
        j++;
        i++;
      }
      else {
        properlyParsedExpression.add(expression.elementAt(i));
      }
      i++;
    }
    return properlyParsedExpression;
  }
}