<?php

/*
 * Inherit the environmental drushrc file
 */
$local_drushrc = dirname(__FILE__) . '/drushrc.local.php';
if (file_exists($local_drushrc)) {
  require_once(dirname(__FILE__) . '/drushrc.local.php');
}
