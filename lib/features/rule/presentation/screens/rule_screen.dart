import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/config_exporter_service.dart';
import '../../../node/data/models/node_model.dart';
import '../../data/models/rule_model.dart';

class RuleScreen extends ConsumerWidget {
  const RuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider);
    final ruleMode = ref.watch(ruleModeProvider);

    // Group rules by category
    final cnRules = rules.where((r) => r.category == 'CN').toList();
    final intlRules = rules.where((r) => r.category == 'International').toList();
    final adsRules = rules.where((r) => r.category == 'Ads').toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('⚡ 代理规则'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () => _showAddRuleDialog(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mode Selection
          _ModeSelector(
            currentMode: ruleMode,
            onChanged: (mode) => ref.read(ruleModeProvider.notifier).state = mode,
          ),
          const SizedBox(height: 24),

          // CN Rules
          _RuleSection(
            title: '🇨🇳 国内流量 (CN)',
            icon: Icons.home,
            color: AppTheme.successColor,
            rules: cnRules,
            defaultAction: RuleAction.direct,
            onRuleToggle: (id) => ref.read(rulesProvider.notifier).toggleRule(id),
            onRuleDelete: (id) => ref.read(rulesProvider.notifier).deleteRule(id),
          ),
          const SizedBox(height: 16),

          // International Rules
          _RuleSection(
            title: '🌍 国际流量',
            icon: Icons.public,
            color: AppTheme.primaryColor,
            rules: intlRules,
            defaultAction: RuleAction.proxy,
            onRuleToggle: (id) => ref.read(rulesProvider.notifier).toggleRule(id),
            onRuleDelete: (id) => ref.read(rulesProvider.notifier).deleteRule(id),
          ),
          const SizedBox(height: 16),

          // Ads Rules
          _RuleSection(
            title: '🚫 广告与追踪',
            icon: Icons.block,
            color: AppTheme.errorColor,
            rules: adsRules,
            defaultAction: RuleAction.reject,
            onRuleToggle: (id) => ref.read(rulesProvider.notifier).toggleRule(id),
            onRuleDelete: (id) => ref.read(rulesProvider.notifier).deleteRule(id),
          ),

          const SizedBox(height: 32),

          // Export Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _exportConfig(context, ref),
              icon: const Icon(Icons.download),
              label: const Text('📤 导出配置'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final patternController = TextEditingController();
    String selectedCategory = 'CN';
    int selectedType = RuleType.domainSuffix.index;
    int selectedAction = RuleAction.direct.index;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text('添加规则', style: TextStyle(color: AppTheme.textPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '规则名称',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: patternController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '匹配模式',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    hintText: '例如: google.com',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '分类',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CN', child: Text('🇨🇳 国内')),
                    DropdownMenuItem(value: 'International', child: Text('🌍 国际')),
                    DropdownMenuItem(value: 'Ads', child: Text('🚫 广告')),
                  ],
                  onChanged: (value) => setState(() => selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedType,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '匹配类型',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('DOMAIN')),
                    DropdownMenuItem(value: 1, child: Text('DOMAIN-SUFFIX')),
                    DropdownMenuItem(value: 2, child: Text('DOMAIN-KEYWORD')),
                    DropdownMenuItem(value: 3, child: Text('IP-CIDR')),
                    DropdownMenuItem(value: 4, child: Text('GEOIP')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedAction,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: '动作',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('🛜 PROXY')),
                    DropdownMenuItem(value: 1, child: Text('🏠 DIRECT')),
                    DropdownMenuItem(value: 2, child: Text('🚫 REJECT')),
                  ],
                  onChanged: (value) => setState(() => selectedAction = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && patternController.text.isNotEmpty) {
                  ref.read(rulesProvider.notifier).addRule(RuleModel(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    type: selectedType,
                    action: selectedAction,
                    pattern: patternController.text,
                    enabled: true,
                    category: selectedCategory,
                  ));
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _exportConfig(BuildContext context, WidgetRef ref) {
    final nodes = ref.read(nodesProvider);
    final rules = ref.read(rulesProvider);
    final mode = ref.read(ruleModeProvider);
    final connection = ref.read(connectionProvider);

    final exporter = ConfigExporterService();
    final proxies = nodes.map((n) => ProxyNode(
      name: n.name,
      type: n.protocol,
      server: n.address,
      port: n.port,
      uuid: n.uuid,
      alterId: n.alterId,
      password: n.password,
      cipher: n.cipher,
      network: n.network,
      tls: n.tls,
    )).toList();

    final config = exporter.exportToClash(
      proxies: proxies,
      rules: rules,
      selectedProxy: connection.selectedNode?.name ?? (nodes.isNotEmpty ? nodes.first.name : 'auto'),
      mode: mode == RuleMode.rule ? 'rule' : mode == RuleMode.global ? 'global' : 'direct',
    );

    Clipboard.setData(ClipboardData(text: config));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 配置已复制到剪贴板'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final RuleMode currentMode;
  final ValueChanged<RuleMode> onChanged;

  const _ModeSelector({required this.currentMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          _ModeButton(label: '规则', icon: Icons.rule, isSelected: currentMode == RuleMode.rule, onTap: () => onChanged(RuleMode.rule)),
          _ModeButton(label: '全局', icon: Icons.public, isSelected: currentMode == RuleMode.global, onTap: () => onChanged(RuleMode.global)),
          _ModeButton(label: '直连', icon: Icons.link_off, isSelected: currentMode == RuleMode.direct, onTap: () => onChanged(RuleMode.direct)),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({required this.label, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? AppTheme.backgroundColor : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.backgroundColor : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<RuleModel> rules;
  final RuleAction defaultAction;
  final ValueChanged<String> onRuleToggle;
  final ValueChanged<String> onRuleDelete;

  const _RuleSection({
    required this.title, required this.icon, required this.color,
    required this.rules, required this.defaultAction,
    required this.onRuleToggle, required this.onRuleDelete,
  });

  String _getActionText(RuleAction action) => switch (action) {
    RuleAction.proxy => 'PROXY',
    RuleAction.direct => 'DIRECT',
    RuleAction.reject => 'REJECT',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
                const Spacer(),
                Text('默认: ${_getActionText(defaultAction)}', style: TextStyle(fontSize: 12, color: color.withOpacity(0.7))),
              ],
            ),
          ),
          if (rules.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Text('暂无自定义规则', style: TextStyle(color: AppTheme.textSecondary)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rules.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderColor),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Dismissible(
                  key: Key(rule.id),
                  direction: DismissDirection.endToStart,
                  background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppTheme.errorColor, child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (_) => onRuleDelete(rule.id),
                  child: ListTile(
                    leading: Icon(_getActionIcon(rule.ruleAction), color: _getActionColor(rule.ruleAction)),
                    title: Text(rule.name, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
                    subtitle: Text('${_getTypeText(rule.ruleType)}, ${rule.pattern}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _getActionColor(rule.ruleAction).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: Text(_getActionText(rule.ruleAction), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getActionColor(rule.ruleAction))),
                        ),
                        const SizedBox(width: 8),
                        Switch(value: rule.enabled, onChanged: (_) => onRuleToggle(rule.id)),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getActionIcon(RuleAction action) => switch (action) {
    RuleAction.reject => Icons.block,
    RuleAction.direct => Icons.home,
    RuleAction.proxy => Icons.public,
  };

  Color _getActionColor(RuleAction action) => switch (action) {
    RuleAction.reject => AppTheme.errorColor,
    RuleAction.direct => AppTheme.successColor,
    RuleAction.proxy => AppTheme.primaryColor,
  };

  String _getTypeText(RuleType type) => switch (type) {
    RuleType.domain => 'DOMAIN',
    RuleType.domainSuffix => 'SUFFIX',
    RuleType.domainKeyword => 'KEYWORD',
    RuleType.ipCidr => 'CIDR',
    RuleType.geoip => 'GEOIP',
    RuleType.custom => 'MATCH',
  };
}
