<?php
/**
 * @file
 * Compiles and displays statistics of a Compass theme stylesheets.
 */

class drush_compass_stats extends drush_compass_engine {
  protected $command = 'stats';

  /**
   * Successful Compass compilation message ensures output of produced statistics.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {
    drush_log(dt('@theme was compiled sucessfully.', array('@theme' => $theme_name)), 'success');
    // Display stats from the command line exec_output. Don't show twice if Drush is set to debug.
    if (!drush_get_context('DRUSH_DEBUG')) {
      drush_log(implode("\n", drush_shell_exec_output()), 'success');
    }
  }
}