<?php

namespace Drupal\Driver;

use Drupal\Exception\BootstrapException,
    Drupal\DrupalExtension\Context\DrupalSubContextFinderInterface;

use Symfony\Component\Process\Process;

/**
 * Implements DriverInterface.
 */
class DrushDriver extends BaseDriver {
  /**
   * Store a drush alias for tests requiring shell access.
   */
  public $alias = FALSE;

  /**
   * Store the root path to a Drupal installation. This is an alternative to
   * using drush aliases.
   */
  public $root = FALSE;

  /**
   * Store the path to drush binary.
   */
  public $binary = FALSE;

  /**
   * Track bootstrapping.
   */
  private $bootstrapped = FALSE;

  /**
   * Global arguments or options for drush commands.
   *
   * @var string
   */
  private $arguments = '';

  /**
   * Set drush alias or root path.
   *
   * @param string $alias
   *   A drush alias
   * @param string $root_path
   *   The root path of the Drupal install. This is an alternative to using aliases.
   * @param string $binary
   *   The path to the drush binary.
   */
  public function __construct($alias = NULL, $root_path = NULL, $binary = 'drush') {
    if ($alias) {
      // Trim off the '@' symbol if it has been added.
      $alias = ltrim($alias, '@');

      $this->alias = $alias;
    }
    elseif ($root_path) {
      $this->root = realpath($root_path);
    }
    else {
      throw new \BootstrapException('A drush alias or root path is required.');
    }

    $this->binary = $binary;
  }

  /**
   * Implements DriverInterface::bootstrap().
   */
  public function bootstrap() {
    // Check that the given alias works.
    // @todo check that this is a functioning alias.
    // See http://drupal.org/node/1615450
    if (!$this->alias && !$this->root) {
      throw new BootstrapException('A drush alias or root path is required.');
    }
    $this->bootstrapped = TRUE;
  }

  /**
   * Implements DriverInterface::isBootstrapped().
   */
  public function isBootstrapped() {
    return $this->bootstrapped;
  }

  /**
   * Implements DriverInterface::userCreate().
   */
  public function userCreate(\stdClass $user) {
    $arguments = array(
      $user->name,
    );
    $options = array(
      'password' => $user->pass,
      'mail' => $user->mail,
    );
    $this->drush('user-create', $arguments, $options);
    if (isset($user->roles) && is_array($user->roles)) {
      foreach ($user->roles as $role) {
        $this->userAddRole($user, $role);
      }
    }
  }

  /**
   * Implements DriverInterface::userDelete().
   */
  public function userDelete(\stdClass $user) {
    $arguments = array($user->name);
    $options = array(
      'yes' => NULL,
      'delete-content' => NULL,
    );
    $this->drush('user-cancel', $arguments, $options);
  }

  /**
   * Implements DriverInterface::userAddRole().
   */
  public function userAddRole(\stdClass $user, $role) {
    $arguments = array(
      sprintf('"%s"', $role),
      $user->name
    );
    $this->drush('user-add-role', $arguments);
  }

  /**
   * Implements DriverInterface::fetchWatchdog().
   */
  public function fetchWatchdog($count = 10, $type = NULL, $severity = NULL) {
    $options = array(
      'count' => $count,
      'type' => $type,
      'severity' => $severity,
    );
    return $this->drush('watchdog-show', array(), $options);
  }

  /**
   * Implements DriverInterface::clearCache().
   */
  public function clearCache($type = 'all') {
    $type = array($type);
    return $this->drush('cache-clear', $type, array());
  }

  /**
   * Sets common drush arguments or options.
   *
   * @param string $arguments
   *   Global arguments to add to every drush command.
   */
  public function setArguments($arguments) {
    $this->arguments = $arguments;
  }

  /**
   * Get common drush arguments.
   */
  public function getArguments() {
    return $this->arguments;
  }

  /**
   * Parse arguments into a string.
   *
   * @param array $arguments
   *   An array of argument/option names to values.
   *
   * @return string
   */
  protected static function parseArguments(array $arguments) {
    $string = '';
    foreach ($arguments as $name => $value) {
      if (is_null($value)) {
        $string .= ' --' . $name;
      }
      else {
        $string .= ' --' . $name . '=' . $value;
      }
    }
    return $string;
  }

  /**
   * Execute a drush command.
   */
  public function drush($command, array $arguments = array(), array $options = array()) {
    $arguments = implode(' ', $arguments);
    $options['nocolor'] = '';
    $string_options = $this->parseArguments($options);

    $alias = isset($this->alias) ? "@{$this->alias}" : '--root=' . $this->root;

    // Add any global arguments.
    $global = $this->getArguments();

    $alias = $this->alias ? "@{$this->alias}" : '--root=' . $this->root;

    $process = new Process("{$this->binary} {$alias} {$global} {$command} {$string_options} {$arguments}");
    $process->setTimeout(3600);
    $process->run();

    if (!$process->isSuccessful()) {
      throw new \RuntimeException($process->getErrorOutput());
    }

    // Some drush commands write to standard error output (for example enable
    // use drush_log which default to _drush_print_log) instead of returning a string
    // (drush status use drush_print_pipe).
    if (!$process->getOutput()) {
      return $process->getErrorOutput();
    }
    else {
      return $process->getOutput();
    }

  }

  /**
   * Implements DriverInterface::processBatch().
   */
  public function processBatch() {
    // Do nothing. Drush should internally handle any needs for processing batch ops.
  }

  /**
   * Implements DriverInterface::runCron().
   */
  public function runCron() {
    $this->drush('cron');
  }

  /**
   * Helper function to derive the Drupal root directory from given alias.
   */
  public function getDrupalRoot($alias = NULL) {
    if (!$alias) {
      $alias = $this->alias;
    }

    // Use drush site-alias to find path.
    $path = $this->drush('site-alias', array('@' . $alias), array('pipe' => NULL));

    // Remove anything past the # that occasionally returns with site-alias.
    $path = reset(explode('#', $path));

    return $path;
  }

  /**
   * Run Drush commands dynamically from a DrupalContext.
   */
  public function __call($name, $arguments) {
    return $this->drush($name, $arguments);
  }

}
