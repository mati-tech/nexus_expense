import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  print('🔍 API Base URL: ${ApiService.baseUrl}');
  runApp(const NexusLedgerApp());
}

class NexusLedgerApp extends StatelessWidget {
  const NexusLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(api)..bootstrap(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionProvider>(
          create: (context) => TransactionProvider(
            api: api,
            auth: context.read<AuthProvider>(),
          ),
          update: (_, auth, previous) =>
          previous ?? TransactionProvider(api: api, auth: auth),
        ),
      ],
      child: MaterialApp(
        title: 'Nexus Ledger',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.bootstrapping) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
