import 'dart:math';

/// Calculates the 1RM (One-Rep Max) using the Epley formula.
/// 
/// [weight] is the weight lifted.
/// [reps] is the number of repetitions performed.
/// Returns the calculated 1RM.
double calculate1RM(double weight, int reps) {
  if (reps == 0) return 0.0;
  
  return (weight * reps * 0.0333 + weight).ceilToDouble();
}