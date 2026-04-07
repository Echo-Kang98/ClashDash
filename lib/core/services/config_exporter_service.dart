import 'package:yaml/yaml.dart';
import '../../../features/node/data/models/node_model.dart';
import '../../../features/rule/data/models/rule_model.dart';

class ConfigExporterService {
  /// Export to Clash YAML format
  String exportToClash({
    required List<ProxyNode> proxies,
    required List<RuleModel> rules,
    required String selectedProxy,
    String mode = 'rule',
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('port: 7890');
    buffer.writeln('socks-port: 7891');
    buffer.writeln('redir-port: 7892');
    buffer.writeln('allow-lan: false');
    buffer.writeln('mode: $mode');
    buffer.writeln('log-level: info');
    buffer.writeln('external-controller: 127.0.0.1:9090');
    buffer.writeln();
    
    buffer.writeln('proxies:');
    for (final proxy in proxies) {
      buffer.writeln('  - name: "${proxy.name}"');
      buffer.writeln('    type: ${proxy.type}');
      buffer.writeln('    server: ${proxy.server}');
      buffer.writeln('    port: ${proxy.port}');
      
      if (proxy.uuid != null) {
        buffer.writeln('    uuid: ${proxy.uuid}');
      }
      if (proxy.alterId != null) {
        buffer.writeln('    alterId: ${proxy.alterId}');
      }
      if (proxy.cipher != null) {
        buffer.writeln('    cipher: ${proxy.cipher}');
      }
      if (proxy.password != null) {
        buffer.writeln('    password: ${proxy.password}');
      }
      if (proxy.network != null) {
        buffer.writeln('    network: ${proxy.network}');
      }
      if (proxy.tls != null) {
        buffer.writeln('    tls: ${proxy.tls}');
      }
      buffer.writeln();
    }
    
    buffer.writeln('proxy-groups:');
    buffer.writeln('  - name: "PROXY"');
    buffer.writeln('    type: select');
    buffer.writeln('    proxies:');
    buffer.writeln('      - $selectedProxy');
    for (final proxy in proxies) {
      if (proxy.name != selectedProxy) {
        buffer.writeln('      - "${proxy.name}"');
      }
    }
    buffer.writeln();
    
    buffer.writeln('rules:');
    for (final rule in rules.where((r) => r.enabled)) {
      buffer.writeln('  - ${rule.toClashRule()}');
    }
    buffer.writeln('  - MATCH,PROXY');
    
    return buffer.toString();
  }
  
  /// Generate Clash config from raw YAML (for editing existing)
  String generateFromYaml(String yamlContent) {
    try {
      final yaml = loadYaml(yamlContent);
      if (yaml == null) return yamlContent;
      
      // Just return formatted YAML for now
      return yamlContent;
    } catch (_) {
      return yamlContent;
    }
  }
}
