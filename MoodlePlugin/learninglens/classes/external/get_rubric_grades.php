<?php
namespace local_learninglens\external;


defined('MOODLE_INTERNAL') || die();


/**
 * Returns rubric grades for a specific submission.
 *
 * @param int $assignmentid The ID of the assignment.
 * @param int $userid The ID of the student.
 * @return array Rubric grading details.
 */

 require_once($CFG->libdir . '/externallib.php');
 require_once("$CFG->dirroot/grade/grading/lib.php");
 require_once("$CFG->dirroot/mod/assign/locallib.php");
 
 use external_function_parameters;
 use external_single_structure;
 use external_multiple_structure;
 use external_value;
 use context_module;
 use external_api;

class get_rubric_grades extends external_api {

    public static function execute_parameters() {
        return new external_function_parameters([
            'assignmentid' => new external_value(PARAM_INT, 'ID of the assignment'),
            'userid' => new external_value(PARAM_INT, 'ID of the user')
        ]);
    }

    // Define the return structure for the function.
    public static function execute_returns() {
        return new external_multiple_structure(
         new external_single_structure(
            array(
                'criterion_description' => new external_value(PARAM_TEXT, 'The description of the criterion'),
                'level_description' => new external_value(PARAM_TEXT, 'The description of the level in the criterion'),
                'score' => new external_value(PARAM_FLOAT, 'The score for the criterion'),
                'remark' => new external_value(PARAM_RAW, 'Remarks by the grader')
                )
            )
        );
    }   
    public static function execute($assignmentid, $userid) {
        global $USER;

        // Validate the parameters.
        $params = self::validate_parameters(self::execute_parameters(), [
            'assignmentid' => $assignmentid,
            'userid' => $userid
        ]);

    global $DB;

    // Get the assignment's grading instance ID.
    $itemid = $DB->get_field('assign_grades', 'id', ['assignment' => $assignmentid, 'userid' => $userid], MUST_EXIST);

    // Add conditions to ensure you get only one grading instance.
    $gradinginstances = $DB->get_records('grading_instances', ['itemid' => $itemid]);

    // Loop through grading instances to find the one with a valid rubric definition.
    $gradinginstance = null;
    foreach ($gradinginstances as $instance) {
        $definition = $DB->get_record('grading_definitions', ['id' => $instance->definitionid]);
        if ($definition->method === 'rubric') {
            $gradinginstance = $instance;
            break;  // Found the correct rubric instance, stop further checks.
        }
    }

    if (!$gradinginstance) {
        throw new moodle_exception('norubricinstance', 'error', '', $assignmentid);
    }

    // Query the rubric fillings for this submission.
    $rubricgrades = $DB->get_records('gradingform_rubric_fillings', ['instanceid' => $gradinginstance->id]);

    $rubricdata = [];

    foreach ($rubricgrades as $grade) {
        $criterion = $DB->get_record('gradingform_rubric_criteria', ['id' => $grade->criterionid], '*', MUST_EXIST);
        $level = $DB->get_record('gradingform_rubric_levels', ['id' => $grade->levelid], '*', MUST_EXIST);
        $rubricdata[] = [
        'criterion_description' => $criterion->description,
        'level_description' => $level->definition,
        'score' => $level->score,
        'remark' => $grade->remark
            ];
        }

    return $rubricdata;

    }
}