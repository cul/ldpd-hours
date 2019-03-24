require "rails_helper"

describe Hours::WifiDensity do
  let(:sample_wifi_density_response) { JSON.parse(file_fixture("sample-wifi-density-response.json").read) }
  let(:sample_hierarchical_wifi_density_data) { JSON.parse file_fixture("sample-hierarchical-wifi-density-data.json").read }

  before do
    allow(described_class).to receive(:fetch_raw_wifi_density_data).and_return(sample_wifi_density_response)
  end

  context ".percentage_for" do
    let(:butler_location) {
      Location.new(code: 'butler-24')
    }
    it "returns the expected percentage" do
      expect(described_class.percentage_for(butler_location)).to eq(27)
    end
  end

  context ".wifi_data_cache_duration" do
    it "returns the expected time" do
      expect(described_class.wifi_data_cache_duration).to eq(1.second)
    end
  end

  context ".data_url" do
    it "returns the expected url" do
      expect(described_class.data_url).to eq('https://hours.library.columbia.edu/wifi-density.json')
    end
  end

  context ".fetch_raw_wifi_density_data" do
    it "returns a parsed-json Hash" do
      expect(described_class.fetch_raw_wifi_density_data).to eq(sample_wifi_density_response)
    end
  end

  context ".fetch_hierarchical_wifi_density_data" do
    it "returns a hierarchical version of the raw wifi data with child locations nested under parents" do
      expect(described_class.fetch_hierarchical_wifi_density_data).to eq(sample_hierarchical_wifi_density_data)
    end
  end

  context ".recursively_collect_children" do
    let(:location_data_with_nested_children) do
      {
        "name" => "Butler Library",
        "children" => {
          "117" => {
            "parent_id" => "115",
            "name" => "Butler Library 3",
            "client_count" => "126",
            "children" => {
              "118" => {
                "parent_id" => "117",
                "name" => "Butler Library 301",
                "client_count" => "107"
              }
            }
          },
          "116" => {
            "parent_id" => "115",
            "name" => "Butler Library 2",
            "client_count" => "108"
          }
        }
      }
    end
    let(:expected_collected_children) do
      {
        "117" => {
          "parent_id" => "115",
          "name" => "Butler Library 3",
          "client_count" => "126",
          "children" => {
            "118" => {
              "parent_id" => "117",
              "name" => "Butler Library 301",
              "client_count" => "107"
            }
          }
        },
        "118" => {
          "parent_id" => "117",
          "name" => "Butler Library 301",
          "client_count" => "107"
        },
        "116" => {
          "parent_id" => "115",
          "name" => "Butler Library 2",
          "client_count" => "108"
        }
      }
    end
    it "works as expected" do
      expect(described_class.recursively_collect_children(location_data_with_nested_children)).to eq(expected_collected_children)
    end
  end
end
