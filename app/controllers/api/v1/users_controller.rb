module Api
  module V1
    class UsersController < BaseController
      include Paginatable
      include Cacheable

      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      # Menampilkan daftar user dengan pagination dan cache
      def index
        users_scope = User.order(created_at: :desc)
        paginated_users = users_scope.page(current_page).per(per_page)

        cache_key = [
          'users/index',
          "updated-#{users_scope.maximum(:updated_at)&.to_i || 0}",
          "page-#{current_page}",
          "per_page-#{per_page}"
        ].join('/')

        serialized_users = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          ActiveModelSerializers::SerializableResource.new(
            paginated_users,
            each_serializer: UserSerializer
          ).as_json
        end

        render_success(
          serialized_users,
          meta: pagination_meta(paginated_users)
        )
      end

      # GET /api/v1/users/:id
      def show
        cache_key = "users/show/#{@user.id}/updated-#{@user.updated_at.to_i}"
        user_data = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          UserSerializer.new(@user).as_json
        end
        render_success(user_data)
      end

      # POST /api/v1/users
      def create
        user = User.create!(user_params)
        invalidate_cache("users", skip_show: true)
        render_success(user, status: :created, serializer: UserSerializer)
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        @user.update!(user_params)
        invalidate_cache("users", id: @user.id)
        render_success(@user, serializer: UserSerializer)
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        invalidate_cache("users", id: @user.id)
        head :no_content
      end

      private

      # hooks rails
      # Mencari user berdasarkan ID dari params[:id]
      # @return [User]
      def set_user
        @user = User.find(params[:id])
      end


      # Rails strong parameters. Tujuannya untuk whitelist data yang boleh diterima dari request params[:user].
      def user_params
        params.require(:user).permit(:name, :email, :phone)
      end


      # Menampilkan response JSON sukses
      # @param data [Object, nil] Data untuk ditampilkan (bisa nil)
      # @param status [Symbol] HTTP status code
      # @param options [Hash] Tambahan opsi render (misal serializer)
      def render_success(data, status: :ok, meta: nil, serializer: nil, each_serializer: nil)
        serialized = ActiveModelSerializers::SerializableResource.new(
          data,
          serializer: serializer,
          each_serializer: each_serializer
        ).as_json

        response = { data: serialized }
        response[:meta] = meta if meta.present?

        render json: response, status: status
      end


    end
  end
end
