namespace :db do
  desc "Populate the database with sample data for demo"
  task setup_demo: :environment do
    if Rails.env.production?
      puts "ERROR: Cannot run demo setup in production!"
    else
      puts "Creating demo data..."
      o1 = Organization.find_or_create_by!(code: "demo1") do |organization|
        organization.name = "Demo Organizations 1"
        organization.description = "Demo Organizations 1"
        o1.pricing = 1
      end
      o2 = Organization.find_or_create_by!(code: "demo2") do |organization|
        organization.name = "Demo Organizations 2"
        organization.description = "Demo Organizations 2"
      end
      o3 = Organization.find_or_create_by!(code: "demo3") do |organization|
        organization.name = "Demo Organizations 3"
        organization.description = "Demo Organizations 3"
      end

      u1 = User.find_or_create_by!(upn: "admin.user@example.com") do |user|
        user.email = "admin.user@example.com"
        user.surname = "ADMIN"
        user.name = "USER"
      end
      u2 = User.find_or_create_by!(upn: "simple.user@example.com") do |user|
        user.email = "simple.user@example.com"
        user.surname = "SIMPLE"
        user.name = "USER"
      end

      # u1 can admin all
      u1.permissions.find_or_create_by!(organization: o1) { |permission| permission.authlevel = 50 }
      u1.permissions.find_or_create_by!(organization: o2) { |permission| permission.authlevel = 50 }
      u1.permissions.find_or_create_by!(organization: o3) { |permission| permission.authlevel = 50 }

      # u2 can only unload in o2 and book in 03
      u2.permissions.find_or_create_by!(organization: o1) { |permission| permission.authlevel = 20 }
      u2.permissions.find_or_create_by!(organization: o3) { |permission| permission.authlevel = 15 }

      # basic data on o2 and o3. o1 in empty
      g21 = o2.groups.find_or_create_by(name: "Carta")
      deposit = o2.deposist.first
      o2.create_default_location
      g21.things.find_or_create_by(organization: o2, name: "Carta A3", minimum: 10)
      g21.things.find_or_create_by(organization: o2, name: "Carta A4", minimum: 10)
      puts "Demo data loaded successfully."
      puts "Login with email admin.user@example.com to be an administrator and with simple.user@example.com to be a simple user than can unload"
    end
  end
end
