Stand-alone installation 
========================

A stand-alone installation is recommended when you want your tests and testing
environment to be portable, from local development to CI server, to client
infrastructure. It also make documentation consistent and reliable.

1. Create a folder for your BDD tests::

    mkdir projectfolder cd projectfolder
    
  All the commands that follow are written to install from the root of your
  project folder.

2. Install Composer, a php package manager::

     curl -s https://getcomposer.org/installer | php

3. Create a composer.json file to tell Composer what to install.  To do that,
   paste the following code into your editor and save as composer.json. The 
   Drupal Extension requires Behat, Mink, and the Mink Extension. The will all 
   be set up because they're dependencies of the Drupal Extension, so you don't 
   have to specify them directly in the composer.json file:

  .. literalinclude:: _static/snippets/composer.json 
     :language: javascript 
     :linenos:

4. Run the following command to install the Drupal Extension and all those
   dependencies. This takes a while before you start to see output::

    php composer.phar install

5. Configure your testing environment by creating a file called behat.yml with
   the following. Be sure that you point the base_url at the web site YOU intend
   to test. Do not include a trailing slash:

  .. literalinclude:: _static/snippets/behat-1.yml 
     :language: yaml 
     :linenos:

6. Initialze behat. This creates the features folder with some basic things to
   get you started, including your own FeatureContext.php file:: 

    bin/behat --init

7. Edit features/bootstrap/FeatureContext.php so that it matches the following:

  .. literalinclude:: _static/snippets/FeatureContext.php.inc
     :language: php 
     :linenos: 
     :emphasize-lines: 20-21

  This will make your FeatureContext.php aware of both the Drupal Extension and
  the Mink Extension, so you'll be able to take advantage of their drivers and
  step definitions and add your own custom step definitions as well.

8. To ensure everything is set up appropriately, type::

    bin/behat -dl
  
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
