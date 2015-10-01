class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :recipient
      t.string :sender
      t.text :subject
      t.text :content
      t.string :type
      t.integer :tries
      t.datetime :sent
      t.string :hash

      t.timestamps
    end
  end
end
