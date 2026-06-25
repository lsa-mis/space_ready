# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

locations = ['about_page', 'rovers_form', 'rovers_welcome_page', 'common_form', 'specific_form', 'resource_form', 'upload_images_form'] #hardcoded locations
existing_locations = Announcement.all.pluck(:location)
locations.each do |location|
  unless existing_locations.include?(location)
    Announcement.create!(location: location)
  end
end

preferences = [
  {:name => 'no_access_reason', :description => "Comma-separated list of why you can't access a room", :pref_type => 'string'},
  {:name => 'supervisor_phone_number', :description => 'A phone to report to a supervisor', :pref_type => 'string'},
  {:name => 'resource_types', :description => 'Comma-separated list of resource types to add from WebCheckout', :pref_type => 'string'},
  {:name => 'tdx_lsa_ts_email', :description => 'An email address to create a TDX ticket with LSA TS', :pref_type => 'string', :value => "Technology Issues (all classrooms): LSATechnologyServices@umich.edu"},
  {:name => 'tdx_facilities_email', :description => 'An email address to create a TDX ticket with LSA Facilities', :pref_type => 'string', :value => "Facilities Issues (LSA classrooms): lsa-facilities@umich.edu"},
  {:name => 'dana_building_facility_issues_email', :description => 'An email address to report Dana Building Facility Issues', :pref_type => 'string', :value => "Dana Building Facility Issues: seas-facilities@umich.edu"},
  {:name => 'skb_facility_issues_email', :description => 'An email address to report SKB Building Facility Issues', :pref_type => 'string', :value => "SKB Facility Issues: ptitus@umich.edu"},
  {:name => 'pharmacy_building_facility_issues_email', :description => 'An email address to report Pharmacy Building Facility Issues', :pref_type => 'string', :value => ""},
  {:name => 'tdx_tickets_quantity_on_dashboard', :description => 'How many recent Room Issues should be displayed on the Dashboard?', :pref_type => 'integer', :value => 6}
]
existing_preferences = AppPreference.all.pluck(:name)

preferences.each do |pref|
  unless existing_preferences.include?(pref[:name])
    AppPreference.create!(pref)
  end
end

Building.find_by(bldrecnbr: 1000151).update(nick_name: "UMMA") if Building.find_by(bldrecnbr: 1000151).present?
Building.find_by(bldrecnbr: 1005046).update(nick_name: "USB") if Building.find_by(bldrecnbr: 1005046).present?
Building.find_by(bldrecnbr: 1000165).update(nick_name: "WEIS") if Building.find_by(bldrecnbr: 1000165).present?
Building.find_by(bldrecnbr: 1000162).update(nick_name: "DENT") if Building.find_by(bldrecnbr: 1000162).present?
Building.find_by(bldrecnbr: 1005235).update(nick_name: "LSSH") if Building.find_by(bldrecnbr: 1005235).present?
Building.find_by(bldrecnbr: 1005177).update(nick_name: "NQ") if Building.find_by(bldrecnbr: 1005177).present?
Building.find_by(bldrecnbr: 1000440).update(nick_name: "SM") if Building.find_by(bldrecnbr: 1000440).present?
Building.find_by(bldrecnbr: 1000054).update(nick_name: "EQ") if Building.find_by(bldrecnbr: 1000054).present?
Building.find_by(bldrecnbr: 1000234).update(nick_name: "SPH") if Building.find_by(bldrecnbr: 1000234).present?
Building.find_by(bldrecnbr: 1000333).update(nick_name: "400NI") if Building.find_by(bldrecnbr: 1000333).present?
Building.find_by(bldrecnbr: 1005101).update(nick_name: "WEILL") if Building.find_by(bldrecnbr: 1005101).present?
Building.find_by(bldrecnbr: 1005370).update(nick_name: "BLAU") if Building.find_by(bldrecnbr: 1005370).present?
Building.find_by(bldrecnbr: 1000211).update(nick_name: "SKB") if Building.find_by(bldrecnbr: 1000211).present?
Building.find_by(bldrecnbr: 1000216).update(nick_name: "TAP") if Building.find_by(bldrecnbr: 1000216).present?
Building.find_by(bldrecnbr: 1000207).update(nick_name: "MLB") if Building.find_by(bldrecnbr: 1000207).present?
Building.find_by(bldrecnbr: 1005451).update(nick_name: "CCCB") if Building.find_by(bldrecnbr: 1005451).present?
Building.find_by(bldrecnbr: 1005188).update(nick_name: "R-BUS") if Building.find_by(bldrecnbr: 1005188).present?
Building.find_by(bldrecnbr: 1000158).update(nick_name: "CHEM") if Building.find_by(bldrecnbr: 1000158).present?
Building.find_by(bldrecnbr: 1000152).update(nick_name: "AH") if Building.find_by(bldrecnbr: 1000152).present?
Building.find_by(bldrecnbr: 1000154).update(nick_name: "LORCH") if Building.find_by(bldrecnbr: 1000154).present?
Building.find_by(bldrecnbr: 1000059).update(nick_name: "ALH") if Building.find_by(bldrecnbr: 1000059).present?
Building.find_by(bldrecnbr: 1000179).update(nick_name: "HUTCH") if Building.find_by(bldrecnbr: 1000179).present?
Building.find_by(bldrecnbr: 1000197).update(nick_name: "MH") if Building.find_by(bldrecnbr: 1000197).present?
Building.find_by(bldrecnbr: 1000188).update(nick_name: "NUB") if Building.find_by(bldrecnbr: 1000188).present?
Building.find_by(bldrecnbr: 1000221).update(nick_name: "SEB") if Building.find_by(bldrecnbr: 1000221).present?
Building.find_by(bldrecnbr: 1000206).update(nick_name: "AH") if Building.find_by(bldrecnbr: 1000206).present?
Building.find_by(bldrecnbr: 1000204).update(nick_name: "SPH") if Building.find_by(bldrecnbr: 1000204).present?
Building.find_by(bldrecnbr: 1005059).update(nick_name: "WDC") if Building.find_by(bldrecnbr: 1005059).present?
Building.find_by(bldrecnbr: 1005347).update(nick_name: "426NI") if Building.find_by(bldrecnbr: 1005347).present?
Building.find_by(bldrecnbr: 1000184).update(nick_name: "LLIBS") if Building.find_by(bldrecnbr: 1000184).present?
Building.find_by(bldrecnbr: 1005179).update(nick_name: "STB") if Building.find_by(bldrecnbr: 1005179).present?
Building.find_by(bldrecnbr: 1000219).update(nick_name: "SSWB") if Building.find_by(bldrecnbr: 1000219).present?
Building.find_by(bldrecnbr: 1000150).update(nick_name: "LSA") if Building.find_by(bldrecnbr: 1000150).present?
Building.find_by(bldrecnbr: 1000189).update(nick_name: "DANA") if Building.find_by(bldrecnbr: 1000189).present?
Building.find_by(bldrecnbr: 1000175).update(nick_name: "HH") if Building.find_by(bldrecnbr: 1000175).present?
Building.find_by(bldrecnbr: 1000166).update(nick_name: "EH") if Building.find_by(bldrecnbr: 1000166).present?
Building.find_by(bldrecnbr: 1000890).update(nick_name: "PERRY") if Building.find_by(bldrecnbr: 1000890).present?
Building.find_by(bldrecnbr: 1005224).update(nick_name: "STAMPS") if Building.find_by(bldrecnbr: 1005224).present?
Building.find_by(bldrecnbr: 1000155).update(nick_name: "BMT") if Building.find_by(bldrecnbr: 1000155).present?
Building.find_by(bldrecnbr: 1000167).update(nick_name: "WH") if Building.find_by(bldrecnbr: 1000167).present?
Building.find_by(bldrecnbr: 1005169).update(nick_name: "BSB") if Building.find_by(bldrecnbr: 1005169).present?
Building.find_by(bldrecnbr: 1005047).update(nick_name: "PALM") if Building.find_by(bldrecnbr: 1005047).present?
Building.find_by(bldrecnbr: 1000208).update(nick_name: "RAND") if Building.find_by(bldrecnbr: 1000208).present?

