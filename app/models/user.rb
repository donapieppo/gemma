class User < ApplicationRecord
  include DmUniboCommon::User

  has_many :operations
  has_many :unloads
  has_many :loads
  has_many :bookings
  has_many :orders
  has_many :images
  has_many :disposals
  has_and_belongs_to_many :delegates,  class_name: 'User', foreign_key: :delegator_id, association_foreign_key: :delegate_id, join_table: :delegations
  has_and_belongs_to_many :delegators, class_name: 'User', foreign_key: :delegate_id, association_foreign_key: :delegator_id, join_table: :delegations

  # Ritorna tutti gli utenti che sono stati in qualche modo associati ad una certa struttura in passato
  # Di solito sono gli utenti che hanno fatto s/carichi o a cui sono stati associati scarichi 
  # Andiamo indietro di un paio di anni (RECENTY in configuration for caching in mysql)
  def self.all_in_cache(organization_id, booking = false)
    if booking 
      User.find_by_sql "SELECT DISTINCT users.id, users.upn, name, surname 
                                   FROM users, operations 
                                  WHERE organization_id = #{organization_id.to_i} 
                                        AND operations.from_booking IS NOT NULL
                                        AND users.id  = user_id
                                    AND operations.date > #{RECENTLY}
                               ORDER BY surname"
    else
      User.find_by_sql "SELECT DISTINCT users.id, users.upn, name, surname
                                   FROM users 
                                   WHERE id IN (SELECT recipient_id FROM operations WHERE organization_id = #{organization_id.to_i}
                                                UNION DISTINCT SELECT user_id FROM operations WHERE organization_id = #{organization_id.to_i})
                                   ORDER BY surname"
    end
  
    #and_user    = booking ? 'AND users.id  = user_id' : 'AND ( users.id = recipient_id OR users.id  = user_id )' 
    #User.find_by_sql "SELECT DISTINCT users.id, users.upn, name, surname 
    #                             FROM users, operations 
    #                            WHERE organization_id = #{organization_id.to_i} 
    #                                  #{and_booking} 
    #                                  #{and_user}
    #                              AND operations.date > DATE_SUB(NOW(), INTERVAL 1 YEAR)
    #                         ORDER BY surname"
  end

  def self.recipient_cache(organization_id, interval = 365)
    User.find_by_sql "SELECT DISTINCT users.id, users.upn, name, surname 
                                 FROM users, operations 
                                WHERE organization_id = #{organization_id.to_i} 
                                  AND operations.recipient_id IS NOT NULL
                                  AND users.id = recipient_id
                                  AND operations.date > DATE_SUB(CURDATE(), INTERVAL #{interval} DAY)
                             ORDER BY surname"
  end

  def get_delegators(organization_id)
    self.delegators.where('delegations.organization_id = ?', organization_id)
  end

  def get_delegates(organization_id)
    self.delegates.where('delegations.organization_id = ?', organization_id)
  end
end

