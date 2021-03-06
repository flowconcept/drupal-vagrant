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


// Try to extract the site from sites-local.php
// sites-local.php is generated by `vagrant provision` if a multi-site system is detected
call_user_func(function () use (&$aliases) {
  $sites_dir = '/var/www/htdocs/sites/';
  if (file_exists($sites_dir . 'sites-local.php')) {
    require($sites_dir . 'sites-local.php');

    // Get the active site for localhost
    if (!empty($sites['localhost'])) {
      // Update sites directory
      $site_dir = $sites_dir . $sites['localhost'];
      if (is_dir($site_dir)) {
        $aliases['dev']['path-aliases'] = array('%site' => 'sites/' . $sites['localhost'] . '/');
      }
      // Load staging configuration
      $drush_alias = '/var/www/config/' . $sites['localhost'] . '.aliases.drushrc.php';
      if (file_exists($drush_alias)) {
        require($drush_alias);
      }
    }
  }
});

// If no staging configuration found in sites-local.php, try loading staging configuration
if (empty($aliases['staging']) && file_exists('/var/www/config')) {
  if ($handle = opendir('/var/www/config')) {
    while (FALSE !== ($file = readdir($handle))) {
      if (preg_match('/aliases\.drushrc\.php/', pathinfo($file, PATHINFO_BASENAME))) {
        require('/var/www/config/' . $file);
      }
    }
  }
}
