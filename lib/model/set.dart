final String tableSet = 'entrySet';

class SetFields {
  static final List<String> values = [setId, entryId, weight, reps, time];

  static const String setId = '_setId';
  static const String entryId = 'entryId';
  static const String weight = 'weight';
  static const String reps = 'reps';
  static const String time = 'time';
}

class Set {
  final int? setId;
  final int? entryId;
  final int? weight;
  final int? reps;
  final int? time;

  const Set(
      {this.setId,
      required this.entryId,
      required this.weight,
      required this.reps,
      required this.time});

  static Set fromJson(Map<String, Object?> json) => Set(
      setId: json[SetFields.setId] as int?,
      entryId: json[SetFields.entryId] as int?,
      weight: json[SetFields.weight] as int?,
      reps: json[SetFields.reps] as int?,
      time: json[SetFields.time] as int?);

  Map<String, Object?> toJson() => {
        SetFields.setId: setId,
        SetFields.entryId: entryId,
        SetFields.weight: weight,
        SetFields.reps: reps,
        SetFields.time: time
      };

  Set copy({int? setId, int? entryId, int? weight, int? reps, int? time}) =>
      Set(
          setId: setId ?? this.setId,
          entryId: entryId ?? this.entryId,
          weight: weight ?? this.weight,
          reps: reps ?? this.reps,
          time: time ?? this.time);
}
