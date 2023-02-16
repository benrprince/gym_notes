import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_notes/db/gym_notes_db.dart';
import 'package:gym_notes/model/entry.dart';
import 'package:gym_notes/model/set.dart' as LiftingSet;
import 'package:stop_watch_timer/stop_watch_timer.dart';

import '../routes/routes.dart';

class AddEntry extends StatefulWidget {
  final ExerciseArguments exerciseArguments;
  final Entry entry;
  const AddEntry(
      {super.key, required this.exerciseArguments, required this.entry});

  @override
  // ignore: library_private_types_in_public_api
  _AddEntryState createState() => _AddEntryState();
}

class _AddEntryState extends State<AddEntry> {
  final GlobalKey<FormState> _setFormKey = GlobalKey<FormState>();
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();
  final bool _isHours = true;
  bool timerFlag = false;
  bool timerPressed = false;
  bool repsFlag = false;
  String hours = "00";
  String minutes = "00";
  String seconds = "00";
  String mSecs = "00";
  int maxWeight = 0;
  int maxTime = 0;
  int time = 0;
  int weight = 0;
  int reps = 0;
  int totalVolume = 0;
  late bool previous;
  late List<LiftingSet.Set> previousSets;
  bool isLoading = false;

  List<SetVariables> setList = [];

  List<StopWatchTimer> timerList = [];

  @override
  void dispose() {
    super.dispose();
    _stopWatchTimer.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.exerciseArguments.exercise.prMetric == "Time") {
      timerFlag = true;
    } else if (widget.exerciseArguments.exercise.prMetric == "Reps") {
      repsFlag = true;
    }
    refreshSets();
    setList = List<SetVariables>.empty(growable: true);
    setList.add(SetVariables(0, 0, 0));
    timerList.add(StopWatchTimer());
  }

  Future refreshSets() async {
    setState(() => isLoading = true);

    if (widget.entry.exerciseId == 0) {
      previous = false;
    } else {
      previous = true;
      List<LiftingSet.Set> initialSetList =
          await GymNotesDatabase.instance.readEntrySets(widget.entry.entryId);
      previousSets = List.from(initialSetList.reversed);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Entry'),
        ),
        // bottomNavigationBar: Visibility(
        //     visible: timerPressed, child: BottomAppBar(child: stopWatch())),
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
                      totalVolume: totalVolume);
                  GymNotesDatabase.instance
                      .createEntry(entry)
                      .then((savedEntry) {
                    setList.forEach((value) {
                      LiftingSet.Set liftingSet = LiftingSet.Set(
                          entryId: savedEntry.entryId,
                          weight: value.weight,
                          reps: value.reps,
                          time: value.time);

                      GymNotesDatabase.instance.createSet(liftingSet);
                    });

                    if (timerFlag) {
                      if (maxTime > widget.exerciseArguments.exercise.pr!) {
                        GymNotesDatabase.instance.updateExercisePR(
                            widget.exerciseArguments.exercise, maxTime);
                      }
                    } else if (repsFlag) {
                      if (totalVolume > widget.exerciseArguments.exercise.pr!) {
                        GymNotesDatabase.instance.updateExercisePR(
                            widget.exerciseArguments.exercise, totalVolume);
                      }
                    } else {
                      if (maxWeight > widget.exerciseArguments.exercise.pr!) {
                        GymNotesDatabase.instance.updateExercisePR(
                            widget.exerciseArguments.exercise, maxWeight);
                      }
                    }
                  });

                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Colors.greenAccent),
                ),
                child: Text(
                  'Submit Entry',
                  style: TextStyle(color: Colors.grey.shade900),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
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
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Previous Entry",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                isLoading
                    ? const CircularProgressIndicator()
                    : !previous
                        ? const SizedBox(
                            height: 150,
                            child: Center(child: Text("No Previous Entry")),
                          )
                        : buildSets(),
                _setContainer(),
              ],
            )));
  }

  Widget buildSets() => ListView.builder(
        reverse: true,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: previousSets.length,
        itemBuilder: ((context, index) {
          final set = previousSets[index];
          return Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                      cardText(widget.exerciseArguments.exercise.prMetric, set),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold))));
        }),
      );

  String cardText(String prMetric, LiftingSet.Set set) {
    switch (prMetric) {
      case "Weight":
        {
          return "Reps: ${set.reps} Weight: ${set.weight}";
        }
      case "Reps":
        {
          return "Reps: ${set.reps} Weight: ${set.weight}";
        }
      case "Time":
        {
          int sec = set.time! % 60;
          int min = (set.time! / 60).floor();
          int hr = (set.time! / 3600).floor();
          String hour = hr.toString().length <= 1 ? "0$hr" : "$min";
          String minute = min.toString().length <= 1 ? "0$min" : "$min";
          String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
          return "Reps: ${set.reps} Time: $hour:$minute:$second";
        }
      default:
        {
          return "";
        }
    }
  }

  Widget _setContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10),
          child: Text("Sets",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Container(
          child: ListView.separated(
              shrinkWrap: true,
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [setUI(index)],
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: setList.length),
        ),
      ],
    );
  }

  Widget setUI(index) {
    SetVariables setVariables = SetVariables(0, 0, 0);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
            width: 75,
            child: TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Reps"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Number of Reps';
                }
                reps = int.parse(value);
                if (repsFlag) {
                  totalVolume += reps;
                }
                setVariables.setReps(reps);
                return null;
              },
              onSaved: (value) {
                setList[index] = setVariables;
              },
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          timerFlag
              ? SizedBox(
                  width: 115,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: StreamBuilder<int>(
                              stream: _stopWatchTimer.rawTime,
                              initialData: _stopWatchTimer.rawTime.value,
                              builder: ((context, snapshot) {
                                final value = snapshot.data;
                                final displayTime =
                                    StopWatchTimer.getDisplayTime(value!,
                                        hours: _isHours);
                                return Text(
                                  displayTime,
                                  style: const TextStyle(fontSize: 18),
                                );
                              })))),
                  // child: Row(
                  //   children: [
                  // Expanded(
                  //     child: TextFormField(
                  //   inputFormatters: [
                  //     LengthLimitingTextInputFormatter(2),
                  //   ],
                  //   controller: TextEditingController(text: hours),
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please Enter Time in Seconds';
                  //     }
                  //     // time = int.parse(value);
                  //     // if (time > maxTime) {
                  //     //   maxTime = time;
                  //     // }
                  //     // totalVolume += time * reps;
                  //     // setVariables.setTime(time);
                  //     return null;
                  //   },
                  //   onSaved: (newValue) {},
                  // )),
                  // Text(":"),
                  // Expanded(
                  //     child: TextFormField(
                  //   inputFormatters: [
                  //     LengthLimitingTextInputFormatter(2),
                  //   ],
                  //   initialValue: minutes,
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please Enter Time in Seconds';
                  //     }
                  //     // time = int.parse(value);
                  //     // if (time > maxTime) {
                  //     //   maxTime = time;
                  //     // }
                  //     // totalVolume += time * reps;
                  //     // setVariables.setTime(time);
                  //     return null;
                  //   },
                  //   onSaved: (newValue) {},
                  // )),
                  // Text(":"),
                  // Expanded(
                  //     child: TextFormField(
                  //   inputFormatters: [
                  //     LengthLimitingTextInputFormatter(2),
                  //   ],
                  //   initialValue: seconds,
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please Enter Time in Seconds';
                  //     }
                  //     // time = int.parse(value);
                  //     // if (time > maxTime) {
                  //     //   maxTime = time;
                  //     // }
                  //     // totalVolume += time * reps;
                  //     // setVariables.setTime(time);
                  //     return null;
                  //   },
                  //   onSaved: (newValue) {},
                  // )),
                  // Text("."),
                  // Expanded(
                  //     child: TextFormField(
                  //   inputFormatters: [
                  //     LengthLimitingTextInputFormatter(2),
                  //   ],
                  //   initialValue: mSecs,
                  //   keyboardType: TextInputType.number,
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please Enter Time in Seconds';
                  //     }
                  //     // time = int.parse(value);
                  //     // if (time > maxTime) {
                  //     //   maxTime = time;
                  //     // }
                  //     // totalVolume += time * reps;
                  //     // setVariables.setTime(time);
                  //     return null;
                  //   },
                  //   onSaved: (newValue) {},
                  // )),
                  //   ],
                  // ),
                )
              // ? SizedBox(
              //     height: 50,
              //     width: 75,
              //     child: TextFormField(
              //       keyboardType: TextInputType.number,
              //       decoration: const InputDecoration(labelText: "Time"),
              //       validator: (value) {
              //         if (value == null || value.isEmpty) {
              //           return 'Please Enter Time in Seconds';
              //         }
              //         time = int.parse(value);
              //         if (time > maxTime) {
              //           maxTime = time;
              //         }
              //         totalVolume += time * reps;
              //         setVariables.setTime(time);
              //         return null;
              //       },
              //       onSaved: (value) {
              //         setList[index] = setVariables;
              //       },
              //     ),
              //   )
              : SizedBox(
                  height: 50,
                  width: 75,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Weight"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter a Weight';
                      }
                      weight = int.parse(value);
                      if (weight > maxWeight) {
                        maxWeight = weight;
                      }
                      if (!timerFlag && !repsFlag) {
                        totalVolume += weight * reps;
                      }
                      setVariables.setWeight(weight);
                      return null;
                    },
                    onSaved: (value) {
                      setList[index] = setVariables;
                    },
                  ),
                ),
          Visibility(
            visible: timerFlag,
            child: SizedBox(
              width: 50,
              height: 30,
              child: IconButton(
                icon: const Icon(
                  Icons.timer_outlined,
                  color: Colors.greenAccent,
                ),
                onPressed: () {
                  setState(() {
                    if (timerPressed) {
                      _stopWatchTimer.onResetTimer();
                      timerPressed = false;
                    } else {
                      timerPressed = true;
                    }
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: index == setList.length - 1,
            child: SizedBox(
              width: 50,
              height: 30,
              child: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.greenAccent,
                ),
                onPressed: () {
                  addSetControl();
                },
              ),
            ),
          ),
          Visibility(
            visible: index > 0,
            child: SizedBox(
              width: 50,
              height: 30,
              child: IconButton(
                icon: Icon(
                  Icons.remove_circle,
                  color: Colors.orange.shade900,
                ),
                onPressed: () {
                  removeSetControl(index);
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  void addSetControl() {
    setState(() {
      setList.add(SetVariables(0, 0, 0));
      timerList.add(StopWatchTimer());
    });
  }

  void removeSetControl(index) {
    setState(() {
      if (setList.length > 1) {
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

  Widget stopWatch() {
    return SizedBox(
        height: 250,
        width: 400,
        child: Column(
          children: [
            const SizedBox(
              height: 60,
            ),
            StreamBuilder<int>(
                stream: _stopWatchTimer.rawTime,
                initialData: _stopWatchTimer.rawTime.value,
                builder: ((context, snapshot) {
                  final value = snapshot.data;
                  final displayTime =
                      StopWatchTimer.getDisplayTime(value!, hours: _isHours);
                  return Text(
                    displayTime,
                    style: const TextStyle(fontSize: 40),
                  );
                })),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: (() {
                      _stopWatchTimer.onStartTimer();
                    }),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.greenAccent),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(
                                        color: Colors.greenAccent)))),
                    child: Text(
                      "Start",
                      style: TextStyle(color: Colors.grey.shade900),
                    )),
                const SizedBox(
                  width: 52,
                ),
                ElevatedButton(
                    onPressed: (() {
                      _stopWatchTimer.onStopTimer();
                    }),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.orange.shade900),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                        color: Colors.orange.shade900)))),
                    child: Text(
                      "Stop",
                      style: TextStyle(color: Colors.grey.shade900),
                    )),
                const SizedBox(
                  width: 50,
                ),
                ElevatedButton(
                    onPressed: (() {
                      _stopWatchTimer.onResetTimer();
                    }),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side:
                                        const BorderSide(color: Colors.grey)))),
                    child: Text(
                      "Reset",
                      style: TextStyle(color: Colors.grey.shade900),
                    ))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: (() {
                  setState(() {
                    hours = StopWatchTimer.getDisplayTimeHours(
                            _stopWatchTimer.rawTime.value)
                        .toString();
                    minutes = StopWatchTimer.getDisplayTimeMinute(
                            _stopWatchTimer.rawTime.value)
                        .toString();
                    seconds = StopWatchTimer.getDisplayTimeSecond(
                            _stopWatchTimer.rawTime.value)
                        .toString();
                    mSecs = StopWatchTimer.getDisplayTimeMillisecond(
                            _stopWatchTimer.rawTime.value)
                        .toString();
                  });
                }),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.greenAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side:
                                const BorderSide(color: Colors.greenAccent)))),
                child: Text(
                  "Record",
                  style: TextStyle(color: Colors.grey.shade900),
                ))
          ],
        ));
  }
}

class SetVariables {
  int weight;
  int reps;
  int time;

  SetVariables(this.weight, this.reps, this.time);

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

  void setTime(time) {
    this.time = time;
  }

  int getTime() {
    return time;
  }
}
