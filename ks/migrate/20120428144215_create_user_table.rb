class CreateUserTable < ActiveColumn::Migration

  def self.up
    create_column_family :users do |cf|
      cf.comment = 'Users column family'
      cf.comparator_type= :string
    end
  end

  def self.down
    drop_column_family :users
  end

end
