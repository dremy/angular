Feature: TFA Article
  As an author,
  I want to create an article
  So that a site visitor can read about a topic from Teach for America

  @api @tfa @tfa-content @tfa-articles
  Scenario: Create an article node and view it
    Given I am logged in as a user with the "system administrator" role
    When I visit "/node/add/article"
    Then I should see the heading "Create Article"
    And I fill in the following:
      | Title       | A Typical Article Page |
      | Body        | Aliquam placerat mauris sed pharetra eleifend. |
    And I attach the file "placeholder.png" to "files[field_attachment_und_0]"
    When I press "Save"
    Then I should see "A Typical Article Page"
    Then I should see "Aliquam placerat mauris sed pharetra eleifend."

