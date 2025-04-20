require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @seafarer = User.new(
      account_type: 'seafarer',
      email: 'seafarer@example.com',
      password: 'password123',
      first_name: 'John',
      last_name: 'Doe',
      phone_number: '1234567890',
      ic_number: 'IC123456',
      seafarer_id: 'SEA123456',
      street: '123 Main St',
      postcode: '12345',
      state: 'State',
      country: 'Country'
    )

    @agent = User.new(
      account_type: 'agent',
      email: 'agent@example.com',
      password: 'password123',
      first_name: 'Jane',
      last_name: 'Smith',
      phone_number: '1234567890',
      ic_number: 'IC789012',
      company_registration_number: 'COMP123456',
      street: '456 Agent St',
      postcode: '67890',
      state: 'State',
      country: 'Country'
    )
  end

  test "should be valid with valid attributes" do
    assert @seafarer.valid?
    assert @agent.valid?
  end

  test "should require account_type" do
    @seafarer.account_type = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:account_type], "can't be blank"
  end

  test "seafarer should require seafarer_id" do
    @seafarer.seafarer_id = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:seafarer_id], "can't be blank"
  end

  test "agent should require company_registration_number" do
    @agent.company_registration_number = nil
    assert_not @agent.valid?
    assert_includes @agent.errors[:company_registration_number], "can't be blank"
  end

  test "agent should require unique company_registration_number" do
    @agent.save!
    duplicate_agent = @agent.dup
    duplicate_agent.email = 'different@example.com'
    duplicate_agent.ic_number = 'IC999999'
    assert_not duplicate_agent.valid?
    assert_includes duplicate_agent.errors[:company_registration_number], "has already been taken"
  end

  test "agent should require address fields" do
    @agent.street = nil
    @agent.postcode = nil
    @agent.state = nil
    @agent.country = nil
    assert_not @agent.valid?
    assert_includes @agent.errors[:street], "can't be blank"
    assert_includes @agent.errors[:postcode], "can't be blank"
    assert_includes @agent.errors[:state], "can't be blank"
    assert_includes @agent.errors[:country], "can't be blank"
  end

  test "should require email" do
    @seafarer.email = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    @seafarer.save!
    duplicate_seafarer = @seafarer.dup
    assert_not duplicate_seafarer.valid?
    assert_includes duplicate_seafarer.errors[:email], "has already been taken"
  end

  test "should require password" do
    @seafarer.password = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:password], "can't be blank"
  end

  test "should require first_name" do
    @seafarer.first_name = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:first_name], "can't be blank"
  end

  test "should require last_name" do
    @seafarer.last_name = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:last_name], "can't be blank"
  end

  test "should require phone_number" do
    @seafarer.phone_number = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:phone_number], "can't be blank"
  end

  test "should require ic_number" do
    @seafarer.ic_number = nil
    assert_not @seafarer.valid?
    assert_includes @seafarer.errors[:ic_number], "can't be blank"
  end

  test "should require unique ic_number" do
    @seafarer.save!
    duplicate_seafarer = @seafarer.dup
    duplicate_seafarer.email = 'different@example.com'
    assert_not duplicate_seafarer.valid?
    assert_includes duplicate_seafarer.errors[:ic_number], "has already been taken"
  end

  test "should require unique seafarer_id for seafarer accounts" do
    @seafarer.save!
    duplicate_seafarer = @seafarer.dup
    duplicate_seafarer.email = 'different@example.com'
    duplicate_seafarer.ic_number = 'IC789012'
    assert_not duplicate_seafarer.valid?
    assert_includes duplicate_seafarer.errors[:seafarer_id], "has already been taken"
  end
end 