# app/controllers/concerns/paginatable.rb

# Concern untuk menambahkan kemampuan pagination secara reusable di controller.
module Paginatable
  extend ActiveSupport::Concern

  # Jumlah default item per halaman
  DEFAULT_PER_PAGE = 10

  # Jumlah maksimum item per halaman untuk menghindari beban besar
  MAX_PER_PAGE = 100

  # Mengambil nomor halaman dari query param ?page=
  # @return [Integer] halaman saat ini (default: 1)
  def current_page
    params[:page].presence || 1
  end

  # Mengambil jumlah item per halaman dari query param ?per_page=
  # @return [Integer] jumlah item yang akan ditampilkan per halaman (default: 10, maksimum: 100)
  def per_page
    raw = params[:per_page].to_i
    raw = DEFAULT_PER_PAGE if raw <= 0
    [raw, MAX_PER_PAGE].min
  end

  # Menghasilkan metadata pagination dari hasil query Kaminari
  # @param collection [Kaminari::PaginatableArray or ActiveRecord::Relation]
  # @return [Hash] metadata pagination
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      total_pages:  collection.total_pages,
      total_count:  collection.total_count,
      per_page:     collection.limit_value
    }
  end
end
