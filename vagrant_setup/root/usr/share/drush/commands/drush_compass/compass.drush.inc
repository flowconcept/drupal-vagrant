<?php
/**
 * @file
 * Drush include for integrating Compass compile.
 */

/**
 * Implements hook_drush_help().
 */
function compass_drush_help($section) {
  switch ($section) {
    case 'drush:compass':
      $command_table = new Console_Table(CONSOLE_TABLE_ALIGN_LEFT, '');
      $actions = array();
      foreach (compass_drush_engine_compass_actions() as $key => $command) {
        $actions[$key] = $command['description'];
      }
      $command_table->addData(drush_key_value_to_array_table($actions));
      return dt("Integration with Compass command line tool, providing:\n@commands", array('@commands' => $command_table->getTable()));
  }
}

/**
 * Implements hook_drush_command().
 */
function compass_drush_command() {
  $items['compass'] = array(
    'description' => 'Integrates with Compass command line tool.',
    'arguments' => array(
      'command' => 'The Compass command you want to run, e.g. clean, compile (default), create, init, stats or validate.',
      'project-type' => '(For init only) the project-type for your Compass project.',
    ),
    'options' => array(
      'themes' => 'A comma delimited list of theme names, if omitted the command will act on all themes.',
      'dry-run' => 'Dry Run. Tells you what it plans to do.',
      'environment' => 'An environment name to pass to compass, defaults to "production".',
      'force' => 'Allows some failing commands to succeed instead.',
      'load' => 'Load the framework or extensions found in the FRAMEWORK directory.',
      'load-all' => 'Load all the frameworks or extensions found in the FRAMEWORKS_DIR directory.',
      'output-style' => 'Select a CSS output mode, one of: nested, expanded, compact, compressed',
      'quiet' => 'Quiet mode.',
      'require' => 'Require the given ruby LIBRARY before running commands.',
      'trace' => 'Show a full stacktrace on error.',
      'verbose' => 'Displays all command line output.',
    ),
    'examples' => array(
      'drush compass clean --themes=itvp,omega' => 'Removes generated files and the sass cache from the itvp and omega themes in the production (default) environment.',
      'drush compass compile' => 'Compiles all theme stylesheets for the production (default) environment.',
      'drush compass create --themes=itvp --environment=development' => 'Creates a Compass project in the itvp theme for the development environment.',
      'drush compass stats --themes=itvp --force' => 'Forces a rebuild and shows statistics of the itvp theme stylesheets for the production (default) environment.',
      'drush compass validate' => 'Compiles and validates all theme stylesheets for the production (default) environment.',
    ),
    'engines' => array('compass_actions'),
    'aliases' => array('sass'),
    'bootstrap' => DRUSH_BOOTSTRAP_DRUPAL_FULL,
  );
  return $items;
}

/**
 * Implements hook_drush_engine_type_info().
 */
function compass_drush_engine_type_info() {
  return array(
    'compass_actions' => array(),
  );
}

/**
 * Implements hook_drush_engine_$type().
 */
function compass_drush_engine_compass_actions() {
  return array(
    'clean' => array(
      'description' => 'Remove generated files and the sass cache from a Compass theme.',
    ),
    'compile' => array(
      'description' => 'Compiles a Compass theme stylesheets.',
    ),
    'create' => array(
      'description' => 'Creates a new compass project for your theme.',
    ),
    'init' => array(
      'description' => 'Initialize an existing project for your theme.',
    ),
    'stats' => array(
      'description' => 'Compiles and displays statistics of a Compass theme stylesheets.',
    ),
    'validate' => array(
      'description' => 'Compiles and validate the generated theme stylesheets.',
    ),
  );
}

/**
 * Implements drush_hook_COMMAND_validate().
 */
function drush_compass_validate($command = 'compile', $project_type = NULL) {
  if (!array_key_exists($command, compass_drush_engine_compass_actions())) {
    return drush_set_error('COMPASS', dt("Aborting; No Compass command '@command' found.", array('@command' => $command)));
  }
  // Only continue if Compass is actually installed.
  if (!drush_shell_exec('command -v compass 2>&1')) {
    return drush_set_error('COMPASS', dt('Aborting; Sass Compass executable not found.'));
  }
  if (($style = drush_get_option('output-style')) && !in_array($style, array('nested', 'expanded', 'compact', 'compressed'))) {
    return drush_set_error('COMPASS', dt('Aborting; Unknown style @style.', array('@style' => $style)));
  }
  // The 'init' command is the only one to use project-type.
  if ($command == 'init') {
    if ($project_type) {
      // @todo Find a way to validate the project type.
//      return drush_set_error('COMPASS', dt('Aborting; Unsupported project type @project_type.', array('@project_type' => $project_type)));
    }
    else {
      return drush_set_error('COMPASS', dt('Aborting; Project type is not optional for the init command.'));
    }
  }
}

/**
 * Drush Compass command callback.
 */
function drush_compass($command = 'compile', $project_type = NULL) {
  drush_include_engine('compass_actions', $command);
  // Parse --themes=xxx arguments if supplied.
  if ($theme_names = drush_get_option('themes')) {
    $theme_names = explode(',', $theme_names);
  }
  // If no --themes=xxx arguments are supplied then use all themes.
  else {
    drush_include_engine('drupal', 'environment');
    $theme_names = array_keys(drush_get_themes());
  }
  $class = 'drush_compass_' . $command;
  return new $class($theme_names, $project_type);
}

/**
 * Interface which lets us know what functions to use.
 */
interface drush_compass {
  function success($theme_name);
  function failure($theme_name);
  function skipped($theme_name);
}

/**
 * Abstract class, a wrapper for running Compass commands.
 */
abstract class drush_compass_engine implements drush_compass {
  // Defaults to 'compile' command if no command is passed.
  protected $command = 'compile';
  protected $project_type;

  /**
   * Helper function for executing compass command.
   *
   * @param $theme_names
   *   An array of Drupal theme names to run the Compass executable against.
   */
  public function __construct($theme_names, $project_type = '') {
    $this->project_type = $project_type;
    foreach ($theme_names as $theme_name) {
      switch ($this->_compass_execute_command($theme_name)) {
        case -1:
          $this->skipped($theme_name);
          continue;
        case 0:
          $this->failure($theme_name);
          break;
        case 1:
          $this->success($theme_name);
          break;
      }
    }
  }

  /**
   * Success function always needs defining, as is always different for each command.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {}

  /**
   * Helper function for returning a generic failure message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function failure($theme_name) {
    drush_set_error('COMPASS',
      dt("The theme @theme did not @action successfully:\n@result",
        array(
          '@theme' => $theme_name,
          '@action' => $this->command,
          '@result' => implode("\n", drush_shell_exec_output()),
        )
      )
    );
  }

  /**
   * Helper function for returning a generic skipped message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function skipped($theme_name) {
    if (drush_get_context('DRUSH_DEBUG')) {
      drush_log(dt('Skipping @theme; not a Compass theme.', array('@theme' => $theme_name)), 'notice');
    }
  }

  /**
   * Parses generic Compass command line options.
   *
   * @param $command
   *   The current Compass command being actioned on (e.g. compile, validate, etc).
   *
   * @return
   *   An array of options to pass to the Compass executable.
   */
  protected function _compass_get_options($command) {
    $compass_options = array();

    // Global options.
    if ($require = drush_get_option('require')) {
      $compass_options[] = '--require=' . drush_escapeshellarg($require);
    }
    if ($load_dir = drush_get_option('load')) {
      $compass_options[] = '--load=' . drush_escapeshellarg($load_dir);
    }
    if ($load_all_dir = drush_get_option('load-all')) {
      $compass_options[] = '--load-all=' . drush_escapeshellarg($load_all_dir);
    }
    if (drush_get_option('quiet')) {
      $compass_options[] = '--quiet';
    }
    // Also add trace output if --debug is passed.
    if (drush_get_option('trace') || drush_get_context('DRUSH_DEBUG')) {
      $compass_options[] = '--trace';
    }
    if (drush_get_option('force')) {
      $compass_options[] = '--force';
    }
    if (drush_get_option('dry-run')) {
      $compass_options[] = '--dry-run';
    }
    // Define default options to pass to Compass.
    $compass_options[] = '--boring';
    $compass_options[] = '--environment=' . drush_escapeshellarg(drush_get_option('environment', 'production'));

    // Parse optional parameters (generally not applicable to all commands).
    if ($style = drush_get_option('output-style')) {
      $compass_options[] = '--output-style=' . drush_escapeshellarg($style);
    }

    return $compass_options;
  }

  /**
   * Helper function for executing compass command.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   *
   * @return
   *   Returns -1 when the Drupal theme isn't a Compass theme (skipping), 1 when the executable
   *   returns successfully (success), else 0 when there's been an error (failure).
   */
  protected function _compass_execute_command($theme_name) {
    // If the theme has a config.rb file it's Compass, if not carry on.
    if (!($theme_path = drush_core_find_project_path($theme_name)) || !file_exists($theme_path . '/config.rb')) {
      return -1;
    }
    return (int) drush_shell_exec("compass %s %s " . implode(' ', $this->_compass_get_options($this->command)), $this->command, $theme_path);
  }
}
