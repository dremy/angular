<?php

/**
 * settings.local.php
 * 
 * This is where you store your environment-specific configurations.
 *   The site's settings.php file should inherit this automatically.
 *   If this is your first time here, simply replace all CAPITALIZED
 *   variables below with the proper values.
 */


// Database definition.
$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => 'DATABASE_NAME',
  'username' => 'USERNAME',
  'password' => 'PASSWORD',
  'host' => 'localhost',
  'prefix' => '',
  'collation' => 'utf8_general_ci',
);

// Define base URL for the installation.
$base_url = 'http://YOUR-DOMAIN.com';  # DO NOT ADD TRAILING SLASH!

// Apache Solr Index Definition.
$conf['apachesolr_environments']['solr']['url'] = 'http://localhost:8983/solr/drupal';

// Configure the site's region name. NOTE: this should be set through the UI, either
// during installation or under /admin/config/system/site-information
# $conf['region_name'] = 'YOUR REGION';

// Define installation profile to use at all times.
$conf['install_profile'] = 'tfa';
