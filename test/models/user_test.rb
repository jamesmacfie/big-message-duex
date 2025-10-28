require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123"
    )
  end

  # Validations
  test "valid user" do
    assert @user.valid?
  end

  test "email is required" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "email must be unique" do
    @user.save!
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "password is required" do
    user = User.new(email: "new@example.com")
    assert_not user.valid?
  end

  test "password must be at least 8 characters" do
    @user.password = "short"
    assert_not @user.valid?
  end

  # Associations
  test "user has one person" do
    assert_respond_to @user, :person
  end

  # Authentication
  test "user can authenticate with correct password" do
    @user.save!
    assert @user.authenticate("password123")
  end

  test "user cannot authenticate with incorrect password" do
    @user.save!
    assert_not @user.authenticate("wrongpassword")
  end
end
