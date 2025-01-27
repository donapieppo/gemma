namespace :gemma do
  namespace :clear do
    desc "Delete inactive organizations"
    task delete_inactive_organizations: :environment do
      Organization.find_each do |organization|
        if organization.operations.in_last_years(2).count == 0
          p organization
          p organization.permissions.map(&:user)
          p organization.things
          p organization.deposits
          p organization.ddts
          p organization.operations
          puts "#{organization.operations.count} OPERAZIONI"
          puts "CANCELLO?"
          res = STDIN.gets.chop
          if res == "y"
            organization.deposits.destroy_all
            organization.things.destroy_all
            organization.groups.destroy_all
            organization.permissions.destroy_all
            organization.barcodes.destroy_all
            organization.ddts.destroy_all
            organization.locations.destroy_all
            organization.delete
          end
        end
      end
    end

    desc "Close inactive organizations from 2 years"
    task close_inactive_organizations_2_years: :environment do
      y = Date.today.year - 2
      Organization.find_each do |organization|
        if organization.operations.where("YEAR(date) >= ?", y).count == 0
          puts "rake gemma:chiusura:close org=#{organization.id}"
        end
      end
    end

    desc "Delete wrong shifts"
    task delete_wrong_shifts: :environment do
      Shift.find_each do |s|
        if s.moves.size < 1
          p thing = s.thing
          # s.moves.each {|m| m.delete}
          s.delete
          thing.rewrite_total
          thing.deposits.each { |d| d.update_actual }
        end
      end
    end
  end
end
