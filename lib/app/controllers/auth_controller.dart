import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:r_studio_v1/app/routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.offAllNamed(Routes.LOGIN);
        //Get.offAllNamed(Routes.ADMIN);
      }
    });
  }

  void login(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "Unknown error");
    } finally {
      isLoading.value = false;
    }
  }

  void register(String email, String password) async {
    try {
      isLoading.value = true;
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Registration Failed", e.message ?? "Unknown error");
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
  }
}
