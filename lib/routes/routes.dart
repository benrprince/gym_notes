import 'package:flutter/material.dart';
import 'package:gym_notes/model/exercise.dart';
import 'package:gym_notes/pages/add_entry.dart';
import 'package:gym_notes/pages/entry_page.dart';
import 'package:gym_notes/pages/home.dart';
import 'package:gym_notes/pages/add_exercise.dart';
import 'package:gym_notes/pages/exercise.dart' as ExPage;

import '../model/entry.dart';

// Routes
const String homePage = 'home';
const String addExercisePage = 'addExercise';
const String exercisePage = 'exercise';
const String addEntryPage = 'addEntry';
const String entryPage = 'entry';

// Route Controller
Route<dynamic> controller(RouteSettings settings) {
  switch(settings.name) {
    case homePage:
      return MaterialPageRoute(builder: (context) => const Home());
    case addExercisePage:
      return MaterialPageRoute(builder: (context) => const AddExercise());
    case addEntryPage:
      return MaterialPageRoute(builder: (BuildContext context) {
        List<dynamic> args = settings.arguments as List<dynamic>;
        return AddEntry(exerciseArguments:args[0]);
      });
    case entryPage:
      return MaterialPageRoute(builder: (BuildContext context) {
        List<dynamic> args = settings.arguments as List<dynamic>;
        return EntryPage(entryArguments:args[0]);
      });
    case exercisePage:
      return MaterialPageRoute(builder: (BuildContext context) {
        List<dynamic> args = settings.arguments as List<dynamic>;
        return ExPage.Exercise(exerciseArguments:args[0]);
      });
    default:
      throw('Error: This route does not exist');
  }
}

class ExerciseArguments {
  late final Exercise exercise;

  ExerciseArguments(this.exercise);
}

class EntryArguments {
  late final Entry entry;

  EntryArguments(this.entry);
}