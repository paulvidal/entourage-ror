require 'rails_helper'

RSpec.describe Encounter, :type => :model do

  it { should validate_presence_of(:date) }
  it { should validate_presence_of(:street_person_name) }
  it { should validate_presence_of(:latitude) }
  it { should validate_presence_of(:tour) }
  it { should validate_presence_of(:longitude) }
  it { should belong_to(:tour).counter_cache(true) }

end
