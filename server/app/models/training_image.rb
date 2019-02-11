class TrainingImage < ApplicationRecord
    has_one_attached :photo

    def photo_url
        if self.photo.attached?
            Rails.application.routes.url_helpers.rails_blob_path(self.photo, only_path: true)
        else
            nil
        end
    end
end
