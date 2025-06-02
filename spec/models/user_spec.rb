require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with name, email, and phone" do
    user = User.new(name: "Damar", email: "damar@mail.com", phone: "0812345678")
    expect(user).to be_valid
  end

  it "is invalid without name" do
    user = User.new(email: "damar@mail.com", phone: "0812345678")
    expect(user).not_to be_valid
  end

  it "is invalid with duplicate email" do
    User.create!(name: "User1", email: "dup@mail.com", phone: "081234")
    user = User.new(name: "User2", email: "dup@mail.com", phone: "082345")
    expect(user).not_to be_valid
  end

end