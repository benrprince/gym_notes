final String tableSet = 'entrySet';

class SetFields {
  static final List<String> values = [
    setId, entryId, weight, reps
  ];

  static final String setId = '_setId';
  static final String entryId = 'entryId';
  static final String weight = 'weight';
  static final String reps = 'reps';
}

class Set {
  final int? setId;
  final int? entryId;
  final int? weight;
  final int? reps;

  const Set({
    this.setId,
    required this.entryId,
    required this.weight,
    required this.reps
  });

  static Set fromJson(Map<String, Object?> json) => Set(
    setId: json[SetFields.setId] as int?,
    entryId: json[SetFields.entryId] as int?,
    weight: json[SetFields.weight] as int?,
    reps: json[SetFields.reps] as int?
  );

  Map<String, Object?> toJson() => {
    SetFields.setId: setId,
    SetFields.entryId: entryId,
    SetFields.weight: weight,
    SetFields.reps: reps
  };

  Set copy({
    int? setId,
    int? entryId,
    int? weight,
    int? reps

  }) =>
    Set(
      setId: setId ?? this.setId,
      entryId: entryId ?? this.entryId,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps
    );
}