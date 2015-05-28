<?php
$aliases['dev'] = array(
  'root'         => '/var/www/htdocs',
  'uri'          => 'http://localhost',
  'path-aliases' =>
    array(
      '%site' => 'sites/default/',
      '%files' => 'sites/default/files',
    ),
  'databases'    =>
    array(
      'default' =>
        array(
          'default' =>
            array(
              'database' => 'drupal',
              'username' => 'vagrant',
              'password' => 'v4gr4nt',
              'host'     => 'localhost',
              'port'     => '',
              'driver'   => 'mysql',
              'prefix'   => '',
            ),
        ),
    ),
);


// Try to extract the site out of the sites-local.php
// sites-local.php should have been generated by config.sh
call_user_func(function () use (&$aliases) {
  $sites_dir = '/var/www/htdocs/sites/';
  if (file_exists($sites_dir . 'sites-local.php')) {
    require($sites_dir . 'sites-local.php');

    // Get the current site for localhost
    if (!empty($sites['localhost'])) {
      // Update sites directory
      $site_dir = $sites_dir . $sites['localhost'];
      if (is_dir($site_dir)) {
        $aliases['dev']['path-aliases'] = array('%site' => 'sites/' . $sites['localhost'] . '/');
      }
      // Load staging configuration
      $drush_alias = '/var/www/drush_config/' . $sites['localhost'] . '.aliases.drushrc.php';
      if (file_exists($drush_alias)) {
        require($drush_alias);
      }
    }
  }
});

// No staging configuration found in sites-local.php
if (empty($aliases['staging'])) {
  // Require staging configuration
  if ($handle = opendir('/var/www/drush_config')) {
    while (FALSE !== ($file = readdir($handle))) {
      if (pathinfo($file, PATHINFO_EXTENSION) == 'php') {
        require('/var/www/drush_config/' . $file);
      }
    }
  }
}
