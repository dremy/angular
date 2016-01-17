System-wide installation 
========================

A system-wide installation allows you to maintain a single copy of the testing
toolset and use it for multiple test environments. Configuuration is slightly
more complex than the stand-alone installation but many people prefer the
flexibility and ease-of-maintenance this setup provides.

Overview 
--------

To install the Drupal Extension globally:

#. Install Composer 
#. Install the Drupal Extension in `/opt/drupalextension` 
#. Create an alias to the behat binary in `/usr/local/bin` 
#. Create your test folder

Install Composer 
----------------

Composer is a PHP dependency manager that will make sure all the pieces you
need get installed. `Full directions for global installation
<http://getcomposer.org/doc/00-intro.md#globally>`_ and more information can be
found on the `Composer website <http://getcomposer.org/>`_.::

  curl -sS https://getcomposer.org/installer | 
  php mv composer.phar /usr/local/bin/composer

Install the Drupal Extension 
----------------------------

#. Make a directory in /opt (or wherever you choose) for the Drupal Extension::

    cd /opt/ 
    sudo mkdir drupalextension
    cd drupalextension/

2. Create a file called `composer.json` and include the following:
  
  .. literalinclude:: _static/snippets/composer.json 
     :language: javascript 
     :linenos:

3. Run the install command::

    sudo composer install

  It will be a bit before you start seeing any output. It will also suggest
  that you install additional tools, but they're not normally needed so you can
  safely ignore that message.

4. Test that your install worked by typing the following::

    bin/behat --help

   If you were successful, you'll see the help output.

5. Make the binary available system-wide::

    ln -s /opt/drupalextension/bin/behat /usr/local/bin/behat

Set up tests 
------------ 

1. Create the directory that will hold your tests. There is no technical
   reason this needs to be inside the Drupal directory at all. It is best to
   keep them in the same version control repository so that the tests match the 
   version of the site they are written for.

  One clear pattern is to keep them in the sites folder as follows:

  Single site: `sites/default/behat-tests`
  
  Multisite or named single site: `/sites/my.domain.com/behat-tests`

2. Wherever you make your test folder, inside it create the behat.yml file:

  .. literalinclude:: _static/snippets/behat-1.yml 
     :language: yaml 
     :linenos:

3. Edit features/bootstrap/FeatureContext.php so that it matches the following:

  .. literalinclude:: _static/snippets/FeatureContext.php.inc
     :language: php 
     :linenos: 
     :emphasize-lines: 20-21

  This will make your FeatureContext.php aware of both the Drupal Extension and
  the Mink Extension, so you'll be able to take advantage of their drivers and
  step definitions and add your own custom step definitions here.

4. To ensure everything is set up appropriately, type::

    behat -dl

   You'll see a list of steps like the following, but longer, if you've
   installed everything successfully:


  .. code-block:: gherkin 
     :linenos:

      Given /^(?:that I|I) am at "(?P[^"]*)"$/
          - Visit a given path, and additionally check for HTTP response code
            200.
          # Drupal\DrupalExtension\Context\DrupalContext::iAmAt()

       When /^I visit "(?P[^"]*)"$/
          # Drupal\DrupalExtension\Context\DrupalContext::iVisit()

       When /^I click "(?P<link>[^"]*)"$/
          # Drupal\DrupalExtension\Context\DrupalContext::iClick()

      Given /^for "(?P<field>[^"]*)" I enter "(?P<value>[^"]*)"$/
          # Drupal\DrupalExtension\Context\DrupalContext::forIenter()

