import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../project_resources/project_strings_file.dart';
import '../project_resources/project_utils.dart';

class SymptomSelectorScreen extends StatefulWidget {
  SymptomSelectorScreen({Key? key, required this.symptoms}) : super(key: key);
  String symptoms;

  @override
  State<SymptomSelectorScreen> createState() => _SymptomSelectorScreen();
}

class _SymptomSelectorScreen extends State<SymptomSelectorScreen> {
  Set<String> symptomsChecked = <String>{};
  List<Symptoms> positiveSymptomListSelection = Symptoms.getPositiveSymptoms();
  List<Symptoms> stressorSymptomsSelection = Symptoms.getStressorSymptomList();
  List<Symptoms> executiveDysfunctionSelection =
      Symptoms.getExecutiveDysfuntionSymptoms();
  List<Symptoms> emotionalListSelection = Symptoms.getEmotionalSymptoms();
  List<Symptoms> inattentiveSymptomListSelection =
      Symptoms.getInattentiveSymptoms();

  @override
  void initState() {
    super.initState();
    loadSymptoms();
  }

  //Load symptoms into widget for the user to select and save to record
  void loadSymptoms() {
// Add symptoms to list and remove empty elements from list
    symptomsChecked.addAll(super.widget.symptoms.split(','));
    symptomsChecked.removeWhere((item) => (item.isEmpty));
// Check to see if the symptoms in the list are in the set from the record.
    //This is going to need expansion because we have 5 lists to check now.
    for (Symptoms element in positiveSymptomListSelection) {
      if (symptomsChecked.contains(element.symptom)) {
        element.isChecked = true;
      }
    }
    for (Symptoms element in inattentiveSymptomListSelection) {
      if (symptomsChecked.contains(element.symptom)) {
        element.isChecked = true;
      }
    }
    for (Symptoms element in emotionalListSelection) {
      if (symptomsChecked.contains(element.symptom)) {
        element.isChecked = true;
      }
    }
    for (Symptoms element in executiveDysfunctionSelection) {
      if (symptomsChecked.contains(element.symptom)) {
        element.isChecked = true;
      }
    }
    for (Symptoms element in stressorSymptomsSelection) {
      if (symptomsChecked.contains(element.symptom)) {
        element.isChecked = true;
      }
    }
  }

  void addItemsToSymptomList() {
    //clear the string so it can be updated with new symptoms.
    super.widget.symptoms = '';
    String unfilteredString = '';
    if (symptomsChecked.isNotEmpty) {
      for (String element in symptomsChecked) {
        unfilteredString += element + ',';
      }
      var indexComma = unfilteredString.lastIndexOf(',');
      var filteredString =
          unfilteredString.replaceRange(indexComma, indexComma + 1, '');
      super.widget.symptoms = filteredString;
    } else {
      super.widget.symptoms = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('ADHD Symptom Selection'),
          leading: IconButton(
              onPressed: () {
                addItemsToSymptomList();
                Navigator.pop(context, super.widget.symptoms);
              },
              icon: backArrowIcon),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(8.0),
          child: CustomScrollView(slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                const ListTile(
                  title: Text(
                    "Positive Symptoms/Benefits",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return uiCard(
                    CheckboxListTile(
                        activeColor: Color(swapper.isColorSeed),
                        value: positiveSymptomListSelection[index].isChecked,
                        onChanged: (bool? changed) {
                          setState(() {
                            positiveSymptomListSelection[index].isChecked =
                                changed!;
                            if (changed == true) {
                              symptomsChecked.add(
                                  positiveSymptomListSelection[index].symptom);
                            } else {
                              symptomsChecked.remove(
                                  positiveSymptomListSelection[index].symptom);
                            }
                          });
                        },
                        title:
                            Text(positiveSymptomListSelection[index].symptom)),
                    swapper);
              }, childCount: positiveSymptomListSelection.length),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const ListTile(
                  title: Text(
                    "Attention-based symptoms based on intensity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return uiCard(
                    CheckboxListTile(
                        activeColor: Color(swapper.isColorSeed),
                        value: inattentiveSymptomListSelection[index].isChecked,
                        onChanged: (bool? changed) {
                          setState(() {
                            inattentiveSymptomListSelection[index].isChecked =
                                changed!;
                            if (changed == true) {
                              symptomsChecked.add(
                                  inattentiveSymptomListSelection[index]
                                      .symptom);
                            } else {
                              symptomsChecked.remove(
                                  inattentiveSymptomListSelection[index]
                                      .symptom);
                            }
                          });
                        },
                        title: Text(
                            inattentiveSymptomListSelection[index].symptom +
                                ' - ' +
                                inattentiveSymptomDefinitionList[index] +
                                '.')),
                    swapper);
              }, childCount: inattentiveSymptomListSelection.length),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const ListTile(
                  title: Text(
                    "Common ADHD symptoms based on intensity ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return uiCard(
                    CheckboxListTile(
                        activeColor: Color(swapper.isColorSeed),
                        value: executiveDysfunctionSelection[index].isChecked,
                        onChanged: (bool? changed) {
                          setState(() {
                            executiveDysfunctionSelection[index].isChecked =
                                changed!;
                            if (changed == true) {
                              symptomsChecked.add(
                                  executiveDysfunctionSelection[index].symptom);
                            } else {
                              symptomsChecked.remove(
                                  executiveDysfunctionSelection[index].symptom);
                            }
                          });
                        },
                        title: Text(
                            executiveDysfunctionSelection[index].symptom +
                                " - " +
                                executiveSymptomDefinitionList[index] +
                                ".")),
                    swapper);
              }, childCount: executiveDysfunctionSelection.length),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const ListTile(
                  title: Text(
                    "Emotional regulation based symptoms based on intensity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return uiCard(
                    CheckboxListTile(
                        activeColor: Color(swapper.isColorSeed),
                        value: emotionalListSelection[index].isChecked,
                        onChanged: (bool? changed) {
                          setState(() {
                            emotionalListSelection[index].isChecked = changed!;
                            if (changed == true) {
                              symptomsChecked
                                  .add(emotionalListSelection[index].symptom);
                            } else {
                              symptomsChecked.remove(
                                  emotionalListSelection[index].symptom);
                            }
                          });
                        },
                        title: Text(emotionalListSelection[index].symptom +
                            ' - ' +
                            emotionalRegDefinitionList[index] +
                            ".")),
                    swapper);
              }, childCount: emotionalListSelection.length),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const ListTile(
                  title: Text(
                    "Stress-based symptoms based on intensity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate:
                  SliverChildBuilderDelegate((BuildContext context, int index) {
                return uiCard(
                    CheckboxListTile(
                        activeColor: Color(swapper.isColorSeed),
                        value: stressorSymptomsSelection[index].isChecked,
                        onChanged: (bool? changed) {
                          setState(() {
                            stressorSymptomsSelection[index].isChecked =
                                changed!;
                            if (changed == true) {
                              symptomsChecked.add(
                                  stressorSymptomsSelection[index].symptom);
                            } else {
                              symptomsChecked.remove(
                                  stressorSymptomsSelection[index].symptom);
                            }
                          });
                        },
                        title: Text(stressorSymptomsSelection[index].symptom +
                            " - " +
                            stressDefinitionList[index])),
                    swapper);
              }, childCount: stressorSymptomsSelection.length),
            ),
          ]),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Save'),
          onPressed: () {
            addItemsToSymptomList();
            Navigator.pop(context, super.widget.symptoms);
          },
        ),
      );
    });
  }
}

class Symptoms {
  String symptom;
  bool isChecked;

  Symptoms(this.symptom, this.isChecked);

  ///This will need modified where all four lists are used instead of the original.
  static List<Symptoms> getPositiveSymptoms() {
    List<Symptoms> symptomsList = List.empty(growable: true);
    for (String element in positiveSymptomList) {
      symptomsList.add(Symptoms(element, false));
    }
    return symptomsList;
  }

  static List<Symptoms> getEmotionalSymptoms() {
    List<Symptoms> emotionSymptoms = List.empty(growable: true);
    for (String element in emotionalSymptomList) {
      emotionSymptoms.add(Symptoms(element, false));
    }
    return emotionSymptoms;
  }

  static List<Symptoms> getInattentiveSymptoms() {
    List<Symptoms> inattentiveSymptoms = List.empty(growable: true);
    for (String element in inattentiveSymptomsList) {
      inattentiveSymptoms.add(Symptoms(element, false));
    }
    return inattentiveSymptoms;
  }

  static List<Symptoms> getExecutiveDysfuntionSymptoms() {
    List<Symptoms> crazySymptoms = List.empty(growable: true);
    for (String element in executiveDysfunctionSymptomList) {
      crazySymptoms.add(Symptoms(element, false));
    }
    return crazySymptoms;
  }

  static List<Symptoms> getStressorSymptomList() {
    List<Symptoms> stressSypmtoms = List.empty(growable: true);
    for (String element in stressorSymptomList) {
      stressSypmtoms.add(Symptoms(element, false));
    }
    return stressSypmtoms;
  }

  @override
  String toString() {
    return symptom + ' $isChecked\r\n';
  }
}
