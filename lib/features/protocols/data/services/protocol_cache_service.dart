import 'dart:collection';

import 'package:zenmind/features/protocols/domain/entities/protocol.dart';

class ProtocolCacheService {
  final int capacity;

  final LinkedHashMap<String, Protocol> _cache =
      LinkedHashMap<String, Protocol>();

  ProtocolCacheService({this.capacity = 5});

  void save(Protocol protocol) {
    _cache.remove(protocol.id);

    _cache[protocol.id] = protocol;

    if (_cache.length > capacity) {
      final leastRecentlyUsed = _cache.keys.first;
      _cache.remove(leastRecentlyUsed);
    }
  }

  Protocol? getById(String id) {
    final protocol = _cache.remove(id);

    if (protocol == null) {
      return null;
    }

    _cache[id] = protocol;

    return protocol;
  }
}
