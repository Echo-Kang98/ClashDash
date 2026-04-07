import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/speed_test_service.dart';

class NodeListScreen extends ConsumerStatefulWidget {
  const NodeListScreen({super.key});

  @override
  ConsumerState<NodeListScreen> createState() => _NodeListScreenState();
}

class _NodeListScreenState extends ConsumerState<NodeListScreen> {
  final _searchController = TextEditingController();
  bool _isTesting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _testAllNodes() async {
    setState(() => _isTesting = true);
    
    final nodes = ref.read(nodesProvider);
    final service = SpeedTestService();
    
    for (final node in nodes) {
      final latency = await service.testLatency(node);
      ref.read(nodesProvider.notifier).updateLatency(node.id, latency);
    }
    
    setState(() => _isTesting = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('测速完成'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNodes = ref.watch(filteredNodesProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final protocolFilter = ref.watch(protocolFilterProvider);
    final connection = ref.watch(connectionProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('📂 节点列表'),
        backgroundColor: AppTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _NodeSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '全部',
                  isSelected: !showFavoritesOnly && protocolFilter == null,
                  onTap: () {
                    ref.read(showFavoritesOnlyProvider.notifier).state = false;
                    ref.read(protocolFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '⭐ 收藏',
                  isSelected: showFavoritesOnly,
                  onTap: () {
                    ref.read(showFavoritesOnlyProvider.notifier).state = !showFavoritesOnly;
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Vmess',
                  isSelected: protocolFilter == 'vmess',
                  color: AppTheme.getProtocolColor('vmess'),
                  onTap: () {
                    ref.read(protocolFilterProvider.notifier).state =
                        protocolFilter == 'vmess' ? null : 'vmess';
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'SS',
                  isSelected: protocolFilter == 'ss',
                  color: AppTheme.getProtocolColor('ss'),
                  onTap: () {
                    ref.read(protocolFilterProvider.notifier).state =
                        protocolFilter == 'ss' ? null : 'ss';
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Trojan',
                  isSelected: protocolFilter == 'trojan',
                  color: AppTheme.getProtocolColor('trojan'),
                  onTap: () {
                    ref.read(protocolFilterProvider.notifier).state =
                        protocolFilter == 'trojan' ? null : 'trojan';
                  },
                ),
              ],
            ),
          ),

          // Node List
          Expanded(
            child: filteredNodes.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredNodes.length,
                    itemBuilder: (context, index) {
                      final node = filteredNodes[index];
                      final isSelected = connection.selectedNode?.id == node.id;
                      final isFastest = index == 0 && filteredNodes.first.latencyMs != null;

                      return _NodeCard(
                        node: node,
                        isSelected: isSelected,
                        isFastest: isFastest,
                        onTap: () {
                          ref.read(connectionProvider.notifier).selectNode(node);
                          Navigator.pop(context);
                        },
                        onFavorite: () {
                          ref.read(nodesProvider.notifier).toggleFavorite(node.id);
                        },
                        onDelete: () {
                          _showDeleteDialog(context, ref, node.id, node.name);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isTesting ? null : _testAllNodes,
        backgroundColor: AppTheme.primaryColor,
        icon: _isTesting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.backgroundColor,
                ),
              )
            : const Icon(Icons.speed, color: AppTheme.backgroundColor),
        label: Text(
          _isTesting ? '测速中...' : '⚡ 测速全部',
          style: const TextStyle(color: AppTheme.backgroundColor),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('删除节点', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          '确定删除 "$name" 吗？',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              ref.read(nodesProvider.notifier).deleteNode(id);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? AppTheme.primaryColor).withOpacity(0.2)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (color ?? AppTheme.primaryColor)
                : AppTheme.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (color ?? AppTheme.primaryColor)
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final dynamic node;
  final bool isSelected;
  final bool isFastest;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;

  const _NodeCard({
    required this.node,
    required this.isSelected,
    required this.isFastest,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(node.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Country Flag
              Container(
                width: 44,
                height: 44,
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
              const SizedBox(width: 12),

              // Node Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            node.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isFastest) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_events, size: 12, color: AppTheme.warningColor),
                                SizedBox(width: 2),
                                Text(
                                  '最快',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.warningColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Protocol Badge
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
                        if (node.tls != null) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.lock, size: 12, color: AppTheme.successColor),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Latency & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (node.latencyMs != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getLatencyColor(node.latencyMs).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed,
                            size: 12,
                            color: AppTheme.getLatencyColor(node.latencyMs),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${node.latencyMs}ms',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.getLatencyColor(node.latencyMs),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      '--',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      node.isFavorite ? Icons.star : Icons.star_border,
                      size: 20,
                      color: node.isFavorite ? AppTheme.warningColor : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无节点',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '添加订阅以获取节点',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/subscription/add');
            },
            icon: const Icon(Icons.add),
            label: const Text('添加订阅'),
          ),
        ],
      ),
    );
  }
}

class _NodeSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _NodeSearchDelegate(this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.backgroundColor,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: AppTheme.textSecondary),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppTheme.textPrimary),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final nodes = ref.watch(nodesProvider);
    final results = nodes.where((node) =>
        node.name.toLowerCase().contains(query.toLowerCase()) ||
        node.address.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final node = results[index];
        return ListTile(
          leading: Text(node.country, style: const TextStyle(fontSize: 24)),
          title: Text(
            node.name,
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          subtitle: Text(
            node.address,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          onTap: () {
            ref.read(connectionProvider.notifier).selectNode(node);
            close(context, node.name);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
