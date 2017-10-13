class AddAccuracyToTourPoints < ActiveRecord::Migration
  def change
    add_column :tour_points, :accuracy, :decimal, precision: 4, scale: 1
  end
end
