Feature: Sign up
  In order to use OpenHub
  As a new user
  I must be able to signup for OpenHub

  Scenario: Sign up for OpenHub
    Given I am on the OpenHub sign up page
    When I submit my sign up details
    Then I should see a verifications page
