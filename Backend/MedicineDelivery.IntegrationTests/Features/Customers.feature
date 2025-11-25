Feature: Customer API
    As a user or administrator
    I want to manage customer information
    So that I can register, view, update, and delete customer records

    Background:
        Given the API is running
        And predefined roles exist
        And predefined permissions exist
        And I call the endpoint to map roles to permissions

    Scenario: Customer can register anonymously
        Given I have customer registration data with mobile number "8888888888"
        When I register a new customer
        Then the response status should be 201
        And the response should contain customer information

    Scenario: Customer can view their own profile
        Given a customer exists with mobile number "7777777777" and password "Test@123"
        And I am logged in as the customer with mobile number "7777777777" and password "Test@123"
        When I request my profile
        Then the response status should be 200
        And the response should contain my customer information

    Scenario: Admin can get all customers
        Given a customer exists with mobile number "6666666666" and password "Test@123"
        And an admin user exists with mobile number "5555555555" and password "Admin@123"
        And I am logged in as the admin user
        When I request all customers
        Then the response status should be 200
        And the response should contain a list of customers

    Scenario: Admin can get customer by ID
        Given a customer exists with mobile number "4444444444" and password "Test@123"
        And I have the customer ID
        And an admin user exists with mobile number "3333333333" and password "Admin@123"
        And I am logged in as the admin user
        When I request the customer by ID
        Then the response status should be 200
        And the response should contain the customer information

    Scenario: Admin can get customer by mobile number
        Given a customer exists with mobile number "2222222222" and password "Test@123"
        And an admin user exists with mobile number "1111111111" and password "Admin@123"
        And I am logged in as the admin user
        When I request the customer by mobile number "2222222222"
        Then the response status should be 200
        And the response should contain the customer information

    Scenario: Admin can create a customer
        Given an admin user exists with mobile number "9999999998" and password "Admin@123"
        And I am logged in as the admin user
        And I have customer creation data with mobile number "9999999997"
        When I create a new customer
        Then the response status should be 201
        And the response should contain the created customer information

    Scenario: Customer can update their own profile
        Given a customer exists with mobile number "9999999996" and password "Test@123"
        And I am logged in as the customer with mobile number "9999999996" and password "Test@123"
        And I have customer update data
        When I update my customer profile
        Then the response status should be 200
        And the response should contain the updated customer information

    Scenario: Admin can update any customer
        Given a customer exists with mobile number "9999999995" and password "Test@123"
        And I have the customer ID
        And an admin user exists with mobile number "9999999994" and password "Admin@123"
        And I am logged in as the admin user
        And I have customer update data
        When I update the customer by ID
        Then the response status should be 200
        And the response should contain the updated customer information

    Scenario: Admin can delete a customer
        Given a customer exists with mobile number "9999999993" and password "Test@123"
        And I have the customer ID
        And an admin user exists with mobile number "9999999992" and password "Admin@123"
        And I am logged in as the admin user
        When I delete the customer by ID
        Then the response status should be 204

    Scenario: Unauthorized user cannot access customer endpoints
        When I request all customers without authentication
        Then the response status should be 401

    Scenario: Customer cannot access other customer's profile
        Given a customer exists with mobile number "9999999991" and password "Test@123"
        And another customer exists with mobile number "9999999990" and password "Test@123"
        And I have the first customer ID
        And I am logged in as the second customer with mobile number "9999999990" and password "Test@123"
        When I request the first customer by ID
        Then the response status should be 403

