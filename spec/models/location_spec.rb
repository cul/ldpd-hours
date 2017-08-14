require "rails_helper"

RSpec.describe Location, :type => :model do
  describe 'validations' do
    let(:miskatonic) { FactoryGirl.create(:miskatonic) }
    let(:sorcery) { FactoryGirl.create(:sorcery) }
    let(:butler) { FactoryGirl.create(:butler) }
    let(:underbutler) { FactoryGirl.create(:underbutler) }

    it { should validate_presence_of :name }
    it { should validate_presence_of :code  }

    it "requires primary location not to have a primary location" do
      miskatonic.primary_location = butler
      expect(miskatonic).not_to be_valid
    end

    it "requires primary location to be primary" do
      sorcery.primary_location = underbutler
      expect(sorcery).not_to be_valid
    end

    it "allows primary location to be assigned to non-primary locations" do
      sorcery.primary_location = butler
      expect(sorcery).to be_valid
    end
  end
end
