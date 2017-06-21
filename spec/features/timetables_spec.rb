require 'rails_helper'

describe "Timetables", js: true do
  let(:lehman) { FactoryGirl.create(:lehman) }

  describe "viewing the page" do

    include_examples 'not authorized when non-admin logged in' do
      let(:request) { visit batch_edit_location_timetables_path(lehman)}
    end

    context "when admin is logged in" do
      include_context 'login admin user'

      it "should display a calendar" do
        visit(batch_edit_location_timetables_path(lehman))
        expect(page).to have_css("table.calendar")
      end

      it "should display tbd in boxes with a blank cal" do
        visit(batch_edit_location_timetables_path(lehman))
        expect(page).to have_content("TBD")
      end
  end


  describe "editing the calendar", js: true do 
    context 'when admin is logged in' do
      include_context 'login admin user'

      it "should add dates to the sidebar when clicked" do
        visit(batch_edit_location_timetables_path(lehman))
        first("tr td").click
        expect(page).to have_css('.days-list li', count: 1)
      end

      it "should save dates" do
        visit(batch_edit_location_timetables_path(lehman))
        find("td", :text => "25").click
        select "07 AM", :from => "timetable_open_4i"
        select "30", :from => "timetable_open_5i"
        select "06 PM", :from => "timetable_close_4i"
        select "30", :from => "timetable_close_5i"
        click_button("Update Hours")
        expect(page).to have_content("07:30AM-06:30PM")
      end

      it "should not save dates with invalid hours" do
        visit(batch_edit_location_timetables_path(lehman))
        find("td", :text => "25").click
        select "07 PM", :from => "timetable_open_4i"
        select "30", :from => "timetable_open_5i"
        select "06 PM", :from => "timetable_close_4i"
        select "30", :from => "timetable_close_5i"
        click_button("Update Hours")
        expect(find("div .alert-danger ul li").text).to eq("Please Enter Valid Data")
      end

      it "should display closed on calendar if closed" do
        visit(batch_edit_location_timetables_path(lehman))
        find("input#timetable_closed").click
        find("td", :text => "15").click
        click_button("Update Hours")
        expect(find("td span").text).to eq("Closed")
      end

      it "should display note if one is added" do
        visit(batch_edit_library_timetables_path(@library))
        find("input#timetable_closed").click
        find("td", :text => "15").click
        fill_in "Note", with: "Holiday"
        click_button("Update Hours")
        expect(find("td", :text => "15")).to have_content("Holiday")
      end

    end
  end
end
