Feature: Setup API
    As a system administrator
    I want to seed roles and permissions
    So that the system has the required authorization data

    Background:
        Given the API is running

    Scenario: Admin can create predefined roles
        When I call the endpoint to create predefined roles
        Then the response status should be 200
        And the response should indicate roles were created

    Scenario: Admin can create predefined permissions
        When I call the endpoint to create predefined permissions
        Then the response status should be 200
        And the response should indicate permissions were created

    Scenario: Admin can map roles to permissions
        Given predefined roles exist
        And predefined permissions exist
        When I call the endpoint to map roles to permissions
        Then the response status should be 200
        And the response should indicate mappings were created

