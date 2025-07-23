import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:r_studio_v1/app/controllers/auth_controller.dart';
import 'package:r_studio_v1/app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Firebase services if needed
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD1HJQ8gCnZ1dAK0o-ERlLyOBukWga3Dps",
      authDomain: "rstudio-e670f.firebaseapp.com",
      projectId: "rstudio-e670f",
      storageBucket: "rstudio-e670f.firebasestorage.app",
      messagingSenderId: "596399747115",
      appId: "1:596399747115:web:b1e3542a74fef9c907ba6e",
      measurementId: "G-859TCTF76V",
    ),
  );
  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  Get.put(AuthController()); // global controller
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Model WebApp',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
