<?php
namespace local_learninglens\external;

defined('MOODLE_INTERNAL') || die();

require_once($CFG->libdir . '/externallib.php');
require_once($CFG->dirroot . '/mod/quiz/lib.php');
require_once($CFG->dirroot . '/mod/quiz/locallib.php');

use external_function_parameters;
use external_single_structure;
use external_value;
use moodle_exception;
use coding_exception;
use required_capability_exception;
use access_manager;
use external_api;

class add_question_to_quiz extends \external_api {

public static function execute_parameters(): external_function_parameters {
    return new external_function_parameters(
        array(
            'quizid' => new external_value(PARAM_INT, 'ID of the quiz'),
            'questionid' => new external_value(PARAM_INT, 'ID of the question'),
        )
    );
}

public static function execute_returns(): external_single_structure {
    return new external_single_structure(
        array(
            'questionid' => new external_value(PARAM_INT, 'ID of the created question')
        )
    );
}

public static function execute($quizid, $questionid): array {
    global $DB, $USER;

    // check if the quiz exists.
    if (!$quiz = $DB->get_record('quiz', array('id' => $quizid))) {
        throw new moodle_exception('invalidquizid', 'error');
    }

    // add question to quiz
    quiz_add_quiz_question($questionid, $quiz, $page = 0, $maxmark = null);

    // return question id
    return array('questionid' => $questionid);
}
};