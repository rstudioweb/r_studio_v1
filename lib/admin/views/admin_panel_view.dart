import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';

class AdminPanelView extends StatelessWidget {
  final AdminController controller = Get.put(AdminController());

  final TextEditingController achievementController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController scoreController = TextEditingController();
  final TextEditingController currentTargetController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  final String adminPassword = "admin123";

  AdminPanelView({super.key});

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isAuthenticated.value) return _passwordPrompt();

      return Scaffold(
        appBar: AppBar(title: const Text("Admin Panel")),
        body: Row(
          children: [
            _buildModelList(),
            const VerticalDivider(),
            _buildModelEditor(),
          ],
        ),
      );
    });
  }

  Widget _buildModelList() {
    return Expanded(
      flex: 2,
      child: Obx(() {
        return ListView(
          children: controller.models.map((docSnap) {
            final data = docSnap.data() as Map<String, dynamic>;
            final name = data['name'] ?? data['email'];
            return ListTile(
              title: Text(name),
              subtitle: Text(docSnap.id),
              onTap: () {
                controller.selectedModel.value = docSnap;
                scoreController.text = (data['performanceScore'] ?? 0)
                    .toString();
                currentTargetController.text =
                    (data['targets']?['current'] ?? 0).toString();
              },
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildModelEditor() {
    return Expanded(
      flex: 4,
      child: Obx(() {
        final docSnap = controller.selectedModel.value;
        if (docSnap == null) return const Center(child: Text("Select a model"));

        final doc = docSnap.data() as Map<String, dynamic>;
        final docId = docSnap.id;
        final name = doc['name'] ?? doc['email'];
        final email = doc['email'];

        final achievements = Map<String, dynamic>.from(
          doc['achievements'] ?? {},
        );
        final dates = achievements.keys.toList()..sort();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: $name",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Email: $email"),
                const SizedBox(height: 20),
                TextField(
                  controller: scoreController,
                  decoration: const InputDecoration(
                    labelText: "Performance Score",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: currentTargetController,
                  decoration: const InputDecoration(
                    labelText: "Current Target",
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 30),
                const SizedBox(height: 30),
                const Text(
                  "Achievements (Datewise)",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                ...dates.map(
                  (date) => ListTile(
                    title: Text("Date: $date"),
                    subtitle: Text("Token: ${achievements[date]}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          controller.removeAchievementByDate(docId, date),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildAddAchievementRow(docId),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.sync),
                  label: const Text("Auto Sync Performance & Target"),
                  onPressed: () async =>
                      controller.autoSumAchievementsToTarget(docId),
                  // await controller._syncPerformanceAndTarget(docId),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAddAchievementRow(String docId) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: achievementController,
            decoration: const InputDecoration(labelText: "Tokens Earned"),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 10),
        Obx(() => Text("Date: ${formatDate(selectedDate.value)}")),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showDatePicker(
              context: Get.context!,
              initialDate: selectedDate.value,
              firstDate: DateTime(2023),
              lastDate: DateTime(2100),
            );
            if (picked != null) selectedDate.value = picked;
          },
        ),
        ElevatedButton(
          onPressed: () {
            final tokens = int.tryParse(achievementController.text.trim());
            if (tokens != null && tokens > 0) {
              controller.addAchievementByDate(
                docId,
                formatDate(selectedDate.value),
                tokens,
              );
              achievementController.clear();
            } else {
              Get.snackbar("Error", "Enter a valid token value");
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }

  Widget _passwordPrompt() {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter Admin Password",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (passwordController.text == adminPassword) {
                        controller.isAuthenticated.value = true;
                        controller.fetchModels();
                      } else {
                        Get.snackbar("Access Denied", "Invalid password");
                      }
                    },
                    child: const Text("Enter"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
