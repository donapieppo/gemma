class Barcode < ApplicationRecord
  belongs_to :thing
  belongs_to :organization

  validates :name, format: { with: /\A[\w\-]+\z/, message: "Formato non corretto." }
  validates :name, uniqueness: { scope: [:organization_id], message: "Codice a barre già presente nella Struttura.", case_sensitive: false }

  validate :check_thing_organization

  protected

  def check_thing_organization
    (self.thing.organization_id == self.organization_id) or raise DmUniboCommon::MismatchOrganization, "Oggetto e struttura non concordi."
  end

  def self.generate(t)
    str = "g-#{t.id}"
    b = Barcode.create(thing_id: t.id, organization_id: t.organization_id, name: str)
  end
end
