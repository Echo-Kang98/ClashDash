import 'package:hive/hive.dart';

part 'rule_model.g.dart';

enum RuleType {
  domain,
  domainSuffix,
  domainKeyword,
  ipCidr,
  geoip,
  custom,
}

enum RuleAction {
  proxy,
  direct,
  reject,
}

@HiveType(typeId: 3)
class RuleModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final int type; // RuleType index
  
  @HiveField(3)
  final int action; // RuleAction index
  
  @HiveField(4)
  final String pattern;
  
  @HiveField(5)
  final bool enabled;
  
  @HiveField(6)
  final String? category; // CN, International, Ads, etc.
  
  RuleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.action,
    required this.pattern,
    this.enabled = true,
    this.category,
  });
  
  RuleModel copyWith({
    String? id,
    String? name,
    int? type,
    int? action,
    String? pattern,
    bool? enabled,
    String? category,
  }) {
    return RuleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      action: action ?? this.action,
      pattern: pattern ?? this.pattern,
      enabled: enabled ?? this.enabled,
      category: category ?? this.category,
    );
  }
  
  RuleType get ruleType => RuleType.values[type];
  RuleAction get ruleAction => RuleAction.values[action];
  
  String toClashRule() {
    final actionStr = switch (ruleAction) {
      RuleAction.proxy => 'PROXY',
      RuleAction.direct => 'DIRECT',
      RuleAction.reject => 'REJECT',
    };
    
    final typeStr = switch (ruleType) {
      RuleType.domain => 'DOMAIN',
      RuleType.domainSuffix => 'DOMAIN-SUFFIX',
      RuleType.domainKeyword => 'DOMAIN-KEYWORD',
      RuleType.ipCidr => 'IP-CIDR',
      RuleType.geoip => 'GEOIP',
      RuleType.custom => 'MATCH',
    };
    
    return '$typeStr,$pattern,$actionStr';
  }
}
