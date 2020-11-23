class Supplier < ApplicationRecord
  has_many :ddts

  validates :name, format: { with: /\w/, message: 'Il nome del fornitore non mi sembra corretto.' }
  validates :pi,   format: { with: /\A[0-9a-zA-Z]{11}\z/, message: 'La partita iva deve contenere 11 caratteri.' },
                   uniqueness: { message: 'Esiste già un fornitore con la stessa partita iva', case_sensitive: false }

  def self.find_by_organization(organization_id)
    find_by_sql("SELECT DISTINCT suppliers.* 
                            FROM suppliers, ddts 
                           WHERE ddts.supplier_id = suppliers.id 
                             AND ddts.organization_id = #{organization_id.to_i}")
  end

  def to_s
    self.name
  end
end
