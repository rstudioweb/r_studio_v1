import 'package:fl_chart/fl_chart.dart'
    show
        AxisTitles,
        FlBorderData,
        FlGridData,
        SideTitles,
        FlTitlesData,
        FlSpot,
        FlDotData,
        LineChartBarData,
        LineChartData,
        LineChart;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:r_studio_v1/app/utils/widgets.dart' show GlassCard;
import 'package:tap_to_expand/tap_to_expand.dart';

class DashboardView extends StatelessWidget {
  DashboardView({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> _getModelData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");
    return await _firestore.collection("models").doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Model Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getModelData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!.data()!;
          final name = data['name'] ?? "Unnamed Model";
          final targets = data['targets'] ?? {};
          final performanceScore = data['performanceScore'] ?? 0;
          final achievementsMap = Map<String, dynamic>.from(
            data['achievements'] ?? {},
          );

          final current = targets['current'] ?? 0;
          final monthly = targets['monthly'] ?? 100;

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                Text(
                  "👋 Welcome, $name",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                const SizedBox(height: 30),

                _buildCard("🎯 Target Progress", [
                  _progressBar("Monthly Target", current, monthly),
                ]),

                const SizedBox(height: 20),

                _buildCard("🏆 Achievements", [
                  achievementsMap.isEmpty
                      ? const Text("No achievements yet.")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: achievementsMap.entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                  ),
                                  child: Text(
                                    "📅 ${entry.key} — 🔥 ${entry.value} tk",
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ], collapsible: true),

                /*  _buildCard("🏆 Achievements", [
                  achievementsMap.isEmpty
                      ? const Text("No achievements yet.")
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: achievementsMap.entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    "📅 ${entry.key} — 🔥 ${entry.value} tokens",
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ]),
                 */
                const SizedBox(height: 20),
                _buildCard("📊 Achievement Chart (Datewise)", [
                  if (achievementsMap.isEmpty)
                    const Text("No data to show.")
                  else
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (value, _) {
                                  final index = value.toInt();
                                  final keys = achievementsMap.keys.toList()
                                    ..sort();
                                  if (index < 0 || index >= keys.length) {
                                    return const SizedBox();
                                  }
                                  return Text(
                                    keys[index].substring(0, 5),
                                  ); // just dd-MM
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < achievementsMap.length; i++)
                                  FlSpot(
                                    i.toDouble(),
                                    (achievementsMap.values.toList()[i] as num)
                                        .toDouble(),
                                  ),
                              ],
                              isCurved: true,
                              barWidth: 3,
                              color: Colors.green,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                ]),

                const SizedBox(height: 20),

                _buildCard("📈 Performance Score", [
                  Text(
                    "$performanceScore / 100",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(
    String title,
    List<Widget> children, {
    bool collapsible = false,
  }) {
    return GlassCard(
      title: title,
      child: collapsible
          ? TapToExpand(
              backgroundcolor: Colors.transparent,
              titlePadding: const EdgeInsets.only(bottom: 0),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
              title: const SizedBox(), // Hide default title
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
    );
  }

  /*
  Widget _buildCard(
    String title,
    List<Widget> children, {
    bool collapsible = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.85),
            Colors.grey.shade100.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: collapsible
            ? TapToExpand(
                backgroundcolor: Colors.transparent,
                titlePadding: const EdgeInsets.only(bottom: 12),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
      ),
    );
  }
*/
  /*Widget _buildCard(
    String title,
    List<Widget> children, {
    bool collapsible = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: collapsible
            ? TapToExpand(
                paddingCurve: Curves.easeInOut,
                backgroundcolor: Colors.blue,
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                iconColor: Colors.white,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const SizedBox(height: 16), ...children],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...children,
                ],
              ),
      ),
    );
  }
   Widget _buildCard(String title, List<Widget> children) {
    return 
     Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  } */

  Widget _progressBar(String label, int current, int total) {
    double percent = total > 0 ? current / total : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $current / $total"),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent.clamp(0, 1),
          backgroundColor: Colors.grey.shade300,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ],
    );
  }
}
