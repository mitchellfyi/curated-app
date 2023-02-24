class SourcesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_source, only: %i[ show edit update destroy ]

  # GET /sources
  def index
    @sources = policy_scope(Source)
  end

  # GET /sources/1
  def show
  end

  # GET /sources/new
  def new
    @source = Source.new
    authorize @source
  end

  # GET /sources/1/edit
  def edit
  end

  # POST /sources
  def create
    @source = Source.new(source_params)

    if @source.save
      current_user.add_role(:owner, @source)
      current_user.add_role(:staff, @source)
      redirect_to @source, notice: "Source was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sources/1
  def update
    if @source.update(source_params)
      redirect_to @source, notice: "Source was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /sources/1
  def destroy
    @source.destroy
    redirect_to sources_url, notice: "Source was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source
      @source = Source.find(params[:id])
      authorize @source
    end

    # Only allow a list of trusted parameters through.
    def source_params
      params.require(:source).permit(:title, :url)
    end
end
