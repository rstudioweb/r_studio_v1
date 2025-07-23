import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isAuthenticated = false.obs;
  RxList<DocumentSnapshot> models = <DocumentSnapshot>[].obs;
  Rx<DocumentSnapshot?> selectedModel = Rx<DocumentSnapshot?>(null);

  Future<void> fetchModels() async {
    final snapshot = await _firestore.collection('models').get();
    models.value = snapshot.docs;
  }

  Future<void> updateModelData(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('models').doc(uid).update(data);
    await fetchModels();
  }

  Future<void> addAchievementByDate(String uid, String date, int tokens) async {
    final docRef = _firestore.collection('models').doc(uid);

    await docRef.set({
      "achievements": {date: tokens},
    }, SetOptions(merge: true));

    await _syncPerformanceAndTarget(uid);
    await fetchModels();
  }

  Future<void> removeAchievementByDate(String uid, String date) async {
    final docRef = _firestore.collection('models').doc(uid);
    await docRef.update({"achievements.$date": FieldValue.delete()});

    await _syncPerformanceAndTarget(uid);
    await fetchModels();
  }

  Future<void> updatePerformanceAndTarget(
    String uid,
    int performanceScore,
    int currentTarget,
  ) async {
    final docRef = _firestore.collection("models").doc(uid);

    try {
      await docRef.update({
        "performanceScore": performanceScore,
        "targets.current": currentTarget,
      });

      selectedModel.value = await docRef.get();
      Get.snackbar("Success", "Performance & target updated");
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    }
  }

  Future<void> autoSumAchievementsToTarget(String uid) async {
    try {
      final docRef = _firestore.collection("models").doc(uid);
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) return;

      final achievements = Map<String, dynamic>.from(
        data['achievements'] ?? {},
      );
      final totalTokens = achievements.values.fold<int>(
        0,
        (sum, value) => sum + (value as int),
      );

      await docRef.update({"targets.current": totalTokens});

      selectedModel.value = await docRef.get();
      Get.snackbar("Synced", "Target updated from achievements");
    } catch (e) {
      Get.snackbar("Error", "Auto sync failed: $e");
    }
  }

  Future<void> _syncPerformanceAndTarget(String uid) async {
    final docRef = _firestore.collection("models").doc(uid);
    final doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) return;

    final achievements = Map<String, dynamic>.from(data['achievements'] ?? {});
    final totalTokens = achievements.values.fold<int>(
      0,
      (sum, value) => sum + (value as int),
    );

    final monthlyTarget = (data['targets']?['monthly'] ?? 0) as int;

    await docRef.update({
      "performanceScore": totalTokens,
      "targets.current": monthlyTarget - totalTokens,
    });

    selectedModel.value = await docRef.get();
  }
}
