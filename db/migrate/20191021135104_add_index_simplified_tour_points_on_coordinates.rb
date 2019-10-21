class AddIndexSimplifiedTourPointsOnCoordinates < ActiveRecord::Migration
  def change
    add_index :simplified_tour_points, [:latitude, :longitude, :tour_id], name: :index_simplified_tour_points_on_coordinates_and_tour_id
  end
end
