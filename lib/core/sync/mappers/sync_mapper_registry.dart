import 'sync_entity_mapper.dart';

class SyncMapperRegistry {
  final Map<String, SyncEntityMapper> _mappers;

  SyncMapperRegistry(Iterable<SyncEntityMapper> mappers)
      : _mappers = {
          for (final mapper in mappers) mapper.entityType: mapper,
        };

  SyncEntityMapper? mapperFor(String entityType) => _mappers[entityType];
}
