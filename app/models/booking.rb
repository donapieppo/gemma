class Booking < Unload
  belongs_to :thing
  belongs_to :organization
  has_many :moves, foreign_key: :operation_id

  # only on creation. Admin can update and confirm
  before_create :validate_delegation

  def initialize(attributes = nil)
    if attributes.is_a?(Hash)
      attributes[:ddt_id] = nil
      attributes[:date] = date_afternoon(attributes[:date]) if attributes[:date]
    end
    super
  end

  # passiamo da prenotazione di scarico a scarico effettivo
  # lo rende Unload
  def confirm
    number < 0 or return nil
    ApplicationRecord.connection.execute("UPDATE operations SET type='Unload', date=NOW(), from_booking = 1 WHERE id=#{id.to_i}")
    true
  end

  # richiamato anche in confirm true/false
  def validate_delegation
    if recipient_id == user_id
      self.recipient_id = nil
    elsif recipient_id
      if Delegation.delegator_permit_delegate?(recipient_id, user_id, organization_id)
        Rails.logger.info("Correct delegation: #{user} delegated by #{recipient}")
        return true
      else
        Rails.logger.info("Wrong delegation: #{user} not delegated by #{recipient}")
        self.recipient_id = nil
        errors.add(:recipient_id, "Non autorizzato.")
        throw(:abort)
      end
    end
    true
  end

  # There is no trace of the delegation that generated the operation (booking) by design
  # in the form it is useful to get a possible original delegation
  def delegation_id
    Delegation.where(organization_id: organization_id, delegate_id: user_id, delegator_id: recipient_id).first&.id
  end

  def didattica?
    !!lab_id
  end
end
