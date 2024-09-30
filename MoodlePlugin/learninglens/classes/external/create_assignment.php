<?php
namespace local_learninglens\external;

defined('MOODLE_INTERNAL') || die();

require_once($CFG->libdir . '/externallib.php');
require_once($CFG->dirroot . '/course/modlib.php');
require_once($CFG->dirroot . '/mod/assign/lib.php');
require_once($CFG->dirroot.'/mod/assign/locallib.php');
require_once($CFG->dirroot.'/grade/grading/lib.php');
require_once($CFG->dirroot.'/grade/grading/form/rubric/lib.php');

use external_function_parameters;
use external_single_structure;
use external_multiple_structure;
use external_value;
use context_system;
use context_course;
use context_module;
use moodle_exception;
use coding_exception;
use required_capability_exception;
use access_manager;
use external_api;
use qformat_xml;
use question_bank;
use question_edit_contexts;

class create_assignment extends \external_api {

    public static function execute_parameters() {
        return new external_function_parameters(
            array(
                'courseid'    => new external_value(PARAM_INT, 'Course ID'),
                'sectionid'   => new external_value(PARAM_INT, 'Section ID'),
                'name'        => new external_value(PARAM_TEXT, 'Assignment name'),
                'description' => new external_value(PARAM_RAW, 'Assignment description', VALUE_OPTIONAL),
                'duedate'     => new external_value(PARAM_INT, 'Due date timestamp', VALUE_OPTIONAL),
                'startdate'     => new external_value(PARAM_INT, 'Start date timestamp', VALUE_OPTIONAL),
                'rubricdefinitionid'    => new external_value(PARAM_INT, 'Rubric Definition ID', VALUE_OPTIONAL),
                // Add more parameters as needed.
            )
        );
    }

    public static function execute($courseid, $sectionid, $name, $description = '', $startdate = 0, $duedate = 0, $rubricdefinitionid = 0) {
        global $DB, $CFG, $USER;

        // Validate parameters.
        $params = self::validate_parameters(self::execute_parameters(), array(
            'courseid'    => $courseid,
            'sectionid'   => $sectionid,
            'name'        => $name,
            'description' => $description,
            'startdate'   => $startdate,
            'duedate'     => $duedate,
            'rubricdefinitionid'    => $rubricdefinitionid,
        ));

        // Debugging: Log parameter values
        error_log('Debug: courseid = ' . $params['courseid']);
        error_log('Debug: sectionid = ' . $params['sectionid']);

        // Context validation.
        $context = context_course::instance($params['courseid']);
        self::validate_context($context);

        // Capability check.
        require_capability('moodle/course:manageactivities', $context);

        // Retrieve the course record.
        try {
            $course = $DB->get_record('course', array('id' => $params['courseid']), '*', MUST_EXIST);
        } catch (dml_missing_record_exception $e) {
            throw new invalid_parameter_exception('Invalid course ID: ' . $params['courseid']);
        }

        // Check if the section exists in the course.
        try {
            $section = $DB->get_record('course_sections', array('section' => $params['sectionid'], 'course' => $params['courseid']), '*', MUST_EXIST);
        } catch (dml_missing_record_exception $e) {
            throw new invalid_parameter_exception('Invalid section ID: ' . $params['sectionid'] . ' for course ID: ' . $params['courseid']);
        }

        // Prepare assignment data.
        $assignment = new \stdClass();
        $assignment->course       = $params['courseid'];
        $assignment->name         = $params['name'];
        $assignment->intro        = $params['description'];
        $assignment->introformat  = FORMAT_HTML;
        $assignment->duedate      = $params['duedate'];
        $assignment->timemodified = time();
        $assignment->submissiondrafts = 1;
        $assignment->requiresubmissionstatement = 0;
        $assignment->assignmenttype = 'onlinetext';
        $assignment->allowsubmissions = 1;
        $assignment->sendnotifications = 0;
        $assignment->sendlatenotifications = 0;
        $assignment->cutoffdate = $params['duedate'] + 86400;
        $assignment->gradingduedate = $params['duedate'] + 86400;
        $assignment->allowsubmissionsfromdate = $params['startdate'];
        $assignment->grade = 0;
        $assignment->teamsubmission = 0;
        $assignment->requireallteammemberssubmit = 0;
        $assignment->blindmarking = 0;
        $assignment->markingworkflow = 0;

        // Module info.
        $moduleinfo = new \stdClass();
        $moduleinfo->modulename = 'assign'; // Correct module name
        $moduleinfo->section    = $section->section; // Use section number, not section ID
        $moduleinfo->visible    = 1;
        $moduleinfo->module     = $DB->get_field('modules', 'id', array('name' => 'assign'), MUST_EXIST);

        // Merge assignment data into module info.
        foreach ($assignment as $key => $value) {
            $moduleinfo->{$key} = $value;
        }

        // Add the assignment module.
        try {
            $moduleinfo = add_moduleinfo($moduleinfo, $course); // Pass the course object   
            $cmid = $moduleinfo->coursemodule; // Capture the course module ID (cmid) of the new assignment.
        } catch (moodle_exception $e) {
            throw new moodle_exception('moduledberror', 'error', '', $e->getMessage());
        }

        // $context = context_module::instance($cmid);
    
        //     // Set the rubric grading method for the assignment
        //     $grading_area = $DB->get_record('grading_areas', array('contextid' => $context->id, 'component' => 'mod_assign', 'areaname' => 'submissions'), '*', MUST_EXIST);
        //     $grading_definition = $DB->get_record('grading_definitions', array('id' => $rubricdefinitionid, 'areaid' => $grading_area->id), '*', MUST_EXIST);
    
        //     // Use the rubric template for this assignment
        //     $grading_instance = new gradingform_rubric_instance($grading_definition->id);
        //     $grading_instance->set_status(GRADINGFORM_INSTANCE_STATUS_ACTIVE);
        //     $grading_instance->save();
        



        if ($rubricdefinitionid !== 0) {



        //     // Get the context of the assignment
        //     $context = context_module::instance($cmid);
        
        //     // Initialize the grading manager
        //     $grading_manager = get_grading_manager($context);
        //     $grading_manager->set_component('mod_assign');
        //     $grading_manager->set_area('submissions');
        
        //     // Set the grading method to 'rubric'
        //     $grading_manager->set_active_method('rubric');
        
        //     // Get the controller for the rubric grading method
        //     $controller = $grading_manager->get_controller('rubric');
        //     error_log("scm test");
        //     if ($controller instanceof \gradingform_rubric_controller) {
        //         try {
        //             // Retrieve the rubric definition (template) by its ID from the `grading_definitions` table.
        //             $rubric_definition = $DB->get_record('grading_definitions', array('id' => $rubricdefinitionid), '*', MUST_EXIST);
        //             error_log("Successfully retrieved rubric definition: " . json_encode($rubric_definition));
            
        //             // Log the parameters being passed to get_or_create_instance
        //             error_log("Attempting to create grading instance with parameters: user_id={$USER->id}, cmid={$cmid}");
            
        //             // // Set the rubric definition to the controller
        //             // $controller->update_definition($rubric_definition);
        //             // error_log("Successfully set rubric definition to the controller");


        //     // $grading_instance = new gradingform_rubric_instance($rubric_definition->id);
        //     $grading_instance = $grading_manager->create_instance($rubric_definition->id, GRADINGFORM_INSTANCE_STATUS_ACTIVE);
        //     $grading_instance->set_status(GRADINGFORM_INSTANCE_STATUS_ACTIVE);
        //     $grading_instance->save();
        //     error_log("Successfully created grading instance with ID: " . $grading_instance->get_id());


        //             // // Create a new grading instance for the assignment using the template rubric definition.
        //             // $grading_instance = $controller->get_or_create_instance(null, $USER->id, $cmid);
        //             // if (!$grading_instance) {
        //             //     error_log("Failed to create grading instance for cmid $cmid");
        //             //     throw new moodle_exception('failedtorubric', 'gradingform_rubric', '', 'Failed to create grading instance.');
        //             // }
        //             // error_log("Successfully created grading instance with ID: " . $grading_instance->get_id());
            





        //             // Attach the template rubric to the grading instance
        //             $controller->update_instance($grading_instance->get_id(), $rubric_definition);
        //             error_log("Successfully updated grading instance with rubric definition ID $rubricdefinitionid");
            
        //             // Log success
        //             error_log("Successfully attached rubric definition ID $rubricdefinitionid to assignment with cmid $cmid");
        //         } catch (dml_exception $e) {
        //             error_log("Error attaching rubric definition: " . $e->getMessage());
        //             throw new moodle_exception('failedtorubric', 'gradingform_rubric', '', 'Failed to attach the rubric template.');
        //         }
        //     } else {
        //         throw new moodle_exception('invalidcontroller', 'gradingform_rubric', '', 'Failed to retrieve the rubric controller.');
        //     }
        }
        return $cmid; // Return the course module ID of the new assignment
    }

    public static function execute_returns() {
        return new external_value(PARAM_INT, 'Course module ID of the new assignment');
    }


    function attach_rubric_to_assignment($assignmentid, $templateid) {
        global $DB, $CFG;
    
        // Get the course module and context for the assignment
        $cm = get_coursemodule_from_instance('assign', $assignmentid, 0, false, MUST_EXIST);
        $context = context_module::instance($cm->id);
    
        // Initialize the grading manager for this context and component
        $grading_manager = get_grading_manager($context, 'mod_assign', 'submissions');
    
        // Fetch the grading definition (rubric template)
        $grading_definition = $DB->get_record('grading_definitions', array('id' => $templateid, 'method' => 'rubric'), '*', MUST_EXIST);
    
        // Load the rubric definition using the grading form API
        $definition = \gradingform_rubric\definition::fetch_definition($templateid);
    
        if (!$definition) {
            throw new moodle_exception('invalidtemplateid', 'gradingform_rubric', '', $templateid);
        }
    
        // Create a grading instance from the rubric definition
        $instance = $grading_manager->create_instance_from_definition($definition, \grading_manager::FORCE_NEW);
    
        // Activate the grading instance
        $instance->set_status(\core_grading\constants::GRADINGFORM_INSTANCE_ACTIVE);
    
        // Save the instance to apply it
        $instance->save();
    
        // Optionally, update the assignment's grading method to use rubric
        $assign = new stdClass();
        $assign->id = $assignmentid;
        $assign->gradingmethod = ASSIGN_GRADINGMETHOD_RUBRIC; // Ensure this constant is correct
    
        $DB->update_record('assign', $assign);
    
        return true; // Indicate success
    }
    



}
