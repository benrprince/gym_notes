final String tableEntry = 'entry';

class EntryFields {
  static final List<String> values = [
    entryId,
    exerciseId,
    date,
    sets,
    maxWeight,
    totalVolume
  ];

  static const String entryId = '_entryId';
  static const String exerciseId = 'exerciseId';
  static const String date = 'date';
  static const String sets = 'sets';
  static const String maxWeight = 'maxWeight';
  static const String totalVolume = 'totalVolume';
}

class Entry {
  final int? entryId;
  final int? exerciseId;
  final DateTime date;
  final int? sets;
  final int? maxWeight;
  final int? totalVolume;

  const Entry(
      {this.entryId,
      required this.exerciseId,
      required this.date,
      required this.sets,
      required this.maxWeight,
      required this.totalVolume});

  static Entry fromJson(Map<String, Object?> json) => Entry(
      entryId: json[EntryFields.entryId] as int?,
      exerciseId: json[EntryFields.exerciseId] as int?,
      date: DateTime.parse(json[EntryFields.date] as String),
      sets: json[EntryFields.sets] as int?,
      maxWeight: json[EntryFields.maxWeight] as int?,
      totalVolume: json[EntryFields.totalVolume] as int?);

  Map<String, Object?> toJson() => {
        EntryFields.entryId: entryId,
        EntryFields.exerciseId: exerciseId,
        EntryFields.date: date.toIso8601String(),
        EntryFields.sets: sets,
        EntryFields.maxWeight: maxWeight,
        EntryFields.totalVolume: totalVolume
      };

  Entry copy(
          {int? entryId,
          int? exerciseId,
          DateTime? date,
          int? sets,
          int? maxWeight,
          int? totalVolume}) =>
      Entry(
          entryId: entryId ?? this.entryId,
          exerciseId: exerciseId ?? this.exerciseId,
          date: date ?? this.date,
          sets: sets ?? this.sets,
          maxWeight: maxWeight ?? this.maxWeight,
          totalVolume: totalVolume ?? this.totalVolume);
}
