import 'package:flutter/material.dart';

import '../../auth/screens/auth_bienvenida_screen.dart';
import '../../auth/screens/auth_login_screen.dart';
import '../../auth/screens/auth_registro_screen.dart';
import '../../auth/screens/auth_perfil_screen.dart';
import '../../dashboards/screens/dashboard_general_usuario_screen.dart';
import '../../dashboards/screens/dashboard_solo_stats_screen.dart';
import '../../dashboards/screens/dashboard_stats_usuario_screen.dart';

class AppRoutes {
  static const String authWelcome = '/auth/welcome';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/profile';

  static const String dashboardGeneralUsuario = '/dashboard/general-usuario';
  static const String dashboardSoloStats = '/dashboard/solo-stats';
  static const String dashboardStatsUsuario = '/dashboard/stats-usuario';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authWelcome:
        return MaterialPageRoute(builder: (_) => const AuthBienvenidaScreen());
      case authLogin:
        return MaterialPageRoute(builder: (_) => const AuthLoginScreen());
      case authRegister:
        return MaterialPageRoute(builder: (_) => const AuthRegistroScreen());
      case authProfile:
        return MaterialPageRoute(builder: (_) => const AuthPerfilScreen());
      case dashboardGeneralUsuario:
        return MaterialPageRoute(
          builder: (_) => const DashboardGeneralUsuarioScreen(),
        );
      case dashboardSoloStats:
        return MaterialPageRoute(
          builder: (_) => const DashboardSoloStatsScreen(),
        );
      case dashboardStatsUsuario:
        return MaterialPageRoute(
          builder: (_) => const DashboardStatsUsuarioScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthBienvenidaScreen());
    }
  }
}
