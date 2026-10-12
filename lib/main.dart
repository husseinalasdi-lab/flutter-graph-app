import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(const MaterialApp(home: GraphApp()));

class GraphApp extends StatefulWidget {
  const GraphApp({super.key});

  @override
  State<GraphApp> createState() => _GraphAppState();
}

class _GraphAppState extends State<GraphApp> {
  bool isFunctionMode = true;
  final TextEditingController _exprController = TextEditingController(text: 'x^2');
  final TextEditingController _pointsController = TextEditingController(text: '1,1; 2,4; 3,9; 4,16');
  List<FlSpot> spots = [];

  @override
  void initState() {
    super.initState();
    calculateAndPlot();
  }

  void calculateAndPlot() {
    List<FlSpot> newSpots = [];
    try {
      if (isFunctionMode) {
        Parser parser = Parser();
        Expression exp = parser.parse(_exprController.text.replaceAll('X', 'x'));
        ContextModel cm = ContextModel();

        for (double x = -5.0; x <= 5.0; x += 0.5) {
          cm.bindVariable(Variable('x'), Number(x));
          double y = exp.evaluate(EvaluationType.REAL, cm);
          if (y.isFinite) {
            newSpots.add(FlSpot(x, y));
          }
        }
      } else {
        List<String> pairs = _pointsController.text.split(';');
        for (var pair in pairs) {
          var parts = pair.trim().split(',');
          if (parts.length == 2) {
            double? x = double.tryParse(parts[0].trim());
            double? y = double.tryParse(parts[1].trim());
            if (x != null && y != null) {
              newSpots.add(FlSpot(x, y));
            }
          }
        }
        newSpots.sort((a, b) => a.x.compareTo(b.x));
      }

      setState(() {
        spots = newSpots;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التأكد من صحة الصيغة المدخلة')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('راسم المنحنيات البيانية'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('دالة رياضية f(x)'),
                  selected: isFunctionMode,
                  onSelected: (val) => setState(() => isFunctionMode = true),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('نقاط جاهزة (X, Y)'),
                  selected: !isFunctionMode,
                  onSelected: (val) => setState(() => isFunctionMode = false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isFunctionMode)
              TextField(
                controller: _exprController,
                decoration: const InputDecoration(
                  labelText: 'المعادلة (مثال: x^2 أو sin(x) + 2*x)',
                  border: OutlineInputBorder(),
                ),
              )
            else
              TextField(
                controller: _pointsController,
                decoration: const InputDecoration(
                  labelText: 'النقاط بصيغة: x,y; x,y (مثال: 1,2; 2,4; 3,9)',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: calculateAndPlot,
              icon: const Icon(Icons.show_chart),
              label: const Text('رسم المنحنى'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: spots.isEmpty
                  ? const Center(child: Text('لا توجد نقاط كافية للرسم'))
                  : LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: const FlTitlesData(
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: isFunctionMode,
                            barWidth: 3,
                            color: Colors.blue,
                            dotData: FlDotData(show: !isFunctionMode),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
