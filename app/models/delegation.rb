class Delegation < ApplicationRecord
  belongs_to :organization
  belongs_to :delegator, class_name: 'User'
  belongs_to :delegate,  class_name: 'User'

  validate :validate_delegator, 
           :validate_delegate

  def validate_delegator
    throw(:abort) unless @_delegator_upn # explicitly halt callbacks.
    begin
      _delegator = User.syncronize(@_delegator_upn)
      Rails.logger.info _delegator.inspect
      self.delegator_id = _delegator.id
    rescue => e
      Rails.logger.info "#{e} while validating delegator: #{@_delegator_upn}"
      self.errors.add(:delegator, e.to_s)
      self.errors.add(:base, e.to_s)
    end
  end

  def validate_delegate
    throw(:abort) unless @_delegate_upn # explicitly halt callbacks.
    begin
      _delegate = User.syncronize(@_delegate_upn)
      Rails.logger.info _delegate.inspect
      self.delegate_id = _delegate.id
    rescue => e
      Rails.logger.info "#{e} while validating delegate: #{@_delegate_upn}"
      self.errors.add(:delegate, e.to_s)
      self.errors.add(:base, e.to_s)
    end
  end

  def delegator_upn=(d)
    @_delegator_upn = (d =~ /(\w+\.\w+)/) ? "#{Regexp.last_match(1)}@unibo.it" : 'wrong upn'
  end

  def delegator_upn
    self.delegator.upn if self.delegator_id
  end

  def delegate_upn=(d)
    @_delegate_upn = (d =~ /(\w+\.\w+)/) ? "#{Regexp.last_match(1)}@unibo.it" : 'wrong upn'
  end

  def delegate_upn
    self.delegate.upn if self.delegate_id
  end

  def self.delegator_permit_delegate?(delegatorid, delegateid, o_id)
    Delegation.where(delegator_id: delegatorid, delegate_id: delegateid, organization_id: o_id).count > 0
  end
end


