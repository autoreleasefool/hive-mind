class CreateTrainingImages < ActiveRecord::Migration[5.2]
  def change
    create_table :training_images do |t|
      t.string :tags

      t.timestamps
    end
  end
end
