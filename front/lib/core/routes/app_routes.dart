import 'package:flutter/material.dart';

import '../../auth/screens/auth_bienvenida_screen.dart';
import '../../auth/screens/auth_login_screen.dart';
import '../../auth/screens/auth_registro_screen.dart';
import '../../auth/screens/auth_perfil_screen.dart';
import '../../dashboards/screens/dashboard_general_usuario_screen.dart';
import '../../dashboards/screens/dashboard_solo_stats_screen.dart';
import '../../dashboards/screens/dashboard_perfil_screen.dart';
import '../../dashboards/screens/dashboard_vincular_screen.dart';
import '../../dashboards/screens/dashboard_configurar_screen.dart';
import '../../chatbot/screens/chatbot_screen.dart';
import '../../chatbot/screens/chatbot_recomendaciones_screen.dart';
import '../../tienda/screens/tienda_screen.dart';
import '../../tienda/screens/tienda_productos_screen.dart';
import '../../tienda/screens/tienda_detalle_producto_screen.dart';
import '../../tienda/screens/tienda_compra_info_screen.dart';
import '../../tienda/screens/tienda_compra_resultado_screen.dart';
import '../../registro_disp/screens/registro_disp_estados_screen.dart';
import '../../registro_disp/screens/registro_disp_interacciones_screen.dart';

class AppRoutes {
  static const String authWelcome = '/auth/welcome';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/profile';

  static const String dashboardGeneralUsuario = '/dashboard/general-usuario';
  static const String dashboardSoloStats = '/dashboard/solo-stats';
  static const String dashboardPerfil = '/dashboard/perfil';
  static const String dashboardVincular = '/dashboard/vincular';
  static const String dashboardConfigurar = '/dashboard/configurar';
  static const String chatbot = '/chatbot';
  static const String chatbotRecomendaciones  = '/chatbot/recomendaciones';
  static const String tiendaHome       = '/tienda';
  static const String tiendaProductos  = '/tienda/productos';
  static const String tiendaDetalle    = '/tienda/detalle';
  static const String tiendaCompraInfo = '/tienda/compra-info';
  static const String tiendaResultado  = '/tienda/compra-resultado';
  static const String estados = '/estado';
  static const String estadosHistorial = '/estado/historial';

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
      case dashboardPerfil:
        return MaterialPageRoute(
          builder: (_) => const DashboardPerfilScreen(),
        );
      case dashboardVincular:
        return MaterialPageRoute(
          builder: (_) => const DashboardVincularScreen(),
        );
      case dashboardConfigurar:
        return MaterialPageRoute(
          builder: (_) => const DashboardConfigurarScreen(),
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
      case estados:
        return MaterialPageRoute(
          builder: (_) => const RegistroDispEstadosScreen(),
        );

      case estadosHistorial:
        // Recibe: {'deviceTitle': String, 'kind': 'sanitario'|'ducha', 'connected': bool}
        return MaterialPageRoute(
          builder: (_) => const RegistroDispInteraccionesScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(builder: (_) => const AuthBienvenidaScreen());
    }
  }
}
