import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yaml/yaml.dart';

import '../../../features/node/data/models/node_model.dart';

class SubscriptionService {
  static const _userAgent = 'ClashDash/1.0';
  
  /// Fetch and parse subscription content
  Future<String?> fetchSubscription(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': _userAgent},
      );
      
      if (response.statusCode == 200) {
        // Check if it's base64 encoded
        final content = response.body.trim();
        try {
          return utf8.decode(base64.decode(content));
        } catch (_) {
          return content;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Parse Clash subscription YAML content
  List<ProxyNode> parseClashConfig(String content) {
    try {
      final yaml = loadYaml(content);
      if (yaml == null || yaml['proxies'] == null) return [];
      
      final List<dynamic> proxies = yaml['proxies'];
      return proxies.map((p) => ProxyNode.fromJson(Map<String, dynamic>.from(p))).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Parse general subscription (base64 encoded node list)
  List<ProxyNode> parseGeneralSubscription(String content) {
    try {
      // Try to parse as YAML first
      final yaml = loadYaml(content);
      if (yaml != null && yaml['proxies'] != null) {
        return parseClashConfig(content);
      }
      
      // Try line-by-line SS/VMess URI format
      final lines = content.split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toList();
      
      final nodes = <ProxyNode>[];
      for (final line in lines) {
        final node = _parseUri(line);
        if (node != null) nodes.add(node);
      }
      
      return nodes;
    } catch (e) {
      return [];
    }
  }
  
  ProxyNode? _parseUri(String uri) {
    try {
      if (uri.startsWith('ss://')) {
        return _parseSSUri(uri);
      } else if (uri.startsWith('vmess://')) {
        return _parseVmessUri(uri);
      } else if (uri.startsWith('trojan://')) {
        return _parseTrojanUri(uri);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
  
  ProxyNode? _parseSSUri(String uri) {
    try {
      final withoutScheme = uri.substring(5);
      final atIndex = withoutScheme.lastIndexOf('@');
      final hashIndex = withoutScheme.indexOf('#');
      
      final userInfo = Uri.decodeFull(withoutScheme.substring(0, atIndex));
      final hostPart = withoutScheme.substring(atIndex + 1);
      final hashPart = hashIndex > 0 
          ? Uri.decodeFull(withoutScheme.substring(hashIndex + 1))
          : 'SS Node';
      
      final colonIndex = userInfo.indexOf(':');
      final cipher = userInfo.substring(0, colonIndex);
      final password = userInfo.substring(colonIndex + 1);
      
      final slashIndex = hostPart.indexOf('/');
      final hostPort = slashIndex > 0 ? hostPart.substring(0, slashIndex) : hostPart;
      final queryPart = slashIndex > 0 ? hostPart.substring(slashIndex + 1) : '';
      
      final colonHostIndex = hostPort.lastIndexOf(':');
      final server = hostPort.substring(0, colonHostIndex);
      final port = int.tryParse(hostPort.substring(colonHostIndex + 1)) ?? 0;
      
      return ProxyNode(
        name: hashPart,
        type: 'ss',
        server: server,
        port: port,
        cipher: cipher,
        password: password,
      );
    } catch (_) {
      return null;
    }
  }
  
  ProxyNode? _parseVmessUri(String uri) {
    try {
      final jsonStr = uri.substring(8);
      final decoded = utf8.decode(base64.decode(jsonStr + '=='));
      final Map<String, dynamic> json = jsonDecode(decoded);
      
      return ProxyNode(
        name: json['ps'] ?? 'VMess Node',
        type: 'vmess',
        server: json['add'] ?? json['address'] ?? '',
        port: int.tryParse((json['port'] ?? '0').toString()) ?? 0,
        uuid: json['id'],
        alterId: json['aid']?.toString(),
        network: json['net'],
        tls: json['tls'],
      );
    } catch (_) {
      return null;
    }
  }
  
  ProxyNode? _parseTrojanUri(String uri) {
    try {
      final withoutScheme = uri.substring(9);
      final atIndex = withoutScheme.indexOf('@');
      final hashIndex = withoutScheme.indexOf('#');
      final queryIndex = withoutScheme.indexOf('?');
      
      final password = withoutScheme.substring(0, atIndex);
      final hostPart = withoutScheme.substring(atIndex + 1);
      
      String name = 'Trojan Node';
      String query = '';
      
      if (hashIndex > 0) {
        name = Uri.decodeFull(hostPart.substring(0, hashIndex));
        query = hashIndex > 0 ? hostPart.substring(hashIndex + 1) : '';
      } else if (queryIndex > 0) {
        query = hostPart.substring(queryIndex + 1);
      }
      
      final hostPort = queryIndex > 0 || hashIndex > 0
          ? hostPart.substring(0, queryIndex > 0 && queryIndex < hashIndex ? queryIndex : hashIndex > 0 && hashIndex < queryIndex ? hashIndex : (queryIndex > 0 ? queryIndex : hostPart.length))
          : hostPart;
      
      final colonIndex = hostPort.lastIndexOf(':');
      final server = hostPort.substring(0, colonIndex);
      final port = int.tryParse(hostPort.substring(colonIndex + 1)) ?? 0;
      
      return ProxyNode(
        name: name,
        type: 'trojan',
        server: server,
        port: port,
        password: password,
      );
    } catch (_) {
      return null;
    }
  }
}
