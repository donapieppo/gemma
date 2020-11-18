namespace :gemma do
namespace :copy do

  desc "Copy things from an organization to another" 
  task copy_things: :environment do 
    org_from = Organization.find 220
    org_to = Organization.find 232

    p org_from
    p org_to

    l2 = org_to.locations.first

    p org_to.operations

    ok = STDIN.gets

    org_from.groups.each do |g1|
      g2 = org_to.groups.where(name: g1.name).first || org_to.groups.create(name: g1.name)
      p g1
      p g2

      g1.things.each do |t1|
        t2 = org_to.things.where(name: t1.name).first || org_to.things.create(name: t1.name, group: g2, minimum: 0)
        t2.create_deposits([l2.id])
        p t1
        p t2
      end
    end
  end
end
end


