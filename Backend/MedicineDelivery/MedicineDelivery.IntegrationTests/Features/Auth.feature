Feature: Authentication API
    As a user
    I want to authenticate and get a token
    So that I can access protected endpoints

    Background:
        Given the API is running

    Scenario: User can register a new account
        Given I have registration data with mobile number "9999999999" and password "Test@123"
        When I register a new user
        Then the response status should be 200
        And the response should contain user information

    Scenario: User can login with valid credentials
        Given a user exists with mobile number "9999999999" and password "Test@123"
        When I login with mobile number "9999999999" and password "Test@123"
        Then the response status should be 200
        And the response should contain a JWT token

    Scenario: User cannot login with invalid credentials
        When I login with mobile number "9999999999" and password "WrongPassword"
        Then the response status should be 401

