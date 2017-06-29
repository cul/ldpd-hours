require 'rails_helper'

describe 'locations open now' do
  context 'when one library closed and one open' do
    before do
      FactoryGirl.create(:butler_today, open: (Time.current - 1.hour).hour.to_s,
                         close: (Time.current + 5.hours).hour.to_s)
      FactoryGirl.create(:lehman_today, open: (Time.current + 1.hour).hour.to_s,
                         close: (Time.current + 6.hours).hour.to_s)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(page).to have_content 'Butler'
    end

    it "does not display closed libraries" do
      expect(page).not_to have_content 'Lehman'
    end
  end
end
