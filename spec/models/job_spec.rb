require 'rails_helper'


RSpec.describe Job, type: :model do
  let(:user) { User.create(name: "Damar", email: "damar@mail.com", phone: "0812345678") }

  it "is valid with title, description, and valid status" do
    job = Job.new(title: "Dev", description: "Coding", status: "pending", user: user)
    expect(job).to be_valid
  end

  it "is invalid with wrong status" do
    job = Job.new(title: "Dev", description: "Coding", status: "unknown", user: user)
    expect(job).not_to be_valid
  end

  it "is invalid without user" do
    job = Job.new(title: "Dev", description: "Coding", status: "pending")
    expect(job).not_to be_valid
  end
end