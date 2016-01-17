Drush Driver
============

Many tests require that a user logs into the site. With the blackbox driver,
all user creation and login would have to take place via the user interface,
which quickly becomes tedious and time consuming. You can use the Drush driver
to add users, reset passwords, and log in by following the steps below, again,
without having to write custom PHP. You can also do this with the Drupal API
driver. The main advantage of the Drush driver is that it can work when your
tests run on a different server than the site being tested.

Install Drush
-------------

See the `Drush project page <https://drupal.org/project/drush>`_ for
installation directions.

Create a Drush alias
--------------------

You'll need ssh-key access to a remote server to use Drush. If Drush and Drush
aliases are new to you, see the `Drush site <http://drush.ws/help>`_ for
`detailed examples <http://drush.ws/examples/example.aliases.drushrc.php>`_

The alias for our example looks like:

.. literalinclude:: _static/snippets/aliases.drushrc.php
   :language: php
   :linenos:
   

Enable the Drush driver in the behat.yml
----------------------------------------

.. literalinclude:: _static/snippets/behat-drush.yml
   :language: yaml
   :linenos:
   :emphasize-lines: 11-12

.. note:: Line 11 isn't strictly necessary for the Drush driver, which is the
          default for the API.

Calling the Drush driver
------------------------

Untagged tests use the blackbox driver. To invoke the Drush driver, tag the
scenario with @api

.. literalinclude:: _static/snippets/apitag.feature
   :language: gherkin
   :linenos:
   :emphasize-lines: 11 

If you try to run a test without that tag, it will fail. 

Example:

.. literalinclude:: _static/snippets/apitag.output
   :language: gherkin
   :linenos:
   :emphasize-lines: 8-10 
   :lines: 1-24

The Drush driver give you access to all the blackbox steps, plus those used in
each of the following examples:

.. literalinclude:: _static/snippets/drush.feature
   :language: gherkin
   :linenos:
   :lines: 1-24
