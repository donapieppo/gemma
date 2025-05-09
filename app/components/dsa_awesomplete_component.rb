# frozen_string_literal: true

# FIXME maybe singleton in case of nultiple user because of cache
class DsaAwesompleteComponent < ViewComponent::Base
  @@organization_users_cache = {}
  @@organization_users_cache_start = 0

  def initialize(current_organization_id, form, what, hint: "")
    @form = form
    @what = what

    if (Time.now - @@organization_users_cache_start) > 300
      @@organization_users_cache = {}
      @@organization_users_cache_start = Time.now
    end
    if !@@organization_users_cache.key?(current_organization_id)
      @@organization_users_cache[current_organization_id] ||= User.all_in_cache(current_organization_id).map { |x| "#{x} (#{x.upn})" }.to_json
    end

    @cache_users_json = @@organization_users_cache[current_organization_id]
  end
end
