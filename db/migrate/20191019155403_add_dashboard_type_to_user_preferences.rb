class AddDashboardTypeToUserPreferences < ActiveRecord::Migration[5.2]
  def change
    add_column :user_preferences, :dashboard_type, :string, default: 'old', null: false
  end
end
