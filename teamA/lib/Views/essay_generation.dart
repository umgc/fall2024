import 'package:flutter/material.dart';
import 'dart:convert';
import '../Api/llm_api.dart';

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
  String _selectedGradeLevel = '12th grade'; // Default value for GradeLevelDropdown
  bool _isLoading = false;

  // Variables to store the text inputs
  final TextEditingController _standardObjectiveController = TextEditingController();
  final TextEditingController _assignmentDescriptionController = TextEditingController();
  final TextEditingController _additionalCustomizationController = TextEditingController();

  dynamic globalRubric;

  void _handlePointScaleChanged(int? newValue) 
  {
    setState(() {
      if (newValue != null) {
        _selectedPointScale = newValue;
      }
    });
  }

  // Function to store the selected grade level value
  void _handleGradeLevelChanged(String? newValue) 
  {
    setState(() {
      if (newValue != null) {
        _selectedGradeLevel = newValue;
      }
    });
  }

  Future<dynamic> apiTest(String inputs) async {
    try
    {
      setState(() 
      {
        _isLoading = true; // Set loading state to true
      });
      LlmApi myLLM = LlmApi(String.fromEnvironment('perplexity_apikey'));
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
      globalRubric = await myLLM.postToLlm(queryPrompt);
      globalRubric = globalRubric.replaceAll('```', '').trim();
      return jsonDecode(globalRubric);
    }
    catch (e) 
    {
      print("Error in API request: $e");
      return null;
    }
    finally 
    {
      setState(() 
      {
        _isLoading = false; // Reset loading state to false
      });
    }
  }
  
  String getSelectedResponses() {
    return '''
      Selected Grade Level: $_selectedGradeLevel
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
                    selectedGradeLevel: _selectedGradeLevel,
                    onChanged: _handleGradeLevelChanged,
                  ),

                  const SizedBox(height: 16),

                  // Point Scale Dropdown
                  PointScaleDropdown(
                    selectedPointScale: _selectedPointScale,
                    onChanged: _handlePointScaleChanged,
                  ),

                  const SizedBox(height: 16),

                  // Standard/objective
                  TextBox(
                    label: "Standard / Objective",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      _standardObjectiveController.text = newValue!;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Assignment description
                  TextBox(
                    label: "Assignment Description",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      _assignmentDescriptionController.text = newValue!;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Additional customization
                  TextBox(
                    label: "Additional Customization for Rubric (Optional)",
                    icon: Icons.mic,
                    secondaryIcon: Icons.attachment,
                    initialValue: '',
                    onChanged: (newValue) 
                    {
                      _additionalCustomizationController.text = newValue!;
                    },
                  ),

                  const SizedBox(height: 16),
                  
                  // Generate Button
                   Button(
                    'essay',
                    onPressed: () 
                    {
                      final result = getSelectedResponses();

                      apiTest(result).then((dynamic results) 
                      {
                        setState(() 
                        {
                          globalRubric = results;  // Store the rubric
                        });
                      });
                    },
                   ),
                ],
              ),
            ),

            const SizedBox(width: 32), // Adds space between the two columns

            // Right Side
            Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 600,
                  color: Colors.grey[200],
                  child: _isLoading // Make the container dependent on the isLoading var
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(), // Loading spinner
                            SizedBox(height: 16),
                            Text(
                              "Generating Rubric...", // Display this text when we start loading
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    : globalRubric != null && globalRubric['criteria'] != null
                        ? SingleChildScrollView(
                            child: Table(
                              border: TableBorder.all(), // Adds border to the table cells
                              columnWidths: const 
                              {
                                0: FlexColumnWidth(2), // Description column
                                // Dynamically add scores per column
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Criteria',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),

                                    // Dynamically create score level headers
                                    for (var level in globalRubric['criteria'][0]['levels']) // Assuming all criteria have the same number of levels
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '${level['score']}',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                  ],
                                ),

                                // Create rows
                                for (var criteria in globalRubric['criteria']) ...[
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          criteria['description'],
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      // Add score levels for each column
                                      for (var level in criteria['levels'])
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            '${level['definition']}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          )
                        : Center(
                            child: Text(
                              "No Rubric Data Available",
                              style: TextStyle(fontSize: 18, color: Colors.black54),
                            ),
                          ),
                ),
                const SizedBox(height: 16),
                // Send to Moodle Button
                Button("assessment"),
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
class Button extends StatelessWidget {
  // Fields in this widget subclass are marked final
  final String type;
  final String text;
  final String filters = "";
  final VoidCallback? onPressed;
  Button._(this.type, this.text, {this.onPressed});

  factory Button(String type, {VoidCallback? onPressed}) 
  {
    if (type == "assessment") {
      return Button._(type, "Send to Moodle");
    } else if (type == "essay") {
      return Button._(
        type,
        "Generate Essay",
        onPressed: onPressed,
      );
    } else {
      return Button._(type, "");
    }
  }
  @override
  Widget build(BuildContext context) 
  {
    return OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.create), Text(text)],
        ));
  }
}

class TextBox extends StatefulWidget { // Create stateful widget to maintain persistence in textboxes from events
  final String label;
  final IconData icon;
  final IconData secondaryIcon;
  final String initialValue;
  final ValueChanged<String?> onChanged;

  const TextBox({
    Key? key,
    required this.label,
    required this.icon,
    required this.secondaryIcon,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TextBoxState createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> { // State within
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller with initial value
    _controller = TextEditingController(text: widget.initialValue);
    // Listen for changes
    _controller.addListener(() {
      widget.onChanged(_controller.text); // Call the passed onChanged function
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller, // Use the controller initialized in initState
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon),
            SizedBox(height: 4),
            Icon(widget.secondaryIcon),
          ],
        ),
      ),
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
      value:  selectedGradeLevel.isNotEmpty ? selectedGradeLevel : null,
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
