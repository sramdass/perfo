class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :institution_id
      t.string :name
      t.string :short_name
      t.string :code
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
