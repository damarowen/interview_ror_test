module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

      private

      def not_found
        render json: { error: "Record not found" }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end


      # Menampilkan response JSON sukses
      # @param data [Object, nil] Data untuk ditampilkan (bisa nil)
      # @param status [Symbol] HTTP status code
      # @param options [Hash] Tambahan opsi render (misal serializer)
      def render_success(data, status: :ok, meta: nil, serializer: nil, each_serializer: nil)
        serialized =
          if data.is_a?(Hash) || (data.is_a?(Array) && data.first.is_a?(Hash))
            data # Sudah diserialisasi
          else
            ActiveModelSerializers::SerializableResource.new(
              data,
              serializer: serializer,
              each_serializer: each_serializer
            ).as_json
          end

        response = { data: serialized }
        response[:meta] = meta if meta.present?

        render json: response, status: status
      end
    end
  end
end
