import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/subscription_model.dart';
import '../../../../core/services/subscription_service.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(subscriptionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('🌐 我的订阅'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, '/subscription/add');
            },
          ),
        ],
      ),
      body: subscriptions.isEmpty
          ? _EmptyState(
              onAdd: () {
                Navigator.pushNamed(context, '/subscription/add');
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final sub = subscriptions[index];
                return _SubscriptionCard(
                  subscription: sub,
                  onToggle: () {
                    ref.read(subscriptionsProvider.notifier).toggleEnabled(sub.id);
                  },
                  onDelete: () {
                    _showDeleteDialog(context, ref, sub);
                  },
                  onSync: () async {
                    await _syncSubscription(context, ref, sub);
                  },
                );
              },
            ),
    );
  }

  Future<void> _syncSubscription(BuildContext context, WidgetRef ref, SubscriptionModel sub) async {
    final service = SubscriptionService();
    
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在同步...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    final content = await service.fetchSubscription(sub.url);
    if (content != null) {
      final nodes = service.parseGeneralSubscription(content);
      
      // Clear old nodes from this subscription
      final allNodes = ref.read(nodesProvider);
      for (final node in allNodes.where((n) => n.subscriptionId == sub.id)) {
        await ref.read(nodesProvider.notifier).deleteNode(node.id);
      }

      // Add new nodes
      final newNodes = nodes.map((proxy) => NodeModel(
        id: const Uuid().v4(),
        name: proxy.name,
        subscriptionId: sub.id,
        protocol: proxy.type,
        address: proxy.server,
        port: proxy.port,
        uuid: proxy.uuid,
        alterId: proxy.alterId,
        password: proxy.password,
        cipher: proxy.cipher,
        network: proxy.network,
        tls: proxy.tls,
      )).toList();

      await ref.read(nodesProvider.notifier).addNodes(newNodes);

      // Update subscription
      await ref.read(subscriptionsProvider.notifier).updateSubscription(
        sub.copyWith(
          nodeCount: newNodes.length,
          lastUpdated: DateTime.now(),
        ),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('同步成功，获取到 ${newNodes.length} 个节点'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('同步失败，请检查订阅地址'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, SubscriptionModel sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('删除订阅', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          '确定删除 "${sub.name}" 吗？这将同时删除 ${sub.nodeCount} 个节点。',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // Delete nodes first
              final nodes = ref.read(nodesProvider);
              for (final node in nodes.where((n) => n.subscriptionId == sub.id)) {
                ref.read(nodesProvider.notifier).deleteNode(node.id);
              }
              // Delete subscription
              ref.read(subscriptionsProvider.notifier).deleteSubscription(sub.id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_download_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无订阅',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '添加订阅以获取节点列表',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('添加订阅'),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onSync;

  const _SubscriptionCard({
    required this.subscription,
    required this.onToggle,
    required this.onDelete,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: subscription.enabled ? AppTheme.primaryColor.withOpacity(0.3) : AppTheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subscription.url.length > 40
                          ? '${subscription.url.substring(0, 40)}...'
                          : subscription.url,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: subscription.enabled,
                onChanged: (_) => onToggle(),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dns, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${subscription.nodeCount} 节点',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (subscription.lastUpdated != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        _formatLastUpdate(subscription.lastUpdated!),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.sync, color: AppTheme.primaryColor),
                onPressed: onSync,
                tooltip: '同步',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                onPressed: onDelete,
                tooltip: '删除',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }
}
