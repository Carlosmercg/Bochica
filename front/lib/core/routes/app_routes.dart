import 'package:flutter/material.dart';

import '../../auth/screens/auth_bienvenida_screen.dart';
import '../../auth/screens/auth_login_screen.dart';
import '../../auth/screens/auth_registro_screen.dart';
import '../../auth/screens/auth_perfil_screen.dart';
import '../../dashboards/screens/dashboard_general_usuario_screen.dart';
import '../../dashboards/screens/dashboard_solo_stats_screen.dart';
import '../../dashboards/screens/dashboard_stats_usuario_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../chatbot/screens/chatbot_recomendaciones_screen.dart';
import '../../tienda/screens/tienda_screen.dart';
import '../../tienda/screens/tienda_productos_screen.dart';
import '../../tienda/screens/tienda_detalle_producto_screen.dart';
import '../../tienda/screens/tienda_compra_info_screen.dart';
import '../../tienda/screens/tienda_compra_resultado_screen.dart';

class AppRoutes {
  static const String authWelcome = '/auth/welcome';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/profile';

  static const String dashboardGeneralUsuario = '/dashboard/general-usuario';
  static const String dashboardSoloStats = '/dashboard/solo-stats';
  static const String dashboardStatsUsuario = '/dashboard/stats-usuario';
  static const String chatbot = '/chatbot';
  static const String chatbotRecomendaciones  = '/chatbot/recomendaciones';
  static const String tiendaHome       = '/tienda';
  static const String tiendaProductos  = '/tienda/productos';
  static const String tiendaDetalle    = '/tienda/detalle';
  static const String tiendaCompraInfo = '/tienda/compra-info';
  static const String tiendaResultado  = '/tienda/compra-resultado';

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
         case chatbot:
        return MaterialPageRoute(builder: (_) => const ChatbotScreen());
      case chatbotRecomendaciones:
        return MaterialPageRoute(builder: (_) => const ChatbotRecomendacionesScreen());
      case tiendaHome:
        return MaterialPageRoute(builder: (_) => const TiendaScreen());

      case tiendaProductos:
        return MaterialPageRoute(builder: (_) => const TiendaProductosScreen());

      case tiendaDetalle:
        // Espera un Producto en settings.arguments
        return MaterialPageRoute(
          builder: (_) => const TiendaDetalleProductoScreen(),
          settings: settings,
        );

      case tiendaCompraInfo:
        return MaterialPageRoute(
          builder: (_) => const TiendaCompraInfoScreen(),
          settings: settings,
        );

      case tiendaResultado:
        return MaterialPageRoute(
          builder: (_) => const TiendaCompraResultadoScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => const AuthBienvenidaScreen());
    }
  }
}
