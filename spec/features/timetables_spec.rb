require 'rails_helper'

describe "Timetables", type: :feature, js: true do
  let!(:all_location) { FactoryBot.create(:all_location) }
  let!(:lehman) { FactoryBot.create(:lehman) }
  let!(:miskatonic) { FactoryBot.create(:miskatonic) }

  shared_examples 'view the page' do
    it "should display a calendar" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      expect(page).to have_css("table.calendar")
    end

    it "should display tbd in boxes with a blank cal" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      expect(page).to have_content("TBD")
    end

    it "should display hours that have previously been set" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      find("td", :text => "16").click
      select "07 AM", :from => "timetable_open_4i"
      select "30", :from => "timetable_open_5i"
      select "06 PM", :from => "timetable_close_4i"
      select "30", :from => "timetable_close_5i"
      click_button("Update Hours")
      find("td", :text => "16")
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      expect(find("td", :text => "16")).to have_content("7:30AM-6:30PM")
    end
  end

  shared_examples 'edit the calendar' do
    it "should add dates to the sidebar when clicked" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      first("tr td").click
      expect(page).to have_css('.days-list li', count: 1)
    end

    it "should save dates" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      find(:xpath, "//td[not(contains(@class, 'not-month'))]", :text => "25").click
      select "07 AM", :from => "timetable_open_4i"
      select "30", :from => "timetable_open_5i"
      select "06 PM", :from => "timetable_close_4i"
      select "30", :from => "timetable_close_5i"
      click_button("Update Hours")
      expect(page).to have_content("7:30AM-6:30PM")
    end

    it "should warn when hours run overnight" do
      visit(exceptional_edit_location_timetables_path(location_code: miskatonic.code))
      find(:xpath, "//td[not(contains(@class, 'not-month'))]", :text => "25").click
      select "07 PM", :from => "timetable_open_4i"
      select "30", :from => "timetable_open_5i"
      select "06 PM", :from => "timetable_close_4i"
      select "30", :from => "timetable_close_5i"
      click_button("Update Hours")
      expect(find("div .alert-warning ul li").text).to have_content("overnight schedule")
    end

    it "should display closed on calendar if closed" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      find("input#timetable_closed").click
      find("td", :text => "15").click
      click_button("Update Hours")
      expect(find("td", :text => "15")).to have_content("Closed")
    end

    it "should display note if one is added" do
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      find("input#timetable_closed").click
      find("td", :text => "15").click
      fill_in "Note", with: "Holiday"
      click_button("Update Hours")
      expect(find("td", :text => "15")).to have_content("Holiday")
    end
  end

  shared_examples 'edit all calendars' do
    it "should display note everywhere if one is added to 'all'" do
      visit(exceptional_edit_location_timetables_path(location_code: 'all'))
      find("input#timetable_closed").click
      find("td", :text => "15").click
      fill_in "Note", with: "Holiday"
      click_button("Update Hours")
      expect(find("td", :text => "15")).to have_content("Holiday")
      visit(exceptional_edit_location_timetables_path(location_code: lehman.code))
      expect(find("td", :text => "15")).to have_content("Holiday")
    end
  end

  shared_examples 'batch edit calendar' do
    pending
  end

  describe 'when administrator logged in' do
    include_context 'login admin'

    include_examples 'view the page'
    include_examples 'edit the calendar'
    include_examples 'edit all calendars'
    include_examples 'batch edit calendar'
  end

  describe 'when manager logged in' do
    include_context 'login manager'

    include_examples 'view the page'
    include_examples 'edit the calendar'
  end

  describe 'when lehman editor logged in' do
    include_context 'login user'
    before :each do
      logged_in_user.update_permissions(role: 'editor', location_ids: [lehman.id, miskatonic.id])
    end

    include_examples 'view the page'
    include_examples 'edit the calendar'
  end

  describe 'when butler editor logged in' do
    let(:butler) { FactoryBot.create(:butler) }

    include_context 'login user'
    before :each do
      logged_in_user.update_permissions(role: 'editor', location_ids: [butler.id, miskatonic.id])
    end

    it 'cannot view set hours page' do
      visit exceptional_edit_location_timetables_path(location_code: lehman.code)
      expect(page).to have_content 'Unauthorized'
    end

    it 'cannot view batch hours page' do
      visit batch_edit_location_timetables_path(location_code: lehman.code)
      expect(page).to have_content 'Unauthorized'
    end
  end

  describe 'when user without a role logged in' do
    include_context 'login user'

    it 'cannot view set hours page' do
      visit exceptional_edit_location_timetables_path(location_code: lehman.code)
      expect(page).to have_content 'Unauthorized'
    end

    it 'cannot view batch hours page' do
      visit batch_edit_location_timetables_path(location_code: lehman.code)
      expect(page).to have_content 'Unauthorized'
    end
  end
end
