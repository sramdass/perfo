class AlterStartDateEndDateInFaculties < ActiveRecord::Migration
  def up
    remove_column :faculties, :start_date
    remove_column :faculties, :end_date
    add_column :faculties, :start_date, :date
    add_column :faculties, :end_date, :date
  end

  def down
  end
end
