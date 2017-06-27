require "rails_helper"

RSpec.describe Location, :type => :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :code  }
  end
end
