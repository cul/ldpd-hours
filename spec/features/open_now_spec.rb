require 'rails_helper'

describe 'locations open now' do
  let(:butler) { FactoryGirl.create(:butler) }
  let(:avery) { FactoryGirl.create(:avery) }

  before do
    Timetable.create(location: butler, date: Date.today, open: '', close: '')
    Timetable.create(location: avery, date: Date.today, open: '', close: '')
  end

  it "correctly displays open library"

  it "does not display closed libraries"

end
