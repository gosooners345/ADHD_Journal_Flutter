import 'package:flutter/material.dart';

import 'project_strings_file.dart';



class SymptomSelectorScreen extends StatefulWidget{
  SymptomSelectorScreen({Key? key, required this.symptoms}) : super(key: key);
String symptoms;

@override
  State<SymptomSelectorScreen> createState() => _SymptomSelectorScreen();
}

class _SymptomSelectorScreen extends State<SymptomSelectorScreen>{
Set<String> symptomsChecked = <String>{};
List<Symptoms> symptomListSelection = Symptoms.getSymptoms();
@override
  void initState() {
    super.initState();
loadSymptoms();
  }

  //Load symptoms into widget for the user to select and save to record
 void loadSymptoms(){
// Add symptoms to list and remove empty elements from list
  symptomsChecked.addAll(super.widget.symptoms.split(','));
  symptomsChecked.removeWhere((item) => (item.isEmpty));
// Check to see if the symptoms in the list are in the set from the record.
  for(Symptoms element in symptomListSelection){
    if(symptomsChecked.contains(element.symptom)){
    element.isChecked = true;
    }
  }
 }


  void addItemsToSymptomList(){
  //clear the string so it can be updated with new symptoms.
  super.widget.symptoms = '';
  String unfilteredString ='';
 for(String element in symptomsChecked)
    {
      unfilteredString+=element + ',';
    }
 var indexComma = unfilteredString.lastIndexOf(',');
var filteredString = unfilteredString.replaceRange(indexComma, indexComma+1, '');
super.widget.symptoms = filteredString;
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('ADHD Symptom Selection'),),
    body:
    ListView.separated(
itemCount: symptomList.length,
    separatorBuilder: (BuildContext context, int index) => Divider(),
  itemBuilder: (BuildContext context, int index)=> CheckboxListTile(
      value: symptomListSelection[index].isChecked,
      onChanged: (bool? changed){
setState(() {
  symptomListSelection[index].isChecked = changed!;
  if(changed == true){
    symptomsChecked.add(symptomListSelection[index].symptom);
  }
  else{
    symptomsChecked.remove(symptomListSelection[index].symptom);
  }
});
},
      title: Text(symptomListSelection[index].symptom)),


  ) ,

    floatingActionButton: FloatingActionButton.extended(label: const Text('Save'),
      onPressed: (){
        addItemsToSymptomList();
        Navigator.pop(context,super.widget.symptoms);
      },
    ),
  );
  }





}

class Symptoms {
  String symptom ;
  bool isChecked ;

  Symptoms(this.symptom,this.isChecked);
  static List<Symptoms> getSymptoms(){
   List<Symptoms> symptomsList = List.empty(growable: true);
    for (String element in symptomList){
      symptomsList.add(Symptoms(element, false));
    }
    return symptomsList;
  }
  @override
  String toString() {
return symptom + ' $isChecked\r\n';
  }
}