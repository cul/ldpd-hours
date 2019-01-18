require "rails_helper"

describe WifiDensityHelper do
  let(:subject_class) { Class.new { include WifiDensityHelper } }
  let(:sample_wifi_density_response) { JSON.parse file_fixture("sample-wifi-density-response.json").read }
  let(:sample_hierarchical_wifi_density_data) { JSON.parse file_fixture("sample-hierarchical-wifi-density-data.json").read }
  subject { subject_class.new }

  context "#fetch_raw_wifi_density_data" do
    it "returns a parsed-json Hash" do
      expect(subject.fetch_raw_wifi_density_data).to eq(sample_wifi_density_response)
    end
  end

  context "#fetch_hierarchical_wifi_density_data" do
    it "returns a hierarchical version of the raw wifi data with child locations nested under parents" do
      expect(subject.fetch_hierarchical_wifi_density_data).to eq(sample_hierarchical_wifi_density_data)
    end
  end

  context "#recursively_collect_children" do
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
      expect(subject.recursively_collect_children(location_data_with_nested_children)).to eq(expected_collected_children)
    end
  end

  context "#wifi_density_percentage" do
    let(:butler_location) {
      Location.new(code: 'butler-24')
    }
    before do
      stub_const('WIFI_DENSITY', {
        'butler-24' => {
          'cuit_location_ids' => [115],
          'high' => 1900
        }
      })
    end
    it "returns the expected percentage" do
      expect(subject.wifi_density_percentage(butler_location)).to eq(27)
    end
  end
end
