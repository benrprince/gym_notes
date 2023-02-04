import 'package:flutter/material.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/exercise.dart';
import 'package:gym_notes/routes/routes.dart' as route;

class Home extends StatefulWidget {
  const Home({super.key});

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late List<Exercise> exercises;
  bool isLoading = false;
  String? filterValue = "All";

  @override
  void initState() {
    super.initState();

    refreshExercises(filterValue);
  }

  Future refreshExercises(String? filterValue) async {
    setState(() => isLoading = true);

    exercises = await GymNotesDatabase.instance.readExercises(filterValue!);
    exercises
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => {},
              child: const Icon(Icons.calendar_month_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => refreshExercises(filterValue),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Column(children: [
        DropdownButton(
          value: filterValue,
          items: const [
            DropdownMenuItem<String>(
              value: "All",
              child: Text("All"),
            ),
            DropdownMenuItem<String>(
              value: "Arms",
              child: Text("Arms"),
            ),
            DropdownMenuItem<String>(
              value: "Back",
              child: Text("Back"),
            ),
            DropdownMenuItem<String>(
              value: "Cardio",
              child: Text("Cardio"),
            ),
            DropdownMenuItem<String>(
              value: "Chest",
              child: Text("Chest"),
            ),
            DropdownMenuItem<String>(
              value: "Core",
              child: Text("Core"),
            ),
            DropdownMenuItem<String>(
              value: "Legs",
              child: Text("Legs"),
            ),
            DropdownMenuItem<String>(
              value: "Shoulders",
              child: Text("Shoulders"),
            ),
            DropdownMenuItem<String>(
              value: "Other",
              child: Text("Other"),
            )
          ],
          onChanged: (value) {
            filterValue = value;
            refreshExercises(filterValue);
          },
        ),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : exercises.isEmpty
                ? const Center(child: Text('No Exercises'))
                : Expanded(child: buildExercises()),
        const SizedBox(
          height: 50,
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, route.addExercisePage);
          refreshExercises(filterValue);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildExercises() => ListView.builder(
        shrinkWrap: true,
        itemCount: exercises.length,
        itemBuilder: ((context, index) {
          final exercise = exercises[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(route.exercisePage,
                  arguments: [route.ExerciseArguments(exercise)]);
            },
            child: Card(
              child: ListTile(
                title: Text(exercise.name),
                trailing: Text(
                  "PR: ${exercise.pr}",
                  style: const TextStyle(fontSize: 20),
                ),
                subtitle: Text(
                  exercise.category,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          );
        }),
      );
}
