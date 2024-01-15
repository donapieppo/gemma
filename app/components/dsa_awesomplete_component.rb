# frozen_string_literal: true

# FIXME maybe singleton in case of nultiple user because of cache
class DsaAwesompleteComponent < ViewComponent::Base
  def initialize(current_organization_id, form, what, hint: "")
    @form = form
    @what = what
    @cache_users_json = User.all_in_cache(current_organization_id).map { |x| "#{x.to_s} (#{x.upn})" }.to_json
  end
end
