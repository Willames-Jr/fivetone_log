import '../../interactor/models/set_model.dart';

class SetAdapter {
  // Convert a Map to SetModel
  static SetModel fromMap(Map<String, dynamic> map) {
    return SetModel(
      setNumber: map['setNumber'] as int,
      reps: map['reps'] as int,
      weight: map['weight'] as double,
    );
  }

  // Convert SetModel to a Map
  static Map<String, dynamic> toMap(SetModel set) {
    return {
      'setNumber': set.setNumber,
      'reps': set.reps,
      'weight': set.weight,
    };
  }
}
