import 'package:hive/hive.dart';

part 'node_model.g.dart';

@HiveType(typeId: 1)
class NodeModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String subscriptionId;
  
  @HiveField(3)
  final String protocol;
  
  @HiveField(4)
  final String address;
  
  @HiveField(5)
  final int port;
  
  @HiveField(6)
  final String? username;
  
  @HiveField(7)
  final String? password;
  
  @HiveField(8)
  final String? uuid;
  
  @HiveField(9)
  final String? alterId;
  
  @HiveField(10)
  final String? cipher;
  
  @HiveField(11)
  final String? network;
  
  @HiveField(12)
  final String? tls;
  
  @HiveField(13)
  final bool isFavorite;
  
  @HiveField(14)
  final int? latencyMs;
  
  @HiveField(15)
  final bool isOnline;
  
  NodeModel({
    required this.id,
    required this.name,
    required this.subscriptionId,
    required this.protocol,
    required this.address,
    required this.port,
    this.username,
    this.password,
    this.uuid,
    this.alterId,
    this.cipher,
    this.network,
    this.tls,
    this.isFavorite = false,
    this.latencyMs,
    this.isOnline = true,
  });
  
  NodeModel copyWith({
    String? id,
    String? name,
    String? subscriptionId,
    String? protocol,
    String? address,
    int? port,
    String? username,
    String? password,
    String? uuid,
    String? alterId,
    String? cipher,
    String? network,
    String? tls,
    bool? isFavorite,
    int? latencyMs,
    bool? isOnline,
  }) {
    return NodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      protocol: protocol ?? this.protocol,
      address: address ?? this.address,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      uuid: uuid ?? this.uuid,
      alterId: alterId ?? this.alterId,
      cipher: cipher ?? this.cipher,
      network: network ?? this.network,
      tls: tls ?? this.tls,
      isFavorite: isFavorite ?? this.isFavorite,
      latencyMs: latencyMs ?? this.latencyMs,
      isOnline: isOnline ?? this.isOnline,
    );
  }
  
  String get country {
    if (name.contains('🇺🇸') || name.toLowerCase().contains('us')) return '🇺🇸';
    if (name.contains('🇭🇰') || name.toLowerCase().contains('hk')) return '🇭🇰';
    if (name.contains('🇯🇵') || name.toLowerCase().contains('jp')) return '🇯🇵';
    if (name.contains('🇸🇬') || name.toLowerCase().contains('sg')) return '🇸🇬';
    if (name.contains('🇰🇷') || name.toLowerCase().contains('kr')) return '🇰🇷';
    if (name.contains('🇩🇪') || name.toLowerCase().contains('de')) return '🇩🇪';
    if (name.contains('🇬🇧') || name.toLowerCase().contains('uk')) return '🇬🇧';
    if (name.contains('🇨🇳') || name.toLowerCase().contains('cn')) return '🇨🇳';
    if (name.contains('🇹🇼') || name.toLowerCase().contains('tw')) return '🇹🇼';
    return '🌐';
  }
}

@HiveType(typeId: 2)
class ProxyNode {
  final String name;
  final String type;
  final String server;
  final int port;
  final String? uuid;
  final String? alterId;
  final String? password;
  final String? cipher;
  final String? network;
  final String? tls;
  
  ProxyNode({
    required this.name,
    required this.type,
    required this.server,
    required this.port,
    this.uuid,
    this.alterId,
    this.password,
    this.cipher,
    this.network,
    this.tls,
  });
  
  factory ProxyNode.fromJson(Map<String, dynamic> json) {
    return ProxyNode(
      name: json['name'] ?? '',
      type: json['type'] ?? 'vmess',
      server: json['server'] ?? '',
      port: json['port'] ?? 0,
      uuid: json['uuid'],
      alterId: json['alterId']?.toString(),
      password: json['password'],
      cipher: json['cipher'],
      network: json['network'],
      tls: json['tls'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'server': server,
    'port': port,
    if (uuid != null) 'uuid': uuid,
    if (alterId != null) 'alterId': alterId,
    if (password != null) 'password': password,
    if (cipher != null) 'cipher': cipher,
    if (network != null) 'network': network,
    if (tls != null) 'tls': tls,
  };
}
