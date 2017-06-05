class Calendar < ApplicationRecord
  	belongs_to :library, primary_key: "code"
end