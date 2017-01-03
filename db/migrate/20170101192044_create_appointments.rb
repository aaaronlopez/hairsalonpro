class CreateAppointments < ActiveRecord::Migration[5.0]
  def change
    create_table :appointments do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.belongs_to :customer, foreign_key: true

      t.timestamps
    end
  end
end
