import 'package:flutter/material.dart';
import 'pages/admin_shell.dart';

export 'pages/admin_home_page.dart';
export 'pages/admin_shell.dart';
export 'pages/core/router.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) => const AdminShell();
}
