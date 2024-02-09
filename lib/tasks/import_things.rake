namespace :gemma do
namespace :import do
  desc "Import things in an organization from csv"
  task import_things: :environment do
    org = Organization.find 261
    g = org.groups.first
    l = org.locations.first
    p org
    p l

    File.foreach("/tmp/magazzino.csv") do |line|
      name, desc1, desc2 = line.split("~")
      t = org.things.new(group_id: g.id, minimum: 0, name: name.strip.upcase, description: "#{desc1.strip.upcase} - #{desc2.strip.upcase}")
      p t
      if t.save
        t.create_deposits([l.id])
      else
        p t.errors
      end
    end
  end
end
end
