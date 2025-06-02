RSpec.describe "Users API", type: :request do

  # Test GET all users
  describe "GET /api/v1/users" do
    it "returns http success" do
      get "/api/v1/users"
      expect(response).to have_http_status(:ok)
    end
  end

  # Test POST create user successfully
  describe "POST /api/v1/users" do
    it "creates a user" do
      post "/api/v1/users", params: {
        user: {
          name: "New User",
          email: "newuser@mail.com",
          phone: "0812345678"
        }
      }
      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("New User")
    end
  end

  # Test GET user by ID
  describe "GET /api/v1/users/:id" do
    it "returns a user by ID" do
      user = User.create!(name: "Find Me", email: "find@mail.com", phone: "081000")
      get "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(user.id)
      expect(json["email"]).to eq("find@mail.com")
    end
  end

  # Test POST create user with invalid data
  describe "POST /api/v1/users with invalid data" do
    it "returns 422 Unprocessable Entity" do
      post "/api/v1/users", params: { user: { name: "", email: "", phone: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Name can't be blank")
    end
  end

  # Test DELETE user with full check
  describe "DELETE /api/v1/users/:id" do
    it "deletes the user" do
      user = User.create!(name: "To Delete", email: "delete@mail.com", phone: "08000000")
      delete "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(:no_content).or have_http_status(:ok)
      expect(User.find_by(id: user.id)).to be_nil
    end
  end

  # Test GET user by invalid ID
  describe "GET /api/v1/users/:id with invalid ID" do
    it "returns 404 not found" do
      get "/api/v1/users/999999"
      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Record not found")
    end
  end

  # Test PATCH update user with invalid data
  describe "PATCH /api/v1/users/:id with invalid data" do
    it "returns 422" do
      user = User.create!(name: "Old", email: "old@mail.com", phone: "08")
      patch "/api/v1/users/#{user.id}", params: { user: { email: "" } }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Email can't be blank")
    end
  end

  # Test PATCH update user with success data
  describe "PATCH /api/v1/users/:id" do
    it "updates a user successfully" do
      user = User.create!(name: "Old", email: "old@mail.com", phone: "081")
      patch "/api/v1/users/#{user.id}", params: {
        user: { name: "Updated Name" }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Updated Name")
    end
  end

  # Test DELETE user returns 204 No Content
  describe "DELETE /api/v1/users/:id" do
    it "returns 204 No Content" do
      user = User.create!(name: "To Del", email: "del@mail.com", phone: "081")
      delete "/api/v1/users/#{user.id}"
      expect(response).to have_http_status(:no_content)
    end
  end

end
