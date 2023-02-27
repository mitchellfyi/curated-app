class AccountsController < ApplicationController
  skip_before_action :set_tenant
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_account, only: %i[show edit update destroy]

  def index
    @accounts = policy_scope(Account)
  end

  def show
    redirect_to(@account.url, allow_other_host: true)
  end

  def new
    @account = Account.new
    authorize @account
  end

  def edit; end

  def create
    @account = Account.new(account_params)
    authorize @account

    if @account.save
      current_user.add_role(:owner, @account)
      current_user.add_role(:staff, @account)
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @account.update(account_params)
      redirect_to edit_account_path(@account), notice: 'Account was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @account.destroy
    redirect_to root_url(subdomain: false), notice: 'Account was successfully destroyed.'
  end

  private

  def set_account
    @account = Account.find(params[:id])
    authorize @account
  end

  def account_params
    params.require(:account).permit(:name, :subdomain, :domain)
  end
end
