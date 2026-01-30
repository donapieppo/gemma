class Organization < ApplicationRecord
  include DmUniboCommon::Organization

  has_many :groups
  has_many :locations
  has_many :operations
  has_many :loads
  has_many :unloads
  has_many :shifts
  has_many :takeovers
  has_many :deposits
  has_many :ddts
  has_many :stocks
  has_many :things
  has_many :bookings
  has_many :barcodes
  has_many :delegations
  has_many :labs
  has_many :cost_centers
  has_many :picking_points

  has_many :arch_operations
  has_many :arch_things
  has_many :arch_ddts

  validates :name, uniqueness: {message: "Struttura già presente.", case_sensitive: false}

  validate :check_mail_parameters

  before_destroy :manual_delete

  def create_default_group
    self.groups.create(name: FIRST_GROUP) if self.groups.empty?
  end

  def create_default_location
    self.locations.create(name: FIRST_LOCATION) if self.locations.empty?
  end

  # una struttura (organization) "nasce" quando gli viene assegnato un amministratore
  # e quindi si verifica che esistano:
  # 1) una ubicazione (location) fittizia 'generale' per i pigri
  # 2) una categoria (gruppo) iniziale chiamata 'Cancelleria'
  def activate
    create_default_location
    create_default_group
  end

  def last_recipient_upn
    o = operations.where("operations.recipient_id is not null").order("date desc").first
    o&.recipient&.upn
  end

  def destroyable?
    operations.count == 0
  end

  private

  def check_mail_parameters
    Configuration::NOTIFY_FREQUENCIES.include?(self.sendmail) or self.sendmail = "n"

    # se abbiamo adminmail lo controlliamo
    self.adminmail.nil? and return true
    self.adminmail.gsub!(/\s+/, '')

    self.adminmail.split(",").each do |mail|
      (mail =~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/) and next
      errors.add(:adminmail, "indirizzo mail non corretto")
      throw(:abort)
    end

    true
  end

  def manual_delete
    self.operations.destroy_all
    self.deposits.destroy_all
    self.things.destroy_all
    self.groups.destroy_all
    self.admins.destroy_all
    self.barcodes.destroy_all
    self.ddts.destroy_all
    self.locations.destroy_all
    # ARCH
    self.arch_operations.destroy_all
    self.arch_things.destroy_all
    self.arch_ddts.destroy_all
  end
end
