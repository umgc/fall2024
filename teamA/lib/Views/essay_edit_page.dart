import 'package:flutter/material.dart';
import 'package:editable/editable.dart';

class EssayEditPage extends StatefulWidget {
 @override
 // ignore: library_private_types_in_public_api
 _EssayEditPageState createState() => _EssayEditPageState();
}
class _EssayEditPageState extends State<EssayEditPage> {


//row data
List rows = [
   {"name": 'James Peter', "date":'01/08/2007',"month":'March',"status":'beginner'}, 
   {"name": 'Okon Etim', "date":'09/07/1889',"month":'January',"status":'completed'}, 
   {"name": 'Samuel Peter', "date":'11/11/2002',"month":'April',"status":'intermediate'}, 
   {"name": 'Udoh Ekong', "date":'06/3/2020',"month":'July',"status":'beginner'}, 
   {"name": 'Essien Ikpa', "date":'12/6/1996',"month":'June',"status":'completed'}, 
 ];
//Headers or Columns
List headers = [
   {"title":'Name', 'index': 1, 'key':'name'},
   {"title":'Date', 'index': 2, 'key':'date'},
   {"title":'Month', 'index': 3, 'key':'month'},
   {"title":'Status', 'index': 4, 'key':'status'},
 ];

@override
 Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
      title: Text("Edit Essay Rubric"),
    ),
     body: Editable(
      columnRatio: .7/headers.length,//sets width of each column as a ratio of total number of columsn
       columns: headers, 
       rows: rows,
       showCreateButton: true,
       tdStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
       showSaveIcon: true,
      //  borderColor: Colors.grey.shade300,
      borderColor: Theme.of(context).colorScheme.primaryContainer,
        onSubmitted: (value){ //new line
            print(value); //you can grab this data to store anywhere
        }
      ),
    );
 }
}
