<?php
/**
 * @file
 * Remove generated files and the sass cache from a Compass theme.
 */

class drush_compass_clean extends drush_compass_engine {
  protected $command = 'clean';

  /**
   * Successful Compass cleaning message.
   *
   * @param $theme_name
   *   The current Drupal theme name the Compass executable is being run against.
   */
  public function success($theme_name) {
    if ($output = drush_shell_exec_output()) {
      drush_log(dt('@theme was cleaned sucessfully.', array('@theme' => $theme_name)), 'success');
      // Don't show exec_output twice if Drush is set to debug.
      if (!drush_get_context('DRUSH_DEBUG')) {
        drush_log(implode("\n", $output), 'notice');
      }
    }
    else {
      drush_log(dt('No cleaning necessary for @theme: already clean.', array('@theme' => $theme_name)), 'success');
    }
  }
}