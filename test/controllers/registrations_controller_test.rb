require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_user_registration_path
    assert_response :success
  end

  test "should create seafarer account with valid attributes" do
    assert_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'seafarer',
          email: 'seafarer@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'John',
          last_name: 'Doe',
          phone_number: '1234567890',
          ic_number: 'IC123456',
          seafarer_id: 'SEA123456',
          street: '123 Main St',
          postcode: '12345',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_redirected_to root_path
    user = User.last
    assert_equal 'seafarer', user.account_type
    assert_equal 'SEA123456', user.seafarer_id
  end

  test "should create agent account with valid attributes" do
    assert_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'agent',
          email: 'agent@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'Jane',
          last_name: 'Smith',
          phone_number: '1234567890',
          ic_number: 'IC789012',
          company_registration_number: 'COMP123456',
          street: '456 Agent St',
          postcode: '67890',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_redirected_to root_path
    user = User.last
    assert_equal 'agent', user.account_type
    assert_equal 'COMP123456', user.company_registration_number
  end

  test "should not create seafarer account without seafarer_id" do
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'seafarer',
          email: 'seafarer@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'John',
          last_name: 'Doe',
          phone_number: '1234567890',
          ic_number: 'IC123456',
          street: '123 Main St',
          postcode: '12345',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Seafarer ID can't be blank"
  end

  test "should not create agent account without company_registration_number" do
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'agent',
          email: 'agent@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'Jane',
          last_name: 'Smith',
          phone_number: '1234567890',
          ic_number: 'IC789012',
          street: '456 Agent St',
          postcode: '67890',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Company registration number can't be blank"
  end

  test "should not create agent account without address fields" do
    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'agent',
          email: 'agent@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'Jane',
          last_name: 'Smith',
          phone_number: '1234567890',
          ic_number: 'IC789012',
          company_registration_number: 'COMP123456'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Street can't be blank"
    assert_includes response.body, "Postcode can't be blank"
    assert_includes response.body, "State can't be blank"
    assert_includes response.body, "Country can't be blank"
  end

  test "should not create account with duplicate email" do
    User.create!(
      account_type: 'seafarer',
      email: 'existing@example.com',
      password: 'password123',
      first_name: 'Existing',
      last_name: 'User',
      phone_number: '1234567890',
      ic_number: 'IC123456',
      seafarer_id: 'SEA123456',
      street: '123 Main St',
      postcode: '12345',
      state: 'State',
      country: 'Country'
    )

    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'seafarer',
          email: 'existing@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'John',
          last_name: 'Doe',
          phone_number: '1234567890',
          ic_number: 'IC789012',
          seafarer_id: 'SEA789012',
          street: '123 Main St',
          postcode: '12345',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Email has already been taken"
  end

  test "should not create account with duplicate company_registration_number" do
    User.create!(
      account_type: 'agent',
      email: 'existing@example.com',
      password: 'password123',
      first_name: 'Existing',
      last_name: 'User',
      phone_number: '1234567890',
      ic_number: 'IC123456',
      company_registration_number: 'COMP123456',
      street: '123 Main St',
      postcode: '12345',
      state: 'State',
      country: 'Country'
    )

    assert_no_difference('User.count') do
      post user_registration_path, params: {
        user: {
          account_type: 'agent',
          email: 'new@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          first_name: 'John',
          last_name: 'Doe',
          phone_number: '1234567890',
          ic_number: 'IC789012',
          company_registration_number: 'COMP123456',
          street: '456 Agent St',
          postcode: '67890',
          state: 'State',
          country: 'Country'
        }
      }
    end

    assert_response :unprocessable_entity
    assert_includes response.body, "Company registration number has already been taken"
  end
end 