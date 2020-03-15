# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

all_location = Location.create(name: "All Locations", code: "all", primary: true, front_page: false)
butler = Location.create(name: "Butler", code: "butler", primary: true)
avery = Location.create(name: "Avery", code: "avery", primary: true)
rbml = Location.create(name: "Rare Books", code: "rbml", primary_location: butler)

admin = User.create(email: "admin@example.com", provider: :developer, name: "Test Admin")
admin.update_permissions(role: Permission::ADMINISTRATOR)
