import 'plan_tier.dart';

class EntitlementState {
  final PlanTier plan;
  final bool cloudEnabled;
  final DateTime? validUntil;
  final DateTime updatedAt;

  const EntitlementState({
    required this.plan,
    required this.cloudEnabled,
    required this.validUntil,
    required this.updatedAt,
  });

  factory EntitlementState.freeLocalOnly({DateTime? now}) {
    final stamp = now ?? DateTime.now();
    return EntitlementState(
      plan: PlanTier.free,
      cloudEnabled: false,
      validUntil: null,
      updatedAt: stamp,
    );
  }

  bool get isPlus => plan == PlanTier.plus;

  bool get canUseCloud {
    if (!cloudEnabled) return false;
    if (validUntil == null) return true;
    return validUntil!.isAfter(DateTime.now());
  }

  EntitlementState copyWith({
    PlanTier? plan,
    bool? cloudEnabled,
    DateTime? validUntil,
    DateTime? updatedAt,
  }) {
    return EntitlementState(
      plan: plan ?? this.plan,
      cloudEnabled: cloudEnabled ?? this.cloudEnabled,
      validUntil: validUntil ?? this.validUntil,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
