class CreateSecretsTable < Sequel::Migration
  def up
    create_table :secrets do
      primary_key :id
      Fixnum :user_id
      String :title
      String :body
      Time   :created_at
    end
  end

  def down
    drop_table :secrets
  end
end
