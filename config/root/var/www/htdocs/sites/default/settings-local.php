<?php
/**
 * @file
 * Development configuration overrides.
 */

/**
 * Custom database settings.
 */
$databases['default']['default']['host'] = 'localhost';
$databases['default']['default']['database'] = 'drupal';
$databases['default']['default']['username'] = 'vagrant';
$databases['default']['default']['password'] = 'v4gr4nt';

/**
 * Allow access to update.php script.
 */
$update_free_access = TRUE;

/**
 * Variable overrides.
 */

// Disable feature revert of boxes content.
$conf['boxes_ignore_changes'] = FALSE;

// Disable caching.
$conf['cache'] = FALSE;

// Display PHP notices.
$conf['error_level'] =  /*ERROR_REPORTING_DISPLAY_ALL*/ 2;

// Disable aggregation.
$conf['preprocess_css'] = FALSE;
$conf['preprocess_js'] = FALSE;

// Limit log size.
$conf['dblog_row_limit'] = 1000;

// Adjust local file system paths.
$conf['file_private_path'] = '/var/www/private';
$conf['file_temporary_path'] = '/tmp';

// Configure Stage File Proxy origin.
$conf['stage_file_proxy_origin'] = call_user_func(function() {
  $aliases = array();
  // Include drush configs
  $drush_config = '/vagrant/vagrant/config/root/home/vagrant/.drush/vagrant.aliases.drushrc.php';
  if (!file_exists($drush_config)) {
  	return FALSE;
  }
  include($drush_config);
  if (empty($aliases['staging']['uri'])) {
    return FALSE;
  }
  $url = array_merge(array('user' => 'flow', 'pass' => 'flowies'), parse_url($aliases['staging']['uri']));
  return $url['scheme'] . '://' . $url['user'] . ':' . $url['pass'] . '@' . $url['host'];
});
