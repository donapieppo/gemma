# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Organization.create(name: "Dip Math", description: "Dipartimento di Matematica di test")
Organization.create(name: "Dip Chimica", description: "Dipartimento di Chimica di test")
User.create(id: 1, upn: "administrator@example.com", name: "Name", surname: "Administrator", email: "administrator@example.com")
User.create(id: 2, upn: "manager@example.com", name: "Name", surname: "Manager", email: "manager@example.com")
User.create(id: 3, upn: "user@example.com", name: "Name", surname: "Surname", email: "user@example.com")
Argument.create(organization_id: 1, name: "Algebra")
Argument.create(organization_id: 1, name: "Geometria")
