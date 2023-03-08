class CollectionsController < ApplicationController
  skip_before_action :set_tenant
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_collection, only: %i[show edit update destroy]

  def index
    @collections = policy_scope(Collection)
  end

  def show
    redirect_to(@collection.url, allow_other_host: true)
  end

  def new
    @collection = Collection.new
    authorize @collection
  end

  def edit; end

  def create
    @collection = Collection.new(collection_params)
    authorize @collection

    if @collection.save
      current_user.add_role(:owner, @collection)
      current_user.add_role(:staff, @collection)
      redirect_to(@collection.url, notice: 'Collection was successfully created.', allow_other_host: true)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to edit_collection_path(@collection), notice: 'Collection was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to root_url(subdomain: false), notice: 'Collection was successfully destroyed.'
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
    authorize @collection
  end

  def collection_params
    params.require(:collection).permit(:name, :subdomain, :domain)
  end
end
