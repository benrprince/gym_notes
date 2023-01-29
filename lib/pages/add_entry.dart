import 'package:flutter/material.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/entry.dart';
import 'package:gym_notes/model/set.dart' as LiftingSet;

import '../routes/routes.dart';

class AddEntry extends StatefulWidget {
  final ExerciseArguments exerciseArguments;
  const AddEntry({super.key, required this.exerciseArguments});

  @override
  // ignore: library_private_types_in_public_api
  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final GlobalKey<FormState> _setFormKey = GlobalKey<FormState>();
  int maxWeight = 0;
  int weight = 0;
  int reps = 0;
  int totalVolume = 0;

  List<SetVariables> setList = [];

  @override
  void initState() {
    super.initState();
    setList = List<SetVariables>.empty(growable: true);
    setList.add(SetVariables(0, 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _setFormWidget(),
            ElevatedButton(
              onPressed: () {
                  validateAndSave();
                  Entry entry = Entry(
                    exerciseId: widget.exerciseArguments.exercise.exerciseId,
                    date: DateTime.now(),
                    sets: setList.length,
                    maxWeight: maxWeight,
                    totalVolume: totalVolume
                  );
                  GymNotesDatabase.instance.createEntry(entry).then((savedEntry){
                    setList.forEach((value) {
                      LiftingSet.Set liftingSet = LiftingSet.Set(
                        entryId: savedEntry.entryId,
                        weight: value.weight,
                        reps: value.reps
                      );

                      GymNotesDatabase.instance.createSet(liftingSet);
                    });

                    if(maxWeight > widget.exerciseArguments.exercise.pr!) {
                      GymNotesDatabase.instance.updateExercisePR(
                        widget.exerciseArguments.exercise, maxWeight);
                    }
                  });

                  Navigator.pop(context);
                },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.greenAccent),
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.grey.shade900),
              ),
            ),
          ],
        ),
      )
    );
  }

  Widget _setFormWidget() {
    return Form(
      key: _setFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _setContainer()
          ],
        )
      )
    );
  }

  Widget _setContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Sets",
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold
            )
          ),
        ),
        Container(
          child: ListView.separated(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                setUI(index)
              ],
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: setList.length
        ),
        )
      ],
    );
  }

  Widget setUI(index) {
    SetVariables setVariables = SetVariables(0, 0);
    return Padding(
      padding: const EdgeInsets.all(10),
      child:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reps"),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return 'Please Enter Number of Reps';
                }
                reps = int.parse(value);
                setVariables.setReps(reps);
                return null;
              },
              onSaved:(value) {
                setList[index] = setVariables;
              },
            ),
          ),
          const SizedBox(width: 30,),
          Container(
            height: 100,
            width: 100,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight"),
              validator: (value) {
                if(value == null || value.isEmpty) {
                  return 'Please Enter a Weight';
                }
                weight = int.parse(value);
                if(weight > maxWeight) {
                  maxWeight = weight;
                }
                totalVolume += weight * reps;
                setVariables.setWeight(weight);
                return null;
              },
              onSaved:(value) {
                setList[index] = setVariables;
              },
            ),
          ),
        Visibility(
            visible: index == setList.length - 1,
            child: SizedBox(
              width: 50, height: 75,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.greenAccent,
                ),
                onPressed: () {
                  addEmailControl();
                },
              ),
            ),
          ),
          Visibility(
            visible: index > 0,
            child: SizedBox(
              width: 50, height: 75,
              child: IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.orange.shade900,
                ),
                onPressed: () {
                  removeEmailControl(index);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void addEmailControl() {
    setState(() {
      setList.add(SetVariables(0, 0));
    });
  }

  void removeEmailControl(index) {
    setState(() {
      if(setList.length > 1) {
        setList.removeAt(index);
      }
    });
  }

  bool validateAndSave() {
    final form = _setFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }
}

class SetVariables {
  int weight;
  int reps;

  SetVariables(this.weight, this.reps);

  void setWeight(weight) {
    this.weight = weight;
  }

  int getWeight() {
    return weight;
  }

  void setReps(reps) {
    this.reps = reps;
  }

  int getReps() {
    return reps;
  }
}