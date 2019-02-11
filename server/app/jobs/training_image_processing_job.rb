require "fileutils"

class TrainingImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(training_image)
    tags = training_image.tags.split(",")
    photo = training_image.photo.download
    extension = training_image.photo.filename.extension_without_delimiter

    tags.each do |tag|
      tag_directory = File.join(Rails.application.config.training_storage, tag)
      FileUtils.mkdir_p(tag_directory)

      # Count files in directory to determine filename
      total_files = Dir[File.join(tag_directory, "*")].count { |file| File.file?(file) }
      filename = File.join(tag_directory, "image_#{total_files}.#{extension}")
      
      # Save the file to the directory
      File.open(filename, "wb") do |file|
        file.write(photo)
      end
    end
  end
end
