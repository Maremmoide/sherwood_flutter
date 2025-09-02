import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticheScreen extends StatefulWidget {
  const StatisticheScreen({super.key});

  @override
  State<StatisticheScreen> createState() => _StatisticheScreenState();
}

class _StatisticheScreenState extends State<StatisticheScreen> {
  String filtro = "Tutto";

  @override
  Widget build(BuildContext context) {
    final ordiniRef = FirebaseFirestore.instance.collection("ordini");

    return Scaffold(
      appBar: AppBar(title: const Text("Statistiche")),
      body: Column(
        children: [
          // Pulsanti filtro
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              isSelected: [
                filtro == "Oggi",
                filtro == "Settimana",
                filtro == "Tutto"
              ],
              onPressed: (index) {
                setState(() {
                  filtro = ["Oggi", "Settimana", "Tutto"][index];
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Oggi"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Ultima settimana"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Tutto"),
                ),
              ],
            ),
          ),

          // Contenuto principale
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: ordiniRef.get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ordini = snapshot.data!.docs;
                final Map<String, int> conteggioPiatti = {};
                double totaleIncasso = 0;

                // Calcolo date filtro
                final now = DateTime.now();
                DateTime? inizioPeriodo;

                if (filtro == "Oggi") {
                  inizioPeriodo = DateTime(now.year, now.month, now.day);
                } else if (filtro == "Settimana") {
                  inizioPeriodo = now.subtract(const Duration(days: 7));
                }

                for (var ordine in ordini) {
                  final data = ordine.data() as Map<String, dynamic>;
                  final items = List<Map<String, dynamic>>.from(data["items"]);

                  final timestampStr = data["timestamp"];
                  DateTime? timestamp;
                  if (timestampStr != null) {
                    timestamp = DateTime.tryParse(timestampStr.toString());
                  }

                  if (inizioPeriodo != null && timestamp != null) {
                    if (timestamp.isBefore(inizioPeriodo)) continue;
                  }

                  for (var item in items) {
                    final nome = item["nome"];
                    final qty = (item["qty"] ?? 0) as int;
                    final prezzo = (item["prezzo"] ?? 0).toDouble();

                    conteggioPiatti[nome] =
                        (conteggioPiatti[nome] ?? 0) + qty;
                    totaleIncasso += prezzo * qty;
                  }
                }

                if (conteggioPiatti.isEmpty) {
                  return const Center(child: Text("Nessun dato disponibile"));
                }

                final entries = conteggioPiatti.entries.toList();

                return Column(
                  children: [
                    // Grafico a barre
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < entries.length) {
                                      return Text(
                                        entries[index].key,
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                            ),
                            barGroups: entries.asMap().entries.map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: data.value.toDouble(),
                                    color: Colors.blue,
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                    // Lista dei piatti
                    Expanded(
                      flex: 1,
                      child: ListView(
                        children: conteggioPiatti.entries.map((e) {
                          return ListTile(
                            title: Text(e.key),
                            trailing: Text("x${e.value}"),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      // Totale incasso spostato sopra i tasti del telefono
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<QuerySnapshot>(
            future: ordiniRef.get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              double totaleIncasso = 0;
              for (var ordine in snapshot.data!.docs) {
                final data = ordine.data() as Map<String, dynamic>;
                final items = List<Map<String, dynamic>>.from(data["items"]);
                for (var item in items) {
                  final qty = (item["qty"] ?? 0) as int;
                  final prezzo = (item["prezzo"] ?? 0).toDouble();
                  totaleIncasso += prezzo * qty;
                }
              }
              return Text(
                "💰 Incasso totale: €${totaleIncasso.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
