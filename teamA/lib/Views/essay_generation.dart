import 'package:flutter/material.dart';
import 'dart:convert';
import '../Api/llm_api';

// Required Components:
// 2 Dropdowns: 1 for the Grade Level and 1 for the Point Scale
// 3 Text Boxes: Standard/Objective, Assignment Description, Additional Customization for Rubric (Optional)
// Audio icon for each textbox for readback?
// Paper clip for each textbox for attachments?
// 2 Buttons: 1 Generate Essay Button, 1 Send to Moodle Button
// 1 Frame to show the rubric that was generated?

class EssayGeneration extends StatefulWidget 
{
  const EssayGeneration({super.key, required this.title});
  final String title;

  @override
  State<EssayGeneration> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<EssayGeneration> 
{
    //Holds values for user input fields
  int _selectedPointScale = 3; // Default value
  String _selectedGradeLevel =
      'Advanced'; // Default value for GradeLevelDropdown
  // Variables to store the text inputs
  final TextEditingController _standardObjectiveController =
      TextEditingController();
  final TextEditingController _assignmentDescriptionController =
      TextEditingController();
  final TextEditingController _additionalCustomizationController =
      TextEditingController();
  dynamic globalRubric;
  // Function to store the selected value
  void _handlePointScaleChanged(int? newValue) {
    setState(() {
      if (newValue != null) {
        _selectedPointScale = newValue;
      }
    });
  }
  // Function to store the selected grade level value
  void _handleGradeLevelChanged(String? newValue) {
    setState(() {
      if (newValue != null) {
        _selectedGradeLevel = newValue;
      }
    });
  }
  Future<dynamic> apiTest(String inputs) async {
    String apiKey = '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';
    LlmApi myLLM = LlmApi(apiKey);
    String queryPrompt = '''
      I am building a program that creates rubrics when provided with assignment information. I will provide you with the following information about the assignment that needs a rubric:
      Difficulty level, point scale, assignment objective, assignment description. You may also receive additional customization rules.
      Using this information, you will reply with a rubric that includes 3-5 criteria. Your reply must only contain the JSON information, and begin with a {.
      Remove any ``` from your output.

      You must reply with a representation of the rubric in JSON format that matches this format: 
      {
          "criteria": [
              {
                  "description": #CriteriaName,
                  "levels": [
                      { "definition": #CriteriaDef, "score": #ScoreValue },
                  ]
              }
        ]
      }
      #CriteriaName must be replaced with the name of the criteria.
      #CriteriaDef must be replaced with a detailed description of what meeting that criteria would look like for each scale value.
      #ScoreValue must be replaced with a number representing the score. The score for the lowest scale value will be 0, and the scores will increase by 1 for each scale.
      You should create as many "levels" objects as there are point scale values.
      Here is the assignment information:
      $inputs
    ''';
    String rubric = await myLLM.postToLlm(queryPrompt);
    return jsonDecode(rubric);
    //globalRubric = jsonDecode(rubric);
    //genRubricFromAI(rubric);
  }
/*
  dynamic genRubricFromAI(String inputs) {
    apiTest(inputs).then((String results) {
      print('tets');
    });
    Object result = jsonDecode(waitRubric);
    //final result1 = (json.decode(waitRubric) as List).cast<Map<String, dynamic>>();
    print('result');
    return result;
    //WARNING
  }
*/
// Method to return a summary of the selected dropdown and text box values
  String getSelectedResponses() {
    return '''
      Selected Difficulty Level: $_selectedGradeLevel
      Selected Point Scale: $_selectedPointScale
      Standard / Objective: ${_standardObjectiveController.text}
      Assignment Description: ${_assignmentDescriptionController.text}
      Additional Customization: ${_additionalCustomizationController.text}
    ''';
  }
  @override
  void dispose() {
    // Dispose the controllers when the widget is removed from the widget tree
    _standardObjectiveController.dispose();
    _assignmentDescriptionController.dispose();
    _additionalCustomizationController.dispose();
    super.dispose();
  }
  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row( // Using Row to split screen into two sections
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Left Column
            Expanded(
              flex: 2, // This controls the space for the left side, bigger ratio
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  const Text("Rubric Generator", style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 16),

                  // Grade Level Dropdown
                  GradeLevelDropdown(
                    selectedGradeLevel: '12th grade',  // Default value
                    onChanged: (newValue) 
                    {
                      setState(() 
                      {
                        this.selectedGradeLevel = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Point Scale Dropdown
                  PointScaleDropdown(
                    selectedPointScale: 3,  // Default value
                    onChanged: (newValue) {
                      setState(() {
                        selectedPointScale = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Standard/Objective TextBox
                  TextBox(
                    label: "Standard / Objective",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      // If the user puts in text
                    },
                  ),
                  const SizedBox(height: 16),

                  // Assignment Description TextBox
                  TextBox(
                    label: "Assignment Description",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      // If the user puts in text
                    },
                  ),
                  const SizedBox(height: 16),

                  // Additional Customization TextBox
                  TextBox(
                    label: "Additional Customization for Rubric (Optional)",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      // Will also be handled as query to API
                    },
                  ),

                  const SizedBox(height: 16),
                  
                  // Generate Button
                  Button('essay')
                ],
              ),
            ),

            const SizedBox(width: 32), // Adds space between the two columns

            // Right Side
            Expanded(
              flex: 3, // side has more room for rubric display
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  // Placeholder for rubric to be generated by button
                  Container(
                    height: 365,
                    color: Colors.grey[200], // Just to show where the rubric will go
                    child: Center(
                      child: Text("Generated Rubric", 
                        style: TextStyle(fontSize: 18, color: Colors.black54)),
                    ),
                  ),


                  const SizedBox(height: 16),


                  // Send to Moodle Button
                  Button("assessment")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Create Class for Buttons
class Button extends StatelessWidget
{
  // Fields in this widget subclass are marked final
  final String type;
  final String text;
  final String filters = "";
  Button._(this.type, this.text);

  factory Button(String type)
  {
    if (type == "assessment")
    {
      return Button._(type,"Send to Moodle");
    }
    else if (type == "essay")
    {
      return Button._(type,"Generate Essay");
    }
    else
    {
      return Button._(type,"");
    }
  }

  @override 
  Widget build(BuildContext context)
  {
    return OutlinedButton(
      onPressed: () {}, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.create), 
          Text(text)],
      )
    );
  }
  
}

class TextBox extends StatelessWidget {
  // Each text box will have icons for attachments and playback, and event handlers
  final String label;
  final IconData icon;
  final IconData secondaryIcon;
  final String initialValue;
  // We need to store the value of the string the user inputs
  final ValueChanged<String?> onChanged;

  // Constructor for textbok requires user input
  const TextBox({
    Key? key,
    required this.label,
    required this.icon,
    required this.secondaryIcon,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  void _handleTextChanged(String? newValue) 
  {
    // Additional Logic
    onChanged(newValue); // Call the passed onChanged function
  }

  @override
  Widget build(BuildContext context) 
  {
    return TextField(
      controller: TextEditingController(text: initialValue),  // To handle the initial value
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Icon(icon),          // Primary icon
            SizedBox(height: 4), // Space between the icons
            Icon(secondaryIcon), // Secondary icon
          ],
        ),
      ),
      onChanged: _handleTextChanged,
    );
  }
}

class PointScaleDropdown extends StatelessWidget 
{
  final int selectedPointScale;
  // We need to store the value of the int the user inputs
  final ValueChanged<int?> onChanged;

  const PointScaleDropdown({
    Key? key,
    required this.selectedPointScale,
    required this.onChanged,
  }) : super(key: key);

  void _handleValueChanged(int? newValue) 
  {
    // Additional Logic
    onChanged(newValue); // Call the passed onChanged function
  }

  @override
  Widget build(BuildContext context) 
  {
    return DropdownButtonFormField<int>(
      decoration: const InputDecoration(labelText: "Point Scale"),
      value: selectedPointScale,
      items: [1, 2, 3, 4, 5].map((int value) 
      {
        return DropdownMenuItem<int>(
          value: value,
          child: Text(value.toString()),
        );
      }).toList(),
      onChanged: _handleValueChanged,
    );
  }
}

class GradeLevelDropdown extends StatelessWidget 
{
  final String selectedGradeLevel;
  // We need to store the value of the string the user inputs
  final ValueChanged<String?> onChanged;

  const GradeLevelDropdown({
    Key? key,
    required this.selectedGradeLevel,
    required this.onChanged,
  }) : super(key: key);

  void _handleTextChanged(String? newValue) 
  {
    // Additional Logic
    onChanged(newValue); // Call the passed onChanged function
  }

  @override
  Widget build(BuildContext context) 
  {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: "Grade Level"),
      value: selectedGradeLevel,
      items: <String>['9th grade', '10th grade', '11th grade', '12th grade']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: _handleTextChanged,
    );
  }
}

