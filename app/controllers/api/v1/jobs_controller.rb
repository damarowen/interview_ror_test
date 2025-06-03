module Api
  module V1
    class JobsController < BaseController
      include Paginatable
      include Cacheable

      before_action :set_job, only: [:show, :update, :destroy]

      # GET /api/v1/jobs
      # Mengambil daftar job dengan opsi filter dan pagination.
      # @option params [Integer] :user_id (optional) Filter berdasarkan user ID
      # @option params [Integer] :page (optional) Nomor halaman, default: 1
      # @option params [Integer] :per_page (optional) Jumlah item per halaman, default: 10
      # @return [JSON] Daftar job yang sudah dipaginasi dan difilter
      def index
        jobs_scope     = filter_jobs.order(created_at: :desc)
        paginated_jobs = jobs_scope.page(current_page).per(per_page)

        cache_key = ActiveSupport::Cache.expand_cache_key([
          'jobs/index',
          "user-#{filter_params || 'all'}",
          "updated-#{jobs_scope.maximum(:updated_at)&.to_i || 0}",
          "page-#{current_page}",
          "per_page-#{per_page}"])

        serialized_jobs = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          ActiveModelSerializers::SerializableResource.new(
            paginated_jobs,
            each_serializer: JobSerializer
          ).as_json
        end

        render_success(
          serialized_jobs,
          meta: pagination_meta(paginated_jobs)
        )
      end

      # GET /api/v1/jobs/:id
      # Menampilkan detail dari sebuah job berdasarkan ID
      # @return [JSON] Job detail
      def show
        cache_key = "jobs/show/#{@job.id}/updated-#{@job.updated_at.to_i}"
        job_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          JobSerializer.new(@job).as_json
        end
        render_success(job_data)
      end

      # POST /api/v1/jobs
      # Membuat job baru
      # @param [Hash] job Atribut job (title, description, status, user_id)
      # @return [JSON] Job yang berhasil dibuat
      def create
        new_job = Job.create!(job_params)
        invalidate_cache("jobs", skip_show: true)
        render_success(new_job, status: :created, serializer: JobSerializer)
      end

      # PATCH/PUT /api/v1/jobs/:id
      # Mengupdate atribut job tertentu
      # @param [Hash] job Atribut job yang ingin diubah
      # @return [JSON] Job yang berhasil diperbarui
      def update
        @job.update!(job_params)
        invalidate_cache("jobs", id: @job.id) # invalidate index + show cache per ID
        render_success(@job, serializer: JobSerializer)
      end

      # DELETE /api/v1/jobs/:id
      # Menghapus sebuah job berdasarkan ID
      # @return [204 No Content]
      def destroy
        @job.destroy!
        invalidate_cache("jobs", id: @job.id) # invalidate index + show cache per ID
        head :no_content
      end

      private

      # hooks rails
      # Mencari job berdasarkan ID dari params[:id]
      # @return [Job]
      def set_job
        @job = Job.find(params[:id])
      end

      # Rails strong parameters. Tujuannya untuk whitelist data yang boleh diterima dari request params[:job].
      # @return [ActionController::Parameters] Parameter yang diizinkan
      def job_params
        params.require(:job).permit(:title, :description, :status, :user_id)
      end

      # Filter jobs jika user_id tersedia
      # @return [ActiveRecord::Relation]
      def filter_jobs
        filter_params ? Job.where(user_id: filter_params) : Job.all
      end

      # Mengambil parameter user_id dari query string dan mengkonversinya menjadi Integer.
      # Jika parameter user_id tidak valid (bukan angka), method ini akan mengembalikan nil.
      # @return [Integer, nil] Nilai user_id dalam bentuk integer, atau nil jika tidak valid.
      def filter_params
        Integer(params[:user_id]) if params[:user_id].present?
      rescue ArgumentError, TypeError
        nil
      end

    end
  end
end