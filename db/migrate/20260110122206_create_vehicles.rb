class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :brand
      t.string :vehicle_model
      t.string :variant
      t.integer :price
      t.integer :year
      t.string :fuel_type
      t.string :transmission
      t.integer :mileage
      t.integer :horsepower
      t.integer :kilowatts
      t.string :image
      t.string :badge
      t.string :badge_color
      t.integer :monthly_rate
      t.boolean :vat_reclaimable

      t.timestamps
    end
  end
end
