import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/subscription/data/models/subscription_model.dart';
import '../../features/node/data/models/node_model.dart';
import '../../features/rule/data/models/rule_model.dart';
import '../../core/constants/app_constants.dart';

// Connection State
enum ConnectionStatus { disconnected, connecting, connected }

class ConnectionState {
  final ConnectionStatus status;
  final NodeModel? selectedNode;
  final String? trafficUp;
  final String? trafficDown;

  const ConnectionState({
    this.status = ConnectionStatus.disconnected,
    this.selectedNode,
    this.trafficUp,
    this.trafficDown,
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    NodeModel? selectedNode,
    String? trafficUp,
    String? trafficDown,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      selectedNode: selectedNode ?? this.selectedNode,
      trafficUp: trafficUp ?? this.trafficUp,
      trafficDown: trafficDown ?? this.trafficDown,
    );
  }
}

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  ConnectionNotifier() : super(const ConnectionState());

  void selectNode(NodeModel node) {
    state = state.copyWith(selectedNode: node);
  }

  void connect() {
    if (state.selectedNode == null) return;
    state = state.copyWith(status: ConnectionStatus.connecting);
    // Simulate connection
    Future.delayed(const Duration(seconds: 1), () {
      state = state.copyWith(status: ConnectionStatus.connected);
    });
  }

  void disconnect() {
    state = state.copyWith(
      status: ConnectionStatus.disconnected,
      trafficUp: null,
      trafficDown: null,
    );
  }

  void updateTraffic(String up, String down) {
    state = state.copyWith(trafficUp: up, trafficDown: down);
  }
}

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>((ref) {
  return ConnectionNotifier();
});

// Subscriptions Provider
final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier, List<SubscriptionModel>>((ref) {
  return SubscriptionsNotifier();
});

class SubscriptionsNotifier extends StateNotifier<List<SubscriptionModel>> {
  SubscriptionsNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final box = Hive.box<SubscriptionModel>(AppConstants.subscriptionsBox);
    state = box.values.toList();
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    final box = Hive.box<SubscriptionModel>(AppConstants.subscriptionsBox);
    await box.put(sub.id, sub);
    state = [...state, sub];
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    final box = Hive.box<SubscriptionModel>(AppConstants.subscriptionsBox);
    await box.put(sub.id, sub);
    state = state.map((s) => s.id == sub.id ? sub : s).toList();
  }

  Future<void> deleteSubscription(String id) async {
    final box = Hive.box<SubscriptionModel>(AppConstants.subscriptionsBox);
    await box.delete(id);
    state = state.where((s) => s.id != id).toList();
  }

  Future<void> toggleEnabled(String id) async {
    final sub = state.firstWhere((s) => s.id == id);
    final updated = sub.copyWith(enabled: !sub.enabled);
    await updateSubscription(updated);
  }
}

// Nodes Provider
final nodesProvider = StateNotifierProvider<NodesNotifier, List<NodeModel>>((ref) {
  return NodesNotifier();
});

class NodesNotifier extends StateNotifier<List<NodeModel>> {
  NodesNotifier() : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    state = box.values.toList();
  }

  Future<void> addNode(NodeModel node) async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    await box.put(node.id, node);
    state = [...state, node];
  }

  Future<void> addNodes(List<NodeModel> nodes) async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    for (final node in nodes) {
      await box.put(node.id, node);
    }
    state = [...state, ...nodes];
  }

  Future<void> updateNode(NodeModel node) async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    await box.put(node.id, node);
    state = state.map((n) => n.id == node.id ? node : n).toList();
  }

  Future<void> deleteNode(String id) async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    await box.delete(id);
    state = state.where((n) => n.id != id).toList();
  }

  Future<void> toggleFavorite(String id) async {
    final node = state.firstWhere((n) => n.id == id);
    final updated = node.copyWith(isFavorite: !node.isFavorite);
    await updateNode(updated);
  }

  Future<void> updateLatency(String id, int? latency) async {
    final node = state.firstWhere((n) => n.id == id);
    final updated = node.copyWith(latencyMs: latency);
    await updateNode(updated);
  }

  Future<void> clearAll() async {
    final box = Hive.box<NodeModel>(AppConstants.nodesBox);
    await box.clear();
    state = [];
  }
}

// Filtered Nodes Provider
final filteredNodesProvider = Provider<List<NodeModel>>((ref) {
  final nodes = ref.watch(nodesProvider);
  final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
  final protocolFilter = ref.watch(protocolFilterProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  var filtered = nodes;

  if (showFavoritesOnly) {
    filtered = filtered.where((n) => n.isFavorite).toList();
  }

  if (protocolFilter != null && protocolFilter.isNotEmpty) {
    filtered = filtered.where((n) => n.protocol.toLowerCase() == protocolFilter.toLowerCase()).toList();
  }

  if (searchQuery.isNotEmpty) {
    filtered = filtered.where((n) =>
      n.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
      n.address.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();
  }

  // Sort by latency
  filtered.sort((a, b) {
    if (a.latencyMs == null && b.latencyMs == null) return 0;
    if (a.latencyMs == null) return 1;
    if (b.latencyMs == null) return -1;
    return a.latencyMs!.compareTo(b.latencyMs!);
  });

  return filtered;
});

final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);
final protocolFilterProvider = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');

// Rules Provider
final rulesProvider = StateNotifierProvider<RulesNotifier, List<RuleModel>>((ref) {
  return RulesNotifier();
});

class RulesNotifier extends StateNotifier<List<RuleModel>> {
  RulesNotifier() : super([]) {
    _loadDefaults();
  }

  void _loadDefaults() {
    // Default rules
    state = [
      RuleModel(
        id: '1',
        name: 'Direct - CN',
        type: RuleType.geoip.index,
        action: RuleAction.direct.index,
        pattern: 'CN',
        enabled: true,
        category: 'CN',
      ),
      RuleModel(
        id: '2',
        name: 'Proxy - Others',
        type: RuleType.custom.index,
        action: RuleAction.proxy.index,
        pattern: 'MATCH',
        enabled: true,
        category: 'International',
      ),
      RuleModel(
        id: '3',
        name: 'Reject Ads',
        type: RuleType.domainSuffix.index,
        action: RuleAction.reject.index,
        pattern: 'doubleclick.net',
        enabled: true,
        category: 'Ads',
      ),
    ];
  }

  Future<void> addRule(RuleModel rule) async {
    final box = Hive.box<RuleModel>(AppConstants.rulesBox);
    await box.put(rule.id, rule);
    state = [...state, rule];
  }

  Future<void> updateRule(RuleModel rule) async {
    final box = Hive.box<RuleModel>(AppConstants.rulesBox);
    await box.put(rule.id, rule);
    state = state.map((r) => r.id == rule.id ? rule : r).toList();
  }

  Future<void> deleteRule(String id) async {
    final box = Hive.box<RuleModel>(AppConstants.rulesBox);
    await box.delete(id);
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> toggleRule(String id) async {
    final rule = state.firstWhere((r) => r.id == id);
    final updated = rule.copyWith(enabled: !rule.enabled);
    await updateRule(updated);
  }
}

// Rule Mode Provider
enum RuleMode { rule, global, direct }

final ruleModeProvider = StateProvider<RuleMode>((ref) => RuleMode.rule);

// Settings Provider
class SettingsState {
  final String theme;
  final bool notificationsEnabled;
  final int autoTestInterval;
  final bool autoReconnect;
  final bool smartSelect;
  final String language;

  const SettingsState({
    this.theme = 'dark',
    this.notificationsEnabled = true,
    this.autoTestInterval = 30,
    this.autoReconnect = true,
    this.smartSelect = false,
    this.language = 'zh_CN',
  });

  SettingsState copyWith({
    String? theme,
    bool? notificationsEnabled,
    int? autoTestInterval,
    bool? autoReconnect,
    bool? smartSelect,
    String? language,
  }) {
    return SettingsState(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoTestInterval: autoTestInterval ?? this.autoTestInterval,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      smartSelect: smartSelect ?? this.smartSelect,
      language: language ?? this.language,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final box = Hive.box(AppConstants.settingsBox);
    state = SettingsState(
      theme: box.get('theme', defaultValue: 'dark'),
      notificationsEnabled: box.get('notifications', defaultValue: true),
      autoTestInterval: box.get('autoTestInterval', defaultValue: 30),
      autoReconnect: box.get('autoReconnect', defaultValue: true),
      smartSelect: box.get('smartSelect', defaultValue: false),
      language: box.get('language', defaultValue: 'zh_CN'),
    );
  }

  Future<void> updateSettings(SettingsState settings) async {
    final box = Hive.box(AppConstants.settingsBox);
    await box.put('theme', settings.theme);
    await box.put('notifications', settings.notificationsEnabled);
    await box.put('autoTestInterval', settings.autoTestInterval);
    await box.put('autoReconnect', settings.autoReconnect);
    await box.put('smartSelect', settings.smartSelect);
    await box.put('language', settings.language);
    state = settings;
  }
}
