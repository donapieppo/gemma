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
    super(attributes)
  end

  # passiamo da prenotazione di scarico a scarico effettivo
  # lo rende Unload
  def confirm
    self.number < 0 or return nil
    ApplicationRecord.connection.execute("UPDATE operations SET type='Unload', date=NOW(), from_booking = 1 WHERE id=#{self.id.to_i}")
    true
  end

  # richiamato anche in confirm true/false
  def validate_delegation
    if self.recipient_id == self.user_id
      self.recipient_id = nil
    elsif self.recipient_id
      if Delegation.delegator_permit_delegate?(self.recipient_id, self.user_id, self.organization_id)
        Rails.logger.info("Correct delegation: #{self.user} delegated by #{self.recipient}")
        return true
      else
        Rails.logger.info("Wrong delegation: #{self.user} not delegated by #{self.recipient}")
        self.recipient_id = nil
        errors.add(:recipient_id, "Non autorizzato.")
        throw(:abort)
      end
    end
    true
  end

  def didattica?
    !!lab_id
  end
end
