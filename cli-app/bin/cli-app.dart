import 'parser.dart';
import 'scanner.dart';
import 'dart:io';

void main () {
  print("Enter a mathematical expression: ");

  String name = stdin.readLineSync()!;


  Scanner sc = Scanner(name);



  List<ScannedToken> scanExp = sc.scan();
  Parser parser = new Parser(scanExp);
  List<ScannedToken> parsed = parser.parse();
  scanExp.forEach((e) {
    print(e.mathExpression);
  });
  print(sc.evaluate(parsed));
}