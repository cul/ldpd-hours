require 'rails_helper'

describe "TimeTables" do
  include_context 'login admin user'
  
  before(:each) do
    @library = Library.create(name: "Lehman", code: "lehman")
    visit("/admin")
    first("li a").click
  end

  describe "batch edit page", js: true do
    it "should display a calendar" do
      expect(page).to have_css("table")
    end

    it "should add dates to the sidebar when clicked" do
      first("tr td").click
      expect(page).to have_css('.days-list li', count: 1)
    end

    it "should save dates" do
      find("td", :text => "25").click
      select "07 AM", :from => "time_table_open_4i"
      select "30", :from => "time_table_open_5i"
      select "06 PM", :from => "time_table_close_4i"
      select "30", :from => "time_table_close_5i"
      click_button("Update Hours")
      expect(find("td span").text).to eq("07:30AM-06:30PM")
    end
  end

end