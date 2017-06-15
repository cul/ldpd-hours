require 'rails_helper'

describe "Timetables", js: true do

  before(:each) do
    @library = Library.create(name: "Lehman", code: "lehman")
  end

  describe "viewing the page" do
    include_context 'login admin user'

    it "should display a calendar" do
      visit(timetables_batch_edit_path(@library))
      expect(page).to have_css("table")
    end
  end


  describe "editing the calendar", js: true do 
    include_context 'login admin user'

    it "should add dates to the sidebar when clicked" do
      visit(timetables_batch_edit_path(@library))
      first("tr td").click
      expect(page).to have_css('.days-list li', count: 1)
    end

    it "should save dates" do
      visit(timetables_batch_edit_path(@library))
      find("td", :text => "25").click
      select "07 AM", :from => "time_table_open_4i"
      select "30", :from => "time_table_open_5i"
      select "06 PM", :from => "time_table_close_4i"
      select "30", :from => "time_table_close_5i"
      click_button("Update Hours")
      expect(find("td span").text).to eq("07:30AM-06:30PM")
    end

    it "should not save dates with invalid hours" do
      visit(timetables_batch_edit_path(@library))
      find("td", :text => "25").click
      select "07 PM", :from => "time_table_open_4i"
      select "30", :from => "time_table_open_5i"
      select "06 PM", :from => "time_table_close_4i"
      select "30", :from => "time_table_close_5i"
      click_button("Update Hours")
      expect(find("div .alert-danger ul li").text).to eq("Please Enter Valid Data")
    end
  end


end