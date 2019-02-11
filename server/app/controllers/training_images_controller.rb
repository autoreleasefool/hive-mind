class TrainingImagesController < ApplicationController

  # GET /training_images/:id
  def show
    @training_image = TrainingImage.find(params[:id])
    render json: @training_image, methods: :photo_url
  end

  # POST /training_images.json
  def create
    @training_image = TrainingImage.new(training_image_params)
    tags = params[:training_image][:tags]
    photo = params[:training_image][:photo]

    if @training_image.save
      if photo
        @training_image.photo.attach(photo)
      end

      render json: @training_image, methods: :photo_url
    else
      render json: @training_image.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /training_images/1.json
  def update
    @training_image = TrainingImage.find(params[:id])
    photo = params[:training_image][:photo]

    if @training_image.update(training_image_params)
      if photo
        @training_image.photo.attach(photo)
      end

      render json: @training_image, status: :ok, location: @training_image, methods: :photo_url
    else
      render json: @training_image.errors, status: :unprocessable_entity
      end
  end

  private

  def training_image_params
    params.require(:training_image).permit(:tags, :photo)
  end

end
