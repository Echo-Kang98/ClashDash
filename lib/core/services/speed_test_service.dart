import 'dart:io';
import '../../../core/constants/app_constants.dart';
import '../../../features/node/data/models/node_model.dart';

class SpeedTestService {
  /// Test latency for a single node
  Future<int?> testLatency(NodeModel node) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final socket = await Socket.connect(
        node.address,
        node.port,
        timeout: const Duration(milliseconds: AppConstants.speedTestTimeout),
      );
      
      stopwatch.stop();
      await socket.close();
      
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return null;
    }
  }
  
  /// Test all nodes and return sorted by latency
  Future<Map<String, int?>> testAllNodes(List<NodeModel> nodes) async {
    final results = <String, int?>{};
    
    for (final node in nodes) {
      results[node.id] = await testLatency(node);
    }
    
    return results;
  }
  
  /// Find fastest node
  Future<NodeModel?> findFastestNode(List<NodeModel> nodes) async {
    NodeModel? fastest;
    int? fastestLatency;
    
    for (final node in nodes) {
      final latency = await testLatency(node);
      if (latency != null && (fastestLatency == null || latency < fastestLatency)) {
        fastest = node;
        fastestLatency = latency;
      }
    }
    
    return fastest;
  }
}
