import 'package:flutter/material.dart';
import 'package:gym_notes/model/entry.dart';
import 'package:gym_notes/model/set.dart' as setModel;
import 'package:flutter/services.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/exercise.dart';
import 'package:gym_notes/routes/routes.dart' as route;
import 'package:intl/intl.dart';

class EntryPage extends StatefulWidget {
  final route.EntryArguments entryArguments;
  const EntryPage({required this.entryArguments});

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  GymNotesDatabase db = GymNotesDatabase.instance;
  late List<setModel.Set> sets;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshSets();
  }

  Future refreshSets() async {
    setState(() => isLoading = true);

    List<setModel.Set> initialSetList = await GymNotesDatabase.instance.readEntrySets(widget.entryArguments.entry.entryId);
    sets = List.from(initialSetList.reversed);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMMMd().format(
          widget.entryArguments.entry.date
        ).toString()),
      ),
      body: Column(
        children: [
          const Text(
            "Sets",
            style: TextStyle(fontSize: 50),
          ),
          Flexible(
            child: isLoading
            ? const CircularProgressIndicator()
            : sets.isEmpty
                ? const Text('No Sets')
                : buildSets(),
          ),
          const SizedBox(
            height: 50,
          ),
          ElevatedButton(
            onPressed: () async {
              await deleteEntryAndAllUnder(db, widget.entryArguments.entry.entryId);
              Navigator.pop(context);
            },
            child: const Text('Delete Entry'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.orange.shade800)
            ),
          ),
        ],
      )
    );
  }

    Widget buildSets() => ListView.builder(
    reverse: true,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
    itemCount: sets.length,
    itemBuilder: ((context, index) {
      final set = sets[index];
      return GestureDetector(
        onTap: () {
        },
        child: Card(
          child: ListTile(
            title: Text("Reps: ${set.reps} Weight: ${set.weight}"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }),
  );

  Future<void> deleteEntryAndAllUnder(GymNotesDatabase db, int? entryId) async {
    List<setModel.Set> initialSetList = await db.readEntrySets(entryId);
    initialSetList.forEach((entrySet) async {
      await db.deleteSet(entrySet.setId);
    });
    await db.deleteEntry(entryId);
  }
}