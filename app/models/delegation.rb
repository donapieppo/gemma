class Delegation < ApplicationRecord
  belongs_to :organization
  belongs_to :delegator, class_name: "User"
  belongs_to :delegate, class_name: "User"
  belongs_to :department, optional: true
  belongs_to :destination, optional: true

  validate :validate_delegator,
    :validate_delegate

  def validate_delegator
    throw(:abort) unless @_delegator_upn # explicitly halt callbacks.
    begin
      user_delegator = User.syncronize(@_delegator_upn)
      Rails.logger.info user_delegator.inspect
      self.delegator_id = user_delegator.id
    rescue => e
      Rails.logger.info "#{e} while validating delegator: #{@_delegator_upn}"
      errors.add(:delegator, e.to_s)
      errors.add(:base, e.to_s)
    end
  end

  def validate_delegate
    throw(:abort) unless @_delegate_upn # explicitly halt callbacks.
    begin
      user_delegate = User.syncronize(@_delegate_upn)
      Rails.logger.info user_delegate.inspect
      self.delegate_id = user_delegate.id
    rescue => e
      Rails.logger.info "#{e} while validating delegate: #{@_delegate_upn}"
      errors.add(:delegate, e.to_s)
      errors.add(:base, e.to_s)
    end
  end

  def delegator_upn=(d)
    @_delegator_upn = (d =~ /(\w+\.\w+)/) ? "#{Regexp.last_match(1)}@unibo.it" : "wrong upn"
  end

  def delegator_upn
    delegator.upn if delegator_id
  end

  def delegate_upn=(d)
    @_delegate_upn = (d =~ /(\w+\.\w+)/) ? "#{Regexp.last_match(1)}@unibo.it" : "wrong upn"
  end

  def delegate_upn
    delegate.upn if delegate_id
  end

  def self.delegator_permit_delegate?(delegatorid, delegateid, o_id)
    Delegation.where(delegator_id: delegatorid, delegate_id: delegateid, organization_id: o_id).count > 0
  end
end
