<?php
/**
 * @file
 * Compiles a Compass theme stylesheets.
 */

class drush_compass_compile extends drush_compass_engine {
  protected $command = 'compile';

  /**
   * Successful Compass compilation message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {
    drush_log(dt('@theme was compiled sucessfully.', array('@theme' => $theme_name)), 'success');
    // Don't show exec_output twice if Drush is set to debug.
    if (!drush_get_context('DRUSH_DEBUG')) {
      drush_log(implode("\n", drush_shell_exec_output()), 'success');
    }
  }
}