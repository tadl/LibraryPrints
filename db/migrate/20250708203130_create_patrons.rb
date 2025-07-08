class CreatePatrons < ActiveRecord::Migration[7.1]
  def change
    create_table :patrons do |t|
      t.string :email
      t.string :name
      t.string :access_token
      t.datetime :token_sent_at

      t.timestamps
    end
    add_index :patrons, :email, unique: true
    add_index :patrons, :access_token, unique: true
  end
end
