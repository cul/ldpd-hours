require 'rails_helper'

describe 'locations open now', type: :feature do
  let(:now) { Time.now }
  let(:tomorrow) { now + 1.day }
  let(:fourAM) { Time.local(tomorrow.year, tomorrow.month, tomorrow.day , 4, 0, 0) }
  let(:threePM) { Time.local(now.year, now.month, now.day, 15, 0, 0) }
  let(:sevenPM) { Time.local(now.year, now.month, now.day, 19, 0, 0) }

  after do
    allow(Date).to receive(:current).and_return(now.to_date)
    allow(Time).to receive(:current).and_return(now)
  end
  context 'afternoon' do
    before do
      allow(Date).to receive(:current).and_return(now.to_date)
      allow(Time).to receive(:current).and_return(threePM)
      FactoryGirl.create(:butler_today)
      FactoryGirl.create(:lehman_today)
      FactoryGirl.create(:miskatonic_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(page).to have_content 'Butler'
      expect(page).to have_content 'Lehman'
    end

    it "does not display closed libraries" do
      expect(page).not_to have_content 'Miskatonic'
    end
  end
  context 'evening' do
    before do
      allow(Date).to receive(:current).and_return(now.to_date)
      allow(Time).to receive(:current).and_return(sevenPM)
      FactoryGirl.create(:butler_today)
      FactoryGirl.create(:lehman_today)
      FactoryGirl.create(:miskatonic_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(page).to have_content 'Lehman'
      expect(page).to have_content 'Miskatonic'
    end

    it "does not display closed libraries" do
      expect(page).not_to have_content 'Butler'
    end
  end
  context 'overnight' do
    before do
      allow(Date).to receive(:current).and_return(tomorrow.to_date)
      allow(Time).to receive(:current).and_return(fourAM)
      FactoryGirl.create(:butler_today)
      FactoryGirl.create(:lehman_today)
      FactoryGirl.create(:miskatonic_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(page).to have_content 'Miskatonic'
    end

    it "does not display closed libraries" do
      expect(page).not_to have_content 'Butler'
      expect(page).not_to have_content 'Lehman'
    end
  end
end
