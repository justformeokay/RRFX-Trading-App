import 'package:get/get.dart';
import 'package:rrfx/src/controllers/network_controller.dart';
import 'package:rrfx/src/views/authentications/forgot.dart';
import 'package:rrfx/src/views/authentications/signin.dart';
import 'package:rrfx/src/views/authentications/signup.dart';
import 'package:rrfx/src/views/authentications/splashscreen.dart';
import 'package:rrfx/src/views/mainpage.dart';
import 'package:rrfx/src/views/no_auth_view/mainpage_no_auth.dart';
import 'package:rrfx/src/views/no_network_page.dart';

class GetUtilities {
  static final routes = [
    GetPage(name: '/', page: () => const MainpageWithoutLogin()),
    GetPage(name: '/splashscreen', page: () => const Splashscreen(), middlewares: [NetworkMiddleware()]),
    GetPage(name: '/login', page: () => const SignIn()),
    GetPage(name: '/signup', page: () => const Signup()),
    GetPage(name: '/login/signup', page: () => const Signup()),
    GetPage(name: '/login/forgot', page: () => const Forgot()),
    GetPage(name: '/login/forgot', page: () => const Forgot()),
    GetPage(name: '/login/passcode/mainpage', page: () => const Mainpage()),
    GetPage(name: '/no-network', page: () => const NoNetworkPage()),
    // GetPage(
    //   name: '/transactions',
    //   page: () => TransactionsPage(),
    //   binding: TransactionsBinding(),
    // ),

  ];
}