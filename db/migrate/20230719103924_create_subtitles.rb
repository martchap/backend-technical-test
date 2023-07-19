class CreateSubtitles < ActiveRecord::Migration[6.1]
  def change
    create_table :subtitles do |t|
      t.string :filename
      t.text :body
      t.timestamps
    end
  end
end
