class Location < ApplicationRecord
  belongs_to :organization
  has_many :deposits
  has_many :things, through: :deposits

  # vogliamo che inizi con una lettera o sia solo -
  validates :name, format: {with: /\A[\w _-]+\Z/, message: "Formato non corretto nel nome dell'ubicazione"}
  validates :name, uniqueness: {scope: [:organization_id], message: "Ubicazione già presente nella Struttura", case_sensitive: false}
  validates :organization_id, presence: true

  before_destroy :check_no_associated_things, prepend: true # http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html

  def to_s
    name.upcase
  end

  protected

  def check_no_associated_things
    if things.any?
      errors.add(:base, "Ci sono oggetti in questa ubicazione da spostare prima di poterla cancellare.")
      throw :abort
    end
  end
end
