class AddEncryptionFields < ActiveRecord::Migration[7.1]
  def change
    create_table :videos do |t|
      t.string :encrypted_file_path
      t.string :encrypted_video_key
      t.string :original_file_name
      # Add any other columns you need for your videos table
      t.timestamps
    end
  end
end
