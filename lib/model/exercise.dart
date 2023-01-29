final String tableExercise = 'exercise';

class ExerciseFields {
  static final List<String> values = [
    exerciseId, name, pr, category
  ];

  static final String exerciseId = '_exerciseId';
  static final String name = 'name';
  static final String pr = 'pr';
  static final String category = 'category';
}

class Exercise {
  final int? exerciseId;
  final String name;
  final int? pr;
  final String category;

  const Exercise({
    this.exerciseId,
    required this.name,
    required this.pr,
    required this.category
  });

  static Exercise fromJson(Map<String, Object?> json) => Exercise(
    exerciseId: json[ExerciseFields.exerciseId] as int?,
    name: json[ExerciseFields.name] as String,
    pr: json[ExerciseFields.pr] as int,
    category: json[ExerciseFields.category] as String,
  );

  Map<String, Object?> toJson() => {
    ExerciseFields.exerciseId: exerciseId,
    ExerciseFields.name: name,
    ExerciseFields.pr: pr,
    ExerciseFields.category: category
  };

  Exercise copy({
    int? exerciseId,
    String? name,
    int? pr,
    String? category
  }) =>
      Exercise(
        exerciseId: exerciseId ?? this.exerciseId,
        name: name ?? this.name,
        pr: pr ?? this.pr,
        category: category ?? this.category
      );
}