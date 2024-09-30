<?php
namespace learninglens\db;

$functions = [
    'local_learninglens_create_quiz' => [
        'classname'   => 'local_learninglens\external\create_quiz',
        'description' => 'Create a quiz in a specified course',
        'type'        => 'write',
        'ajax'        => true,
        'capabilities'=> 'mod/quiz:addinstance',
        'services'     => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
        ]
    ],
    'local_learninglens_add_question_to_quiz' => [
        'classname'   => 'local_learninglens\external\add_question_to_quiz',
        'description' => 'Add a question to a quiz',
        'type'        => 'write',
        'ajax'        => true,
        'capabilities'=> 'mod/quiz:manage',
        'services'     => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
            ]
        ],
     'local_learninglens_import_questions' => [
        'classname'   => 'local_learninglens\external\import_questions',
        'description' => 'Import XML questions to a course question bank',
        'type'        => 'write',
        'ajax'        => true,
        'capabilities'=> 'moodle/question:add',
        'services'     => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
            ]
        ],
        'local_learninglens_add_type_randoms_to_quiz' => [
        'classname'   => 'local_learninglens\external\add_type_randoms_to_quiz',
        'description' => 'Add questions of type random to quiz from category',
        'type'        => 'write',
        'ajax'        => true,
        'capabilities'=> 'mod/quiz:manage',
        'services'     => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
            ]
        ],
        'local_learninglens_get_rubric' => [
        'classname'   => 'local_learninglens\external\get_rubric',
        'description' => 'Returns instances of grading forms including rubrics.',
        'type'        => 'read',
        'ajax'        => true,
        'capabilities'=> 'moodle/grade:view',
        'services'    => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
            ]
        ],
        'local_learninglens_create_assignment' => [
        'classname'   => 'local_learninglens\external\create_assignment',
        'description' => 'Creates an assignment and optionally attach a rubric.',
        'type'        => 'write',
        'ajax'        => true,
        'capabilities'=> 'moodle/course:manageactivities',
        'services'    => [
            MOODLE_OFFICIAL_MOBILE_SERVICE,
            ]
        ],   
];