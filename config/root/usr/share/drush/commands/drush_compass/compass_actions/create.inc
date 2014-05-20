<?php
/**
 * @file
 * Creates a new compass project for your theme.
 */

class drush_compass_create extends drush_compass_engine {
  protected $command = 'create';

  /**
   * Successful Compass creation message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {
    drush_log(dt('@theme was created sucessfully.', array('@theme' => $theme_name)), 'success');
    // Display creation message from the command line exec_output. Don't show twice if Drush is set to debug.
    if (!drush_get_context('DRUSH_DEBUG')) {
      drush_log(implode("\n", drush_shell_exec_output()), 'success');
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
      return (int) drush_shell_exec("compass create %s " . implode(' ', $this->_compass_get_options($this->command)), $theme_path);
    }
    return -1;
  }
}