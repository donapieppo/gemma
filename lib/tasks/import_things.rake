namespace :gemma do
  namespace :import do
    desc "Import things in an organization from csv"
    task import_things: :environment do
      org = Organization.find 223
      g = org.groups.first
      l = org.locations.first
      u = User.find_by_upn("giacomo.modigliani@unibo.it")
      p org
      p g
      p l

      File.foreach("tmp/magazzino.csv") do |line|
        name, num = line.split("\t")
        num = num.strip.to_i
        num = 0 if num < 0
        t = org.things.new(group_id: g.id, minimum: 0, name: name.strip.upcase)
        p t
        p num
        if t.save
          t.create_deposits([l.id])
          s = t.stocks.new(organization_id: org.id, user_id: u.id, numbers: {t.deposits.first.id => num})
          s.save!
        else
          p t.errors
        end
      end
    end
  end
end
