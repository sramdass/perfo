# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

faculty_attrs = {:name => 'Satheesh Ramdass', :id_no => 'sramdass', :female => false}
faculty = Faculty.find_or_create_by_id_no(faculty_attrs)

contact_attrs = {:email => 'superuser@superuser.com', :mobile => 9999999999}
contact = Contact.find_or_create_by_email(contact_attrs)

faculty.contact = contact
faculty.save!

profile = UserProfile.find_or_create_by_login(:login => faculty.id_no, :password => "aaa", :password_confirmation => "aaa", :user => faculty)


