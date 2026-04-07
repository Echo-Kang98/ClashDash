import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('⚙️ 设置'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Basic Settings
          _SectionTitle(title: '基础设置'),
          _SettingsTile(
            icon: Icons.palette,
            title: 'App 主题',
            subtitle: settings.theme == 'dark' ? '深色' : '浅色',
            trailing: DropdownButton<String>(
              value: settings.theme,
              dropdownColor: AppTheme.cardColor,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'dark', child: Text('深色', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 'light', child: Text('浅色', style: TextStyle(color: AppTheme.textPrimary))),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(theme: value));
                }
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.notifications,
            title: '通知推送',
            subtitle: '接收连接状态通知',
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(notificationsEnabled: value));
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.language,
            title: '语言',
            subtitle: settings.language == 'zh_CN' ? '简体中文' : 'English',
            trailing: DropdownButton<String>(
              value: settings.language,
              dropdownColor: AppTheme.cardColor,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'zh_CN', child: Text('简体中文', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 'en_US', child: Text('English', style: TextStyle(color: AppTheme.textPrimary))),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(language: value));
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // Proxy Settings
          _SectionTitle(title: '代理设置'),
          _SettingsTile(
            icon: Icons.timer,
            title: '自动测速间隔',
            subtitle: '${settings.autoTestInterval} 分钟',
            trailing: DropdownButton<int>(
              value: settings.autoTestInterval,
              dropdownColor: AppTheme.cardColor,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 15, child: Text('15分钟', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 30, child: Text('30分钟', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 60, child: Text('1小时', style: TextStyle(color: AppTheme.textPrimary))),
                DropdownMenuItem(value: 0, child: Text('关闭', style: TextStyle(color: AppTheme.textPrimary))),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(autoTestInterval: value));
                }
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.refresh,
            title: '断线自动重连',
            subtitle: '连接断开时自动重试',
            trailing: Switch(
              value: settings.autoReconnect,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(autoReconnect: value));
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.auto_awesome,
            title: '智能选节点',
            subtitle: '自动选择延迟最低的节点',
            trailing: Switch(
              value: settings.smartSelect,
              onChanged: (value) {
                ref.read(settingsProvider.notifier).updateSettings(settings.copyWith(smartSelect: value));
              },
            ),
          ),

          const SizedBox(height: 24),

          // Data Management
          _SectionTitle(title: '数据管理'),
          _SettingsTile(
            icon: Icons.storage,
            title: '清除缓存',
            subtitle: '清理订阅缓存数据',
            onTap: () {
              _showClearCacheDialog(context, ref);
            },
          ),
          _SettingsTile(
            icon: Icons.download,
            title: '导出全部配置',
            subtitle: '导出所有订阅和规则',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配置已导出'), backgroundColor: AppTheme.successColor),
              );
            },
          ),

          const SizedBox(height: 24),

          // About
          _SectionTitle(title: '关于'),
          _SettingsTile(
            icon: Icons.info,
            title: '版本信息',
            subtitle: 'v1.0.0',
          ),
          _SettingsTile(
            icon: Icons.description,
            title: '用户协议 & 隐私政策',
            onTap: () {},
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('清除缓存', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          '确定要清除所有缓存数据吗？这不会删除您的订阅和节点。',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除'), backgroundColor: AppTheme.successColor),
              );
            },
            child: const Text('清除', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
