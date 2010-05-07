class NocaseLoginColumn < Sequel::Migration
  def up
    set_column_type :users, :login, :string, :type => "varchar(255) COLLATE NOCASE"
  end

  def down
    set_column_type :users, :login, :string
  end
end
