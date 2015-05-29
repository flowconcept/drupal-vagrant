<?php
/**
 * @file
 * Development configuration overrides.
 */

/**
 * Database settings.
 */
$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'vagrant',
  'password' => 'v4gr4nt',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);

/**
 * configuration
 */
#$config_directories['active'] = '';
#$config_directories['staging'] = '';

/**
 * Enable local development services.
 */
#$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';

/**
 * Allow test modules and themes to be installed.
 *
 * Drupal ignores test modules and themes by default for performance reasons.
 * During development it can be useful to install test extensions for debugging
 * purposes.
 */
$settings['extension_discovery_scan_tests'] = TRUE;

/**
 * Enable access to rebuild.php.
 *
 * This setting can be enabled to allow Drupal's php and database cached
 * storage to be cleared via the rebuild.php page. Access to this page can also
 * be gained by generating a query string from rebuild_token_calculator.sh and
 * using these parameters in a request to rebuild.php.
 */
$settings['rebuild_access'] = TRUE;

/**
 * Allow access to update.php script.
 */
$settings['update_free_access'] = TRUE;

/**
 * Override configuration values.
 * ´drush --include-overridden cget´
 */

/**
 * Show all error messages, with backtrace information.
 * Possible values: hide, some, all, verbose.
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess'] = FALSE;

/**
 * Disable the render cache.
 *
 * This setting disables the render cache by using the Null cache back-end
 * defined by the development.services.yml file above.
 *
 * Do not use this setting until after the site is installed.
 */
#$settings['cache']['bins']['render'] = 'cache.backend.null';

// Limit log size.
$config['dblog.settings']['row_limit'] = 1000;

// Adjust local file system paths.
$settings['file_private_path'] = '/var/www/private';
$config['system.file']['path']['temporary'] = '/tmp';

/**
 * Configure Stage File Proxy origin.
 */
/*
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
// */