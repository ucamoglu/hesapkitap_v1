class SyncResult {
  final int pushed;
  final int pulled;
  final int conflicts;

  const SyncResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
  });

  static const empty = SyncResult(
    pushed: 0,
    pulled: 0,
    conflicts: 0,
  );
}
