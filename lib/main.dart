import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/main/screens/main_screen.dart';
import 'features/subscription/presentation/screens/add_subscription_screen.dart';
import 'features/subscription/data/models/subscription_model.dart';
import 'features/node/data/models/node_model.dart';
import 'features/rule/data/models/rule_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(SubscriptionModelAdapter());
  Hive.registerAdapter(NodeModelAdapter());
  Hive.registerAdapter(RuleModelAdapter());
  
  // Open Hive Boxes
  await Hive.openBox<SubscriptionModel>(AppConstants.subscriptionsBox);
  await Hive.openBox<NodeModel>(AppConstants.nodesBox);
  await Hive.openBox<RuleModel>(AppConstants.rulesBox);
  await Hive.openBox(AppConstants.settingsBox);
  
  runApp(const ProviderScope(child: ClashDashApp()));
}

class ClashDashApp extends StatelessWidget {
  const ClashDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClashDash',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/subscription/add': (context) => const AddSubscriptionScreen(),
      ],
    );
  }
}
