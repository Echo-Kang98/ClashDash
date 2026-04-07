import 'package:hive/hive.dart';

part 'subscription_model.g.dart';

@HiveType(typeId: 0)
class SubscriptionModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String url;
  
  @HiveField(3)
  final bool enabled;
  
  @HiveField(4)
  final DateTime? lastUpdated;
  
  @HiveField(5)
  final int nodeCount;
  
  SubscriptionModel({
    required this.id,
    required this.name,
    required this.url,
    this.enabled = true,
    this.lastUpdated,
    this.nodeCount = 0,
  });
  
  SubscriptionModel copyWith({
    String? id,
    String? name,
    String? url,
    bool? enabled,
    DateTime? lastUpdated,
    int? nodeCount,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      enabled: enabled ?? this.enabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      nodeCount: nodeCount ?? this.nodeCount,
    );
  }
}
