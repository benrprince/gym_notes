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

  @override
  void initState() {
    super.initState();

    refreshExercises();
  }

  Future refreshExercises() async {
    setState(() => isLoading = true);

    exercises = await GymNotesDatabase.instance.readAllExercises();
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
              onTap: () => refreshExercises(),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : exercises.isEmpty
                ? const Text('No Exercises')
                : buildExercises(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, route.addExercisePage);
          refreshExercises();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildExercises() => ListView.builder(
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
