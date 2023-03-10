import 'package:flutter/material.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/entry.dart';
import 'package:gym_notes/model/set.dart' as setModel;
import 'package:gym_notes/routes/routes.dart';
import 'package:gym_notes/routes/routes.dart' as route;
import 'package:intl/intl.dart';

class Exercise extends StatefulWidget {
  final ExerciseArguments exerciseArguments;
  const Exercise({super.key, required this.exerciseArguments});

  @override
  // ignore: library_private_types_in_public_api
  _ExerciseState createState() => _ExerciseState();
}

class _ExerciseState extends State<Exercise> {
  GymNotesDatabase db = GymNotesDatabase.instance;
  late List<Entry> entries;
  late Entry mostRecentEntry;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshEntries();
  }

  Future refreshEntries() async {
    setState(() => isLoading = true);

    entries = await db
        .readExerciseEntries(widget.exerciseArguments.exercise.exerciseId);
    
    entries = entries.reversed.toList();

    if (entries.isNotEmpty) {
      mostRecentEntry = entries.first;
    } else {
      mostRecentEntry = Entry(
          date: DateTime.now(),
          exerciseId: 0,
          sets: 0,
          maxWeight: 0,
          totalVolume: 0);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
              child: Text(widget.exerciseArguments.exercise.name,
                  style: const TextStyle(fontSize: 50))),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Text(widget.exerciseArguments.exercise.category,
                style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
                prMetric(widget.exerciseArguments.exercise.prMetric,
                    widget.exerciseArguments.exercise.pr!),
                style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            onPressed: () {
              showAlertDialog(context);
            },
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.orange.shade800)),
            child: const Text('Delete'),
          ),
          const SizedBox(height: 25),
          const Center(
            child: Text('Entries', style: TextStyle(fontSize: 20)),
          ),
          isLoading
              ? const CircularProgressIndicator()
              : entries.isEmpty
                  ? const Text('No Entries')
                  : Expanded(child: buildEntries()),
          const SizedBox(
            height: 100,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed(route.addEntryPage, arguments: [
            route.ExerciseArguments(widget.exerciseArguments.exercise),
            mostRecentEntry
          ]);
          refreshEntries();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildEntries() => ListView.builder(
        // reverse: true,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: entries.length,
        itemBuilder: ((context, index) {
          final entry = entries[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(route.entryPage, arguments: [
                route.EntryArguments(entry),
                route.ExerciseArguments(widget.exerciseArguments.exercise)
              ]);
            },
            child: Card(
              child: ListTile(
                title: Text(DateFormat.yMMMd().format(entry.date).toString()),
                trailing: Text(entryCard(
                    widget.exerciseArguments.exercise.prMetric, entry)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          );
        }),
      );

  Future<void> deleteExerciseAndAllUnder(
      GymNotesDatabase db, int? exerciseId) async {
    List<Entry> entries = await db.readExerciseEntries(exerciseId);
    entries.forEach((entry) async {
      List<setModel.Set> initialSetList = await db.readEntrySets(entry.entryId);
      initialSetList.forEach((entrySet) async {
        await db.deleteSet(entrySet.setId);
      });
      await db.deleteEntry(entry.entryId);
    });
    await db.deleteExercise(exerciseId);
  }

  String prMetric(String prMetric, int pr) {
    switch (prMetric) {
      case "Weight":
        {
          return "PR: $pr lbs";
        }
      case "Reps":
        {
          return "PR: $pr reps";
        }
      case "Time":
        {
          int sec = pr % 60;
          int min = (pr / 60).floor();
          int hr = (pr / 3600).floor();
          String hour = hr.toString().length <= 1 ? "0$hr" : "$min";
          String minute = min.toString().length <= 1 ? "0$min" : "$min";
          String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
          return "PR: $hour:$minute:$second";
        }
      default:
        {
          return "";
        }
    }
  }

  String entryCard(String prMetric, Entry entry) {
    switch (prMetric) {
      case "Weight":
        {
          return "Sets: ${entry.sets} | Max: ${entry.maxWeight} | Total Vol: ${entry.totalVolume}";
        }
      case "Reps":
        {
          return "Sets: ${entry.sets} | Total Vol: ${entry.totalVolume}";
        }
      case "Time":
        {
          int sec = entry.totalVolume! % 60;
          int min = (entry.totalVolume! / 60).floor();
          int hr = (entry.totalVolume! / 3600).floor();
          String hour = hr.toString().length <= 1 ? "0$hr" : "$min";
          String minute = min.toString().length <= 1 ? "0$min" : "$min";
          String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
          return "PR: $hour:$minute:$second";
        }
      default:
        {
          return "";
        }
    }
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete"),
      onPressed: () async {
        await deleteExerciseAndAllUnder(
            db, widget.exerciseArguments.exercise.exerciseId);
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Exercise"),
      content:
          const Text("All data associated with this exercise will be deleted"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
