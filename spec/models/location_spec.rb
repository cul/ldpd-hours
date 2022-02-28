require "rails_helper"

RSpec.describe Location, :type => :model do
  describe 'validations' do
    let(:validators) { described_class.validators }
    let(:presence_validator) { validators.detect { |v| ActiveRecord::Validations::PresenceValidator === v } }
    let(:miskatonic) { FactoryBot.create(:miskatonic) }
    let(:sorcery) { FactoryBot.create(:sorcery) }
    let(:butler) { FactoryBot.create(:butler) }
    let(:underbutler) { FactoryBot.create(:underbutler) }

    it { expect(presence_validator.attributes).to include(:name) }
    it { expect(presence_validator.attributes).to include(:code) }

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

  describe 'build_api_response' do
    let(:butler) { FactoryBot.create(:butler) }
    it "raises if start_date larger than end_date" do
      start_date = '1958-10-10'
      end_date = '1958-10-09'
      expect { butler.build_api_response(start_date, end_date) }.to raise_error("build_api_response: start_date is larger than end_date.")
    end
  end
end
