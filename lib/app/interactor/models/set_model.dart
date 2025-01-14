import 'package:flutter/foundation.dart';

@immutable
class SetModel {
  final int setNumber;
  final int reps;
  final double weight;

  const SetModel({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  SetModel copyWith({
    int? setNumber,
    int? reps,
    double? weight,
  }) {
    return SetModel(
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetModel &&
          runtimeType == other.runtimeType &&
          setNumber == other.setNumber &&
          reps == other.reps &&
          weight == other.weight;

  @override
  int get hashCode => setNumber.hashCode ^ reps.hashCode ^ weight.hashCode;
}