import 'dart:convert';
import 'dart:io';
import 'dart:math';

enum TokenType{
  ADD,
  SUB,
  MUL,
  DIV,
  POW,
  LPAR,
  RPAR,
  VALUE;


  @override
    String convertToString() {
      switch(this.index) {
        case 0:
          return "+";
        case 1:
          return "-";
        case 2:
          return "*";
        case 3:
          return "/";
        case 4:
          return "(";
        case 5:
          return ")";
        case 6:
          return this.name;
        default:
          return "null";
      }
    }

  static TokenType fromString(String s){
    switch (s){
      case "+":
        return TokenType.ADD;
      case "-":
        return TokenType.SUB;
      case "*":
        return TokenType.MUL;
      case "/":
        return TokenType.DIV;
      case "^":
        return TokenType.POW;
      case "(":
        return TokenType.LPAR;
      case ")":
        return TokenType.RPAR;
      default:
        return TokenType.VALUE;
    }
  }
}

class ScannedToken {
  late String mathExpression;
  TokenType type = TokenType.VALUE;

  ScannedToken(String expr, TokenType type) {
    this.mathExpression = expr;
    this.type = type;
  }

  @override
  String convertToString() {
    return "(Expr:"+ mathExpression + ", Token:"+ type.convertToString() +")";
  }

  TokenType typeOf(){
    return type;
  }

  String expression(){
    return mathExpression;
  }
}


class Scanner {
  late final String expression;
  late final Map <String, int> variables;

  Scanner(String expr) {
    this.expression = expr;
  }

  List<ScannedToken> scan() {
    String value = '';
    List<ScannedToken> scannedExpr = [];

    for (int i=0; i<expression.length; i++)
    {
      String c = expression[i];

      TokenType type = TokenType.fromString(c);
      if(!(type == TokenType.VALUE))
        {
          if (value.length > 0) {
            ScannedToken st = ScannedToken(value.toString(), TokenType.VALUE);
            scannedExpr.add(st);
          }
          value = c;
          ScannedToken st = ScannedToken(value.toString(), type);
          scannedExpr.add(st);
          value = '';
        } else {
        if(double.tryParse(c)==null)
          {
            print ("Enter $c value: ");
            c = stdin.readLineSync()!;
          }
        value += c;
      }
    }
    if (value.length > 0) {
      ScannedToken st = new ScannedToken(value.toString(), TokenType.VALUE);
      scannedExpr.add(st);
    }

    return scannedExpr;
  }

  double evaluate (List<ScannedToken> tokenizedExpression) {
    if(tokenizedExpression.length == 1) {
      return double.parse(tokenizedExpression.elementAt(0).expression());
    }

    List<ScannedToken> simpleExpr = [];

    int idx = -1;

    for (int i = 0; i < tokenizedExpression.length; i++) {
      ScannedToken curr = tokenizedExpression.elementAt(i);
      if(curr.type == TokenType.LPAR) {
        idx = i;
        break;
      }
    }

    int matchingRPAR = -1;
    if (idx >= 0) {
      for (int i = idx + 1; i < tokenizedExpression.length; i++) {
        ScannedToken curr = tokenizedExpression.elementAt(i);
        if(curr.type == TokenType.RPAR) {
          matchingRPAR = i;
          break;
        } else {
          simpleExpr.add(tokenizedExpression.elementAt(i));
        }
      }
    } else {
      simpleExpr.addAll(tokenizedExpression);
      return evaluateSimpleExpression(tokenizedExpression);
    }

    double value = evaluateSimpleExpression(simpleExpr);

    List<ScannedToken> partiallyEvaluatedExpression = [];
    for (int i = 0; i < idx; i++) {
      partiallyEvaluatedExpression.add(tokenizedExpression.elementAt(i));
    }

    partiallyEvaluatedExpression.add(new ScannedToken(value.toString(), TokenType.VALUE));
    for (int i = matchingRPAR + 1; i < tokenizedExpression.length; i++) {
      partiallyEvaluatedExpression.add(tokenizedExpression.elementAt(i));
    }

    return evaluate(partiallyEvaluatedExpression);
  }


  double evaluateSimpleExpression(List<ScannedToken> expression) {
    if (expression.length == 1) {
      return double.parse(expression.elementAt(0).expression());
    } else {
        List<ScannedToken> newExpression = [];
        int mulIdx = -1;
        for (int i = 0; i < expression.length; i++) {
          ScannedToken curr = expression.elementAt(i);
          if(curr.type == TokenType.MUL) {
            mulIdx = i;
            break;
          }
        }

        int divIdx = -1;
        for (int i = 0; i < expression.length; i++) {
          ScannedToken curr = expression.elementAt(i);
          if(curr.type == TokenType.DIV) {
            divIdx = i;
            break;
          }
        }
        int computationIdx = (mulIdx >= 0 && divIdx >= 0) ? min(mulIdx, divIdx) : max(mulIdx, divIdx);

        if (computationIdx != -1) {
          double left = double.parse(expression.elementAt(computationIdx - 1).expression());
          double right = double.parse(expression.elementAt(computationIdx + 1).expression());
          double ans = computationIdx == mulIdx ? left * right : left / right * 1.0;
          for (int i = 0; i < computationIdx - 1; i++) {
            newExpression.add(expression.elementAt(i));
          }
          newExpression.add(new ScannedToken(ans.toString() + "", TokenType.VALUE));
          for (int i = computationIdx + 2; i < expression.length; i++) {
            newExpression.add(expression.elementAt(i));
          }
          return evaluateSimpleExpression(newExpression);
        } else {
          int addIdx = -1;
          for (int i = 0; i < expression.length; i++) {
            ScannedToken curr = expression.elementAt(i);
            if(curr.type == TokenType.ADD) {
              addIdx = i;
              break;
            }
          }

          int subIdx = -1;
          for (int i = 0; i < expression.length; i++) {
            ScannedToken curr = expression.elementAt(i);
            if(curr.type == TokenType.SUB) {
              subIdx = i;
              break;
            }
          }

          int computationIdx2 = (addIdx >= 0 && subIdx >= 0) ? min(addIdx, subIdx) : max(addIdx, subIdx);
          if (computationIdx2 != -1) {
            double left = double.parse(expression.elementAt(computationIdx2 - 1).expression());
            double right = double.parse(expression.elementAt(computationIdx2 + 1).expression());
            double ans = computationIdx2 == addIdx ? left + right : (left - right) * 1.0;
            for (int i = 0; i < computationIdx2 - 1; i++) {
              newExpression.add(expression.elementAt(i));
            }
            newExpression.add(new ScannedToken(ans.toString() + "", TokenType.VALUE));
            for (int i = computationIdx2 + 2; i < expression.length; i++) {
              newExpression.add(expression.elementAt(i));
            }
            return evaluateSimpleExpression(newExpression);
          }
        }
      }
    return -1.0;
  }
}
