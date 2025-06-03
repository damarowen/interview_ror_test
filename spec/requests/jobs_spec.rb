RSpec.describe "Jobs API", type: :request do
  # Test GET all jobs
  describe "GET /api/v1/jobs" do
    it "returns http success" do
      get "/api/v1/jobs"
      expect(response).to have_http_status(:ok)
    end
  end

  # Test PATCH update job status
  describe "PATCH /api/v1/jobs/:id" do
    it "updates a job status" do
      user = User.create!(name: "Damar", email: "damar@mail.com", phone: "0812345678")
      job = Job.create!(title: "Dev", description: "Code stuff", status: "pending", user: user)

      patch "/api/v1/jobs/#{job.id}", params: {
        job: {
          status: "completed"
        }
      }

      expect(response).to have_http_status(:ok).or have_http_status(:success)
      expect(Job.find(job.id).status).to eq("completed")
    end
  end

  # Test POST job with invalid data
  describe "POST /api/v1/jobs with invalid data" do
    it "returns 422 Unprocessable Entity" do
      user = User.create!(name: "Owner", email: "owner@mail.com", phone: "081234")
      post "/api/v1/jobs", params: {
        job: { title: "", description: "", status: "", user_id: user.id }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Title can't be blank")
    end
  end

  # Test DELETE job successfully
  describe "DELETE /api/v1/jobs/:id" do
    it "deletes the job" do
      user = User.create!(name: "Job Owner", email: "jobowner@mail.com", phone: "081222")
      job = Job.create!(title: "Delete Me", description: "To be deleted", status: "pending", user: user)
      delete "/api/v1/jobs/#{job.id}"

      expect(response).to have_http_status(:no_content).or have_http_status(:ok)
      expect(Job.find_by(id: job.id)).to be_nil
    end
  end

  # Test POST job with missing user_id
  describe "POST /api/v1/jobs with invalid user_id" do
    it "returns 422 unprocessable entity" do
      post "/api/v1/jobs", params: {
        job: {
          title: "Test",
          description: "Test Desc",
          status: "pending",
          user_id: nil
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("User must exist")
    end
  end

  # Test GET a single job by ID
  describe "GET /api/v1/jobs/:id" do
    it "returns a job with the given ID" do
      user = User.create!(name: "Single Jobber", email: "single@mail.com", phone: "081000")
      job = Job.create!(title: "Single Job", description: "A specific job", status: "pending", user: user)

      get "/api/v1/jobs/#{job.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      data = json["data"]
      expect(data["id"]).to eq(job.id)
    end
  end

  # Test GET /api/v1/jobs/:id with invalid ID
  describe "GET /api/v1/jobs/:id with invalid ID" do
    it "returns 404 not found" do
      get "/api/v1/jobs/999999"

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Record not found")
    end
  end

  # Test POST /api/v1/jobs with valid data
  describe "POST /api/v1/jobs" do
    it "creates a job" do
      user = User.create!(name: "Valid Poster", email: "poster@mail.com", phone: "08999")
      post "/api/v1/jobs", params: {
        job: {
          title: "New Job",
          description: "Great opportunity",
          status: "pending",
          user_id: user.id
        }
      }

      expect(response).to have_http_status(:created).or have_http_status(:ok)
      json = JSON.parse(response.body)
      data = json["data"]
      expect(data["title"]).to eq("New Job")
    end
  end

  # Test POST /jobs/:id with invalid data to trigger RecordInvalid
  describe "POST /api/v1/jobs with invalid data (trigger RecordInvalid)" do
    it "returns 422 via BaseController rescue_from" do
      user = User.create!(name: "Invalid", email: "invalid@mail.com", phone: "0899")

      post "/api/v1/jobs", params: {
        job: {
          title: "",
          description: "",
          status: "",
          user_id: user.id
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Title can't be blank")
    end
  end

  # Test PATCH /jobs/:id with invalid data to trigger RecordInvalid
  describe "PATCH /api/v1/jobs/:id with invalid data" do
    it "returns 422 from BaseController" do
      user = User.create!(name: "Patch", email: "patch@mail.com", phone: "0877")
      job = Job.create!(title: "PatchMe", description: "desc", status: "pending", user: user)

      patch "/api/v1/jobs/#{job.id}", params: {
        job: {
          title: "", # invalid
          description: "",
          status: ""
        }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Title can't be blank")
    end
  end

  # Test GET /api/v1/jobs?user_id=xx
  describe "GET /api/v1/jobs with user_id param" do
    it "returns only jobs for the given user" do
      user1 = User.create!(name: "User One", email: "one@mail.com", phone: "081")
      user2 = User.create!(name: "User Two", email: "two@mail.com", phone: "082")
      Job.create!(title: "A", description: "A1", status: "pending", user: user1)
      Job.create!(title: "B", description: "B1", status: "pending", user: user2)

      get "/api/v1/jobs", params: { user_id: user1.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      data = json["data"]
      expect(data.length).to eq(1)
    end

    it "returns all jobs when user_id is invalid (string)" do
      user = User.create!(name: "Invalid User", email: "invalid1@mail.com", phone: "081001")
      Job.create!(title: "Invalid Job", description: "desc", status: "pending", user: user)

      get "/api/v1/jobs", params: { user_id: "abc" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]).not_to be_empty
    end
  end
end
