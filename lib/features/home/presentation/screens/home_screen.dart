import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(connectionProvider);
    final selectedNode = connection.selectedNode;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🚀 ClashDash',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                    icon: const Icon(Icons.settings, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Connect Button
              Expanded(
                child: Center(
                  child: _ConnectButton(
                    status: connection.status,
                    onTap: () {
                      final notifier = ref.read(connectionProvider.notifier);
                      if (connection.status == ConnectionStatus.disconnected) {
                        if (selectedNode != null) {
                          notifier.connect();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('请先选择一个节点'),
                              backgroundColor: AppTheme.warningColor,
                            ),
                          );
                        }
                      } else {
                        notifier.disconnect();
                      }
                    },
                  ),
                ),
              ),

              // Current Node Card
              if (selectedNode != null)
                _NodeCard(
                  node: selectedNode,
                  status: connection.status,
                  trafficUp: connection.trafficUp,
                  trafficDown: connection.trafficDown,
                  onTap: () {
                    Navigator.pushNamed(context, '/nodes');
                  },
                )
              else
                _EmptyNodeCard(
                  onTap: () {
                    Navigator.pushNamed(context, '/nodes');
                  },
                ),

              const SizedBox(height: 20),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionButton(
                    icon: Icons.speed,
                    label: '测速',
                    onTap: () {
                      Navigator.pushNamed(context, '/nodes');
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.bar_chart,
                    label: '流量',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.rule,
                    label: '规则',
                    onTap: () {
                      Navigator.pushNamed(context, '/rules');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final ConnectionStatus status;
  final VoidCallback onTap;

  const _ConnectButton({required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isConnected = status == ConnectionStatus.connected;
    final isConnecting = status == ConnectionStatus.connecting;

    return GestureDetector(
      onTap: isConnecting ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected
                  ? AppTheme.successColor.withOpacity(0.2)
                  : AppTheme.cardColor,
              border: Border.all(
                color: isConnected
                    ? AppTheme.successColor
                    : isConnecting
                        ? AppTheme.warningColor
                        : AppTheme.primaryColor,
                width: 3,
              ),
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: AppTheme.successColor.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isConnecting
                  ? const CircularProgressIndicator(
                      color: AppTheme.warningColor,
                    )
                  : Icon(
                      isConnected ? Icons.link_off : Icons.power_settings_new,
                      size: 60,
                      color: isConnected
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isConnecting
                ? '连接中...'
                : isConnected
                    ? '已连接 ✓'
                    : '点击连接',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isConnected
                  ? AppTheme.successColor
                  : isConnecting
                      ? AppTheme.warningColor
                      : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final dynamic node;
  final ConnectionStatus status;
  final String? trafficUp;
  final String? trafficDown;
  final VoidCallback onTap;

  const _NodeCard({
    required this.node,
    required this.status,
    this.trafficUp,
    this.trafficDown,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isConnected = status == ConnectionStatus.connected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isConnected ? AppTheme.successColor : AppTheme.borderColor,
            width: isConnected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  node.country,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '当前节点',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, size: 8, color: AppTheme.successColor),
                              SizedBox(width: 4),
                              Text(
                                '在线',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    node.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getProtocolColor(node.protocol).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          node.protocol.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.getProtocolColor(node.protocol),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (node.latencyMs != null) ...[
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: AppTheme.getLatencyColor(node.latencyMs),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${node.latencyMs}ms',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.getLatencyColor(node.latencyMs),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _EmptyNodeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyNodeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择节点',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '点击选择要使用的节点',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
