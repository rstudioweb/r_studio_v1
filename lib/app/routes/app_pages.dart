import 'package:get/get.dart';
import 'package:r_studio_v1/admin/views/admin_panel_view.dart'
    show AdminPanelView;
import 'package:r_studio_v1/app/views/dashboard_view.dart' show DashboardView;
import '../views/login_view.dart';
// import other views when ready
import '../routes/app_routes.dart';

class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => LoginView()),
    GetPage(name: Routes.DASHBOARD, page: () => DashboardView()),
    GetPage(name: Routes.ADMIN, page: () => AdminPanelView()),
  ];
}
