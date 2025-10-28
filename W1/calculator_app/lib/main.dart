import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController _expressionController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  String expression = "";
  String result = "0";
  List<String> history = [];

  @override
  void dispose() {
    _expressionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  final List<String> buttons = [
    "(",
    ")",
    "⌫",
    "/",
    "7",
    "8",
    "9",
    "*",
    "4",
    "5",
    "6",
    "-",
    "1",
    "2",
    "3",
    "+",
    "C",
    "0",
    ".",
    "=",
  ];

  void onButtonPressed(String value) {
    setState(() {
      int cursorPos = _expressionController.selection.base.offset;
      if (cursorPos < 0) cursorPos = expression.length;

      if (value == "C") {
        expression = "";
        result = "0";
        cursorPos = 0;
      } else if (value == "⌫") {
        if (expression.isNotEmpty && cursorPos > 0) {
          expression = expression.replaceRange(cursorPos - 1, cursorPos, "");
          cursorPos--;
        }
      } else if (value == "=") {
        if (expression.isEmpty) return;

        try {
          final parser = ShuntingYardParser();
          Expression exp = parser.parse(expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          result = eval.toString();
          history.insert(0, "$expression = $result");
          if (history.length > 5) history.removeLast();
        } catch (e) {
          result = "Error";
        }
      } else {
        if (expression.length >= 22) return;

        if (['+', '-', '*', '/', '.'].contains(value)) {
          if (cursorPos == 0 || (cursorPos > 0 && ['+', '-', '*', '/', '.'].contains(expression[cursorPos - 1]))) {
            return;
          }
        }

        expression = expression.replaceRange(cursorPos, cursorPos, value);
        cursorPos += value.length;
      }

      _expressionController.text = expression;
      _expressionController.selection = TextSelection.collapsed(offset: cursorPos);
    });
  }

  Color _getButtonColor(String value) {
    if (value == "C" || value == "⌫") return Colors.red[400]!;
    if (["=", "+", "-", "*", "/"].contains(value)) return Colors.cyan[500]!;
    return Colors.blueGrey[200]!;
  }


  @override
  Widget build(BuildContext context) {
    double fontSize = expression.length > 16 ? 24 : 32; // Responsive font size

    return Scaffold(
      appBar: AppBar(title: Text("Huỳnh Kim Thiên, Võ Duy Trường")),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SizedBox(
                      height: 80,
                      child: ListView(
                        children: history.map(
                              (entry) => Text(
                            entry,
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ).toList(),
                      ),
                    ),
                  ),
                  Container(
                    height: 230,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _focusNode.requestFocus();
                          },
                          child: TextField(
                            controller: _expressionController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.none,
                            onChanged: (value) {
                              setState(() {
                                expression = value;
                              });
                            },
                          ),
                        ),
                        Spacer(),
                        Text(
                          result,
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: result.length > 10 ? 32 : 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 400,
            child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.2,
              ),
              itemCount: buttons.length,
              itemBuilder: (context, index) {
                return CalculatorButton(
                  text: buttons[index],
                  onPressed: () => onButtonPressed(buttons[index]),
                  color: _getButtonColor(buttons[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  CalculatorButton({
    required this.text,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: text == "⌫"
              ? Icon(Icons.backspace, color: Colors.white, size: 30)
              : Text(
            text,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
