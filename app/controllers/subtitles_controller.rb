class SubtitlesController < ApplicationController
  before_action :set_subtitle, only: %i[ show edit update destroy ]

  # GET /subtitles or /subtitles.json
  def index
    @subtitles = SubtitlesService::Index.call(
      pagination: { page: 1 },
      ordering: { by: :created_at, direction: 'DESC' }
    )
  end

  # GET /subtitles/1 or /subtitles/1.json
  def show
  end

  # GET /subtitles/new
  def new
    @subtitle = SubtitlesService::New.call(attributes: params)
  end

  # GET /subtitles/1/edit
  def edit
  end

  # POST /subtitles or /subtitles.json
  def create
    @subtitle = SubtitlesService::Create.call(attributes: params.require(:subtitle))

    respond_to do |format|
      if @subtitle.persisted?
        format.html { redirect_to @subtitle, notice: "Subtitle was successfully created." }
        format.json { render :show, status: :created, location: @subtitle }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subtitle.errors, status: :unprocessable_entity }
      end
    end
  rescue Service::Errors::Invalid => e
    @errors = JSON.parse(e.message)

    @subtitle = SubtitlesService::New.call(attributes: params)

    respond_to do |format|
     format.html { render :new, status: :unprocessable_entity }
   end
  end

  def update
    respond_to do |format|
      if @subtitle = SubtitlesService::Update.call(
        attributes: params.require(:subtitle),
        find_by: { id: params[:id]}
      )
        format.html { redirect_to @subtitle, notice: "Subtitle was successfully updated." }
        format.json { render :show, status: :created, location: @subtitle }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @subtitle.errors, status: :unprocessable_entity }
      end
    end
  rescue Service::Errors::Invalid => e
    @errors = JSON.parse(e.message)

    set_subtitle

    respond_to do |format|
     format.html { render :edit, status: :unprocessable_entity }
   end
  end

  # DELETE /subtitles/1 or /subtitles/1.json
  def destroy
    @subtitle.destroy
    respond_to do |format|
      format.html { redirect_to subtitles_url, notice: "Subtitle was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_subtitle
    @subtitle = Subtitle.find(params[:id])
  end
end
