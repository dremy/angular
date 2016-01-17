<?php

/**
 * @file
 * TFA-specific functions
 */

use Behat\Behat\Context\ClosuredContextInterface,
    Behat\Behat\Context\TranslatedContextInterface,
    Behat\Behat\Context\BehatContext,
    Behat\Behat\Exception\PendingException;
use Behat\Gherkin\Node\PyStringNode,
    Behat\Gherkin\Node\TableNode;
use Behat\Mink\Exception\ElementNotFoundException;

//
// Require 3rd-party libraries here:
//
//   require_once 'PHPUnit/Autoload.php';
//   require_once 'PHPUnit/Framework/Assert/Functions.php';
//

/**
 * Features context.
 */
class FeatureContext extends Drupal\DrupalExtension\Context\DrupalContext {
  private $lastRealScald = FALSE;
  private $chosenJquerySelector;
  /**
   * Initializes context -- Every scenario gets its own context object.
   *
   * @param array $parameters
   *   Context parameters (set them in behat.yml).
   */
  public function __construct(array $parameters) {
    // Initialize your context here.
    $this->useContext('panels', new PanelsSubContext());
  }

  /**
   * The field with the label 'Short Bio' was found when we search for 'Bio'.
   *
   * @Given /^I add a Bio of "([^"]*)"$/
   */
  public function iAddABioOf($value) {
    return $this->getSession()->getPage()->fillField('edit-body-und-0-value', $value);
  }

  /**
   * Open or close a scald browser (the action is the same).
   *
   * @Given /^I "([^"]*)" the scald browser$/
   */
  public function iTheScaldBrowser($action) {
    $button = $this->getSession()->getPage()->find('xpath', '//div[@class="scald-anchor"]');

    if (NULL === $button) {
      throw new ElementNotFoundException(
        $this->getSession(), 'button', 'class', 'scald-anchor'
      );
    }

    return $button->click();
  }

  /**
   * Remove atoms that were created during content creation.
   *
   * @AfterScenario
   */
  public function cleanupAtoms() {
    $query = new EntityFieldQuery();
    $result = $query->entityCondition('entity_type', 'scald_atom')
      ->propertyCondition('sid', $this->lastRealScald, '>')
      ->execute();
    if (isset($result['scald_atom'])) {
      $sids = array_keys($result['scald_atom']);
      scald_atom_delete_multiple($sids);
    }
  }

  /**
   * Find the greatest ID for atoms.
   *
   * @BeforeScenario
   */
  public function getAtomsID() {
    $query = db_select('scald_atoms', 'atoms')
      ->fields('atoms', array('sid'))
      ->orderBy('sid', 'DESC');
    $this->lastRealScald = $query->execute()->fetchfield();
  }

  /**
   * Ensures the window is a valid size.
   *
   * @beforeScenario @javascript
   */
  public function resizeWindow() {
    $this->getSession()->resizeWindow(1440, 900, 'current');
  }

  /**
   * @Given /^I visit the "([^"]*)" link in the "([^"]*)" region$/
   *
   * Necessary to avoid opening a new tab, despite the "_blank" target.
   */
  public function iVisitTheLinkInTheRegion($link, $region) {
    $regionObj = $this->getRegion($region);

    // Find the link within the region
    $linkObj = $regionObj->findLink($link);
    if (empty($linkObj)) {
      throw new \Exception(sprintf('The link "%s" was not found in the region "%s" on the page %s', $link, $region, $this->getSession()->getCurrentUrl()));
    }
    $destination = $linkObj->getAttribute('href');

    $this->getSession()->visit($this->locatePath($destination));
  }

  /**
   * @Given /^"([^"]*)" atoms:$/
   */
  public function atoms($type, TableNode $atoms) {
    foreach ($atoms->getHash() as $values) {
      // Make a new scald with $file.
      if ($this->getMinkParameter('files_path')) {
        $fullPath = rtrim(realpath($this->getMinkParameter('files_path')), DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR.$values['scald_thumbnail'];
        if (!is_file($fullPath)) {
          throw new \Exception(sprintf("Could not find file at %s", $fullPath));
        }
      }

      $file = file_save_data(file_get_contents($fullPath), 'public://' . $values['scald_thumbnail']);

      if (!$file) {
        throw new \Exception(sprintf("Could not make file from path %s", $fullPath));
      }

      $atom = new ScaldAtom($type, 'scald_image');
      $atom->title = $values['title'];
      $atom->base_id = $file->fid;
      $atom->scald_thumbnail[LANGUAGE_NONE][0] = (array) $file;
      $atom->save();
    }
  }

  /**
   * Map custom node labels.
   *
   * @beforeNodeCreate
   */
  public function mapNodeLinks($event) {
    $node = $event->getEntity();

    if (isset($node->{'link field'})) {
      $node->{$node->{'link field'}} = array(
        'url' => $node->{'link url'},
        'title' => $node->{'link title'},
      );
    }
  }

  /**
   * Verify the href of a link.
   *
   * @Given /^the link "([^"]*)" in the "([^"]*)" region should go to "([^"]*)"$/
   */
  public function theLinkInTheRegionShouldGoTo($link, $region, $href) {
    $this->assertLinkVisible($link);
    $regionObj = $this->getRegion($region);

    $link_item = $regionObj->findLink($link);

    if (empty($link_item)) {
      throw new \Exception(sprintf('The link "%s" was not found in the region "%s" on the page %s', $link, $region, $this->getSession()->getCurrentUrl()));
    }

    if ($link_item->getAttribute('href') != $href) {
      throw new \Exception(sprintf("The link '%s' does not lead to %s", $link, $href));
    }
  }

  /**
   * Verify that a link will open in a new winodw (it has a target of _blank).
   *
   * @Given /^the link "([^"]*)" should open in a new window$/
   */
  public function theLinkShouldOpenInANewWindow($link) {
    $this->assertLinkVisible($link);
    $link_item = $this->getSession()->getPage()->findLink($link);

    if (NULL === $link_item->getAttribute('target') || $link_item->getAttribute('target') != '_blank') {
      throw new \Exception(sprintf("The link '%s' does not open in a new window", $link));
    }
  }

  /**
   * Disable Chosen, if installed.
   *
   * @BeforeScenario
   */
  public function disableChosen() {
    $this->chosenJquerySelector = variable_get('chosen_jquery_selector');
    variable_set('chosen_jquery_selector', '');
  }


  /**
   * Re-enable Chosen, if it was installed.
   *
   * @AfterScenario
   */
  public function enableChosen() {
    variable_set('chosen_jquery_selector', $this->chosenJquerySelector);
  }

  /**
   * @Given /^I create the following "([^"]*)" field collections$/
   */
  public function iCreateTheFollowingFieldCollections($label, TableNode $fcTable) {
    $page = $this->getSession()->getPage();

    // Assumes field collections will be in a sortable table.
    $table_xpath = 'table[contains(@class,"field-multiple-table")][contains(.,"' . $label. '")]';
    $field_collection_region = $page->find('xpath', '//div[contains(@class,"field-type-field-collection")]');
    $field_collection_table = $page->find('xpath', '//' . $table_xpath);
    $row = 1;

    foreach ($fcTable->getHash() as $fcRow) {
      $this_row = $field_collection_table->find('xpath', '//tbody/tr[' . $row . ']');

      if (!$this_row) {
        throw new \Exception("Could not find table row $row");
      }

      // Little hack to make sure wysiwyg will be filled.
      $this_is_wysiwyg = $this_row->findLink('Switch to plain text editor');
      if ($this_is_wysiwyg->isVisible()) {
        $this_is_wysiwyg->click();
      }
      foreach ($fcRow as $key => $value) {
        $this_row->fillField($key, $value);
      }

      $field_collection_region->findButton('Add another item')->click();
      $this->iWaitForAjaxToFinish();

      $row++;
    }
  }


  /**
   * @Given /^the "([^"]*)" button should be available on all content types but the following:$/
   */
  public function theButtonShouldBeAvailableOnAllContentTypesButTheFollowing($button, TableNode $exceptions) {
    $content_types = node_type_get_types();
    $skip_content_types = array();

    foreach ($exceptions->getHash() as $exception) {
      $skip_content_types[] = $exception['Content type'];
    }

    foreach($content_types as $machine_name => $bundle) {
      $type_url_str = str_replace('_', '-', $machine_name);
      $this->assertAtPath("/node/add/$type_url_str");

      if ($this->getSession()->getStatusCode() == 200) {
        $submit = $this->getSession()->getPage()->findButton($button);
        $button_found = !empty($submit);
        $button_expected = !in_array($bundle->name, $skip_content_types);

        if ($button_found && !$button_expected) {
          throw new \Exception(sprintf("Button '%s' found at %s", $button, $this->getSession()->getCurrentUrl()));
        }
        elseif (!$button_found && $button_expected) {
          throw new \Exception(sprintf("Button '%s' not found at %s", $button, $this->getSession()->getCurrentUrl()));
        }
      }
      else {
        throw new \Exception(sprintf("Page %s not accessible", $this->getSession()->getCurrentUrl()));
      }
    }
  }

  /**
  * @Given /^I drag the image atom "([^"]*)" to "([^"]*)"$/
  */
  public function iDragTheImageAtomTo($path, $upload_field) {
    // Make a new scald with $file.
    if ($this->getMinkParameter('files_path')) {
      $fullPath = rtrim(realpath($this->getMinkParameter('files_path')), DIRECTORY_SEPARATOR).DIRECTORY_SEPARATOR.$path;
      if (!is_file($fullPath)) {
        throw new \Exception(sprintf("Could not find file at %s", $fullPath));
      }
    }

    $file = file_save_data(file_get_contents($fullPath), 'public://' . $path);

    if (!$file) {
      throw new \Exception(sprintf("Could not make file from path %s", $fullPath));
    }

    $atom = new ScaldAtom('image', 'scald_image');
    $atom->title = $file->filename;
    $atom->base_id = $file->fid;
    $atom->scald_thumbnail[LANGUAGE_NONE][0] = (array) $file;
    $atom->save();

    if (!isset($atom->sid)) {
      throw new \Exception(sprintf("Could not make an atom from %s", $path));
    }

    // Put that scald id in $upload_field.
    $this->getSession()->getPage()->fillField($upload_field, $atom->sid);
  }

  /**
   * @AfterStep
   */
  public function takeScreenshotAfterFailedStep($event)
  {
    if ($event->getResult() == 4) {
      if ($this->getSession()->getDriver() instanceof
        \Behat\Mink\Driver\Selenium2Driver) {
        $stepText = $event->getStep()->getText();
        $fileTitle = preg_replace("#[^a-zA-Z0-9\._-]#", '', $stepText);
        $fileName = sys_get_temp_dir() . DIRECTORY_SEPARATOR . $fileTitle . '.png';
        $screenshot = $this->getSession()->getDriver()->getScreenshot();
        file_put_contents($fileName, $screenshot);
        print "Screenshot for '{$stepText}' placed in {$fileName}\n";
      }
    }
  }
}
