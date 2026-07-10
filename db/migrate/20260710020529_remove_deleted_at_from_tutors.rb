class RemoveDeletedAtFromTutors < ActiveRecord::Migration[8.0]
  def change
    remove_column :tutors, :deleted_at, :datetime
  end
end
