require 'rails_helper'

describe 'locations open now', type: :feature do
  let(:now) { Time.current }
  let(:tomorrow) { now + 1.day }
  let(:fourAM) { Time.zone.local(tomorrow.year, tomorrow.month, tomorrow.day , 4, 0, 0) }
  let(:threePM) { Time.zone.local(now.year, now.month, now.day, 15, 0, 0) }
  let(:sevenPM) { Time.zone.local(now.year, now.month, now.day, 19, 0, 0) }
  let (:scripts) { page.all(:css, 'script[src]', visible: false) }
  let(:main_page_content) { find('#outer-wrapper') }

  after do
    allow(Date).to receive(:current).and_call_original
    allow(Time).to receive(:current).and_call_original
  end
  context 'with analytics' do
    before do
      Rails.application.secrets[:analytics_key] = 'fakey'
      visit '/locations/open_now'
    end
    it "tracks page views" do
      expect(scripts).not_to be_empty
      expect(scripts.find {|s| s[:src].include? 'gtag/js?id=fakey'}).to be
    end
  end
  context 'without analytics' do
    before do
      Rails.application.secrets.delete(:analytics_key)
      visit '/locations/open_now'
    end
    it "doesn't tracks page views" do
      expect(scripts).not_to be_empty
      expect(scripts.find {|s| s[:src].include? 'gtag/js?id='}).to be_nil
    end
  end
  context 'afternoon' do
    before do
      allow(Date).to receive(:current).and_return(now.to_date)
      allow(Time).to receive(:current).and_return(threePM)
      FactoryBot.create(:butler_today)
      FactoryBot.create(:lehman_today)
      FactoryBot.create(:miskatonic_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(main_page_content).to have_content 'Butler'
      expect(main_page_content).to have_content 'Lehman'
    end

    it "does not display closed libraries" do
      expect(main_page_content).not_to have_content 'Miskatonic'
    end
  end
  context 'evening' do
    before do
      allow(Date).to receive(:current).and_return(now.to_date)
      allow(Time).to receive(:current).and_return(sevenPM)
      FactoryBot.create(:butler_today)
      FactoryBot.create(:lehman_today)
      FactoryBot.create(:miskatonic_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(main_page_content).to have_content 'Lehman'
      expect(main_page_content).to have_content 'Miskatonic'
    end

    it "does not display closed libraries" do
      expect(main_page_content).not_to have_content 'Butler'
    end
  end
  context 'overnight' do
    before do
      allow(Date).to receive(:current).and_return(tomorrow.to_date)
      allow(Time).to receive(:current).and_return(fourAM)
      FactoryBot.create(:butler_today)
      FactoryBot.create(:lehman_today)
      FactoryBot.create(:miskatonic_today)
      FactoryBot.create(:duanereade_today)
      visit '/locations/open_now'
    end

    it "correctly displays open libraries" do
      expect(main_page_content).to have_content 'Miskatonic'
      expect(main_page_content).to have_content 'Drugstore'
    end

    it "does not display closed libraries" do
      expect(main_page_content).not_to have_content 'Butler'
      expect(main_page_content).not_to have_content 'Lehman'
    end
  end
  context 'primary closed' do
    before do
      allow(Date).to receive(:current).and_return(now.to_date)
      allow(Time).to receive(:current).and_return(threePM)
      FactoryBot.create(:butler_today).update(closed: true)
      FactoryBot.create(:lehman_today)
      FactoryBot.create(:underbutler_today)
      visit '/locations/open_now'
    end

    it "correctly displays open library" do
      expect(main_page_content).to have_content 'Lehman'
    end

    it "does not display closed libraries" do
      expect(main_page_content).not_to have_content 'Butler'
      expect(main_page_content).not_to have_content 'Library Under'
    end
  end
end
