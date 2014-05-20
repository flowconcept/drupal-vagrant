<?php
/**
 * @file
 * Initialises a Compass theme.
 */

class drush_compass_init extends drush_compass_engine {
  protected $command = 'init';

  /**
   * Successful Compass initing message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {
    if ($output = drush_shell_exec_output()) {
      drush_log(dt('@theme was initialised sucessfully.', array('@theme' => $theme_name)), 'success');
      // Don't show exec_output twice if Drush is set to debug.
      if (!drush_get_context('DRUSH_DEBUG')) {
        drush_log(implode("\n", $output), 'notice');
      }
    }
    else {
      drush_log(dt('No initialising necessary for @theme: already Compass enabled.', array('@theme' => $theme_name)), 'success');
    }
  }

  /**
   * Return specific (for this command) skipping message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function skipped($theme_name) {
    drush_log(dt('Skipping @theme; already using Compass.', array('@theme' => $theme_name)), 'success');
  }

  /**
   * Override executing compass command, as we want to only act on themes with no Compass support already.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   *
   * @return
   *   Returns 1 when the executable returns successfully (success), 0 when there's been an error (failure)
   *   else -1 when the Drupal theme is already a Compass theme (skipping).
   */
  protected function _compass_execute_command($theme_name) {
    // Check if the theme has a config.rb file, if it does then skip it.
    if (!($theme_path = drush_core_find_project_path($theme_name)) || !file_exists($theme_path . '/config.rb')) {
      return (int) drush_shell_exec("compass init &s %s " . implode(' ', $this->_compass_get_options($this->command)), $this->project_type, $theme_path);
    }
    return -1;
  }
}