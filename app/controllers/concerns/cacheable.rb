# app/controllers/concerns/cacheable.rb
module Cacheable
  extend ActiveSupport::Concern

  # Menghapus cache terkait job tertentu (dan index)
  def invalidate_cache(namespace, id: nil, skip_show: false)
    Rails.logger.info("[CACHE] Deleting #{namespace}/index/*")
    Rails.cache.delete_matched("#{namespace}/index/*")

    unless skip_show || id.nil?
      Rails.logger.info("[CACHE] Deleting #{namespace}/show/#{id}/*")
      Rails.cache.delete_matched("#{namespace}/show/#{id}/*")
    end
  end
end
