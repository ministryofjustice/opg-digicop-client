Feature: cases

  Scenario: upload CSV
    Given I am logged in as behat user
    When I go to "/upload-csv"
    When I attach the file "behat-cases.csv" to "csv_upload_form_file"
    And I click on "submit"
    Then the form should be valid
    And I should see the "order-93559316-PF" region
    And I should see the "order-93559316-HW" region
    Then the response status code should be 200


  Scenario: PA order: set assets, subtype, appointment type
    Given I am logged in as behat user
    When I follow "order-93559316-PF"
    # check form validation
    When I fill in the following:
      | order_form_hasAssetsAboveThreshold |  |
      | order_form_subType                 |  |
      | order_form_appointmentType         |  |
    And I press "order_form_submit"
    Then the following fields should have an error:
      | order_form_hasAssetsAboveThreshold |
      | order_form_subType                 |
      | order_form_appointmentType         |
    # fill form in with valid data
    When I fill in the following:
      | order_form_hasAssetsAboveThreshold | no          |
      | order_form_subType                 | REPLACEMENT_OF_DISCHARGED_DEPUTY  |
      | order_form_appointmentType         | JOINT_AND_SEVERAL          |
    And I press "order_form_submit"
    Then the response status code should be 200
    And each text should be present in the corresponding region:
      | No                               | has-assets    |
      | Replacement of discharged deputy | order-subtype |
      | Joint and several                | app-type      |
    And the order should be unservable

  Scenario: HW order: set subtype, appointment type
    Given I am logged in as behat user
    When I follow "order-93559316-HW"
    # check form validation
    When I fill in the following:
      | order_form_subType                 |  |
      | order_form_appointmentType         |  |
    And I press "order_form_submit"
    Then the following fields should have an error:
      | order_form_subType                 |
      | order_form_appointmentType         |
    # fill form in with valid data
    When I fill in the following:
      | order_form_subType         | INTERIM_ORDER |
      | order_form_appointmentType | SOLE          |
    And I press "order_form_submit"
    Then the response status code should be 200
    And I should not see the "has-assets" region
    And each text should be present in the corresponding region:
      | Interim order | order-subtype |
      | Sole          | app-type      |
    And the order should be unservable

  Scenario: test search
    Given I am logged in as behat user
    # fake q
    When I fill in "search" with "NOT EXISTING"
    And I press "search_submit"
    Then I should not see the "order-93559316-PF" region
    And I should not see the "order-93559316-HW" region
    # real search
    When I fill in "q" with "93559316"
    And I press "search_submit"
    # served tab has no results
    And I click on "served-tab"
    Then I should not see the "order-93559316-PF" region
    And I should not see the "order-93559316-HW" region
    # pending tab has results
    When I click on "pending-tab"
    Then I should see the "order-93559316-PF" region
    And I should see the "order-93559316-HW" region

