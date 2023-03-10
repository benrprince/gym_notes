import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/exercise.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  _AddExerciseState createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final _formKey = GlobalKey<FormState>();
  String exerciseName = '';
  String prMetric = 'Weight';
  String category = 'Other';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: "Exercise Name"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Exercise Name';
                }
                exerciseName = value;
                return null;
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Exercise Category"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a catergory';
                }
                category = value;
                return null;
              },
              onChanged: (String? newValue) {
                setState(() {
                  category = newValue!;
                });
              },
              items: [
                'Arms',
                'Back',
                'Cardio',
                'Chest',
                'Core',
                'Legs',
                'Shoulders',
                'Other'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "PR Metric"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a metric';
                }
                prMetric = value;
                return null;
              },
              onChanged: (String? newValue) {
                setState(() {
                  prMetric = newValue!;
                });
              },
              items: [
                'Weight',
                'Reps',
                // 'Time'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Adding Exercise')),
                    );
                    Exercise exercise = Exercise(
                        name: exerciseName,
                        pr: 0,
                        category: category,
                        prMetric: prMetric);
                    GymNotesDatabase.instance.createExercise(exercise);
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent)),
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.grey.shade900),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
