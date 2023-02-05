final String tableExercise = 'exercise';

class ExerciseFields {
  static final List<String> values = [exerciseId, name, pr, category, prMetric];

  static const String exerciseId = '_exerciseId';
  static const String name = 'name';
  static const String pr = 'pr';
  static const String category = 'category';
  static const String prMetric = 'prMetric';
}

class Exercise {
  final int? exerciseId;
  final String name;
  final int? pr;
  final String category;
  final String prMetric;

  const Exercise(
      {this.exerciseId,
      required this.name,
      required this.pr,
      required this.category,
      required this.prMetric});

  static Exercise fromJson(Map<String, Object?> json) => Exercise(
      exerciseId: json[ExerciseFields.exerciseId] as int?,
      name: json[ExerciseFields.name] as String,
      pr: json[ExerciseFields.pr] as int,
      category: json[ExerciseFields.category] as String,
      prMetric: json[ExerciseFields.prMetric] as String);

  Map<String, Object?> toJson() => {
        ExerciseFields.exerciseId: exerciseId,
        ExerciseFields.name: name,
        ExerciseFields.pr: pr,
        ExerciseFields.category: category,
        ExerciseFields.prMetric: prMetric
      };

  Exercise copy(
          {int? exerciseId,
          String? name,
          int? pr,
          String? category,
          String? prMetric}) =>
      Exercise(
          exerciseId: exerciseId ?? this.exerciseId,
          name: name ?? this.name,
          pr: pr ?? this.pr,
          category: category ?? this.category,
          prMetric: prMetric ?? this.prMetric);
}
