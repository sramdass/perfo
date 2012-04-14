class RenameTypeToTipeInInstitutions < ActiveRecord::Migration
  def up
    rename_column :institutions, :type, :tipe
  end

  def down
    rename_column :institutions, :tipe, :type
  end
end
