class CreateSecretViewRightsTable < Sequel::Migration
  def up
    create_table :secret_view_rights do
      foreign_key :secret_id, :secrets
      foreign_key :viewer_id, :users
    end
  end

  def down
    drop_table :secret_view_rights
  end
end
