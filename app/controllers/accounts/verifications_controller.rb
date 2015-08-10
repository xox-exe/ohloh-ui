class Accounts::VerificationsController < ApplicationController
  include RedirectIfDisabled

  skip_before_action :store_location
  before_action :session_required
  before_action :set_account
  before_action :redirect_if_disabled
  before_action :must_own_account
  before_action :redirect_if_verified

  def create
    if digits_response_success?
      return redirect_back if @account.update(twitter_id: twitter_id)
      flash[:error] = @account.errors.messages[:twitter_id].first
    else
      flash[:error] = t('.error')
    end

    render :new
  end

  private

  def set_account
    @account = Account.from_param(params[:account_id]).take
    fail ParamRecordNotFound unless @account
  end

  def digits_response_success?
    twitter_id.present?
  end

  def redirect_if_verified
    redirect_to root_path if @account.twitter_id?
  end

  def twitter_id
    @twitter_id ||= TwitterDigits.get_twitter_id(params[:verification][:service_provider_url],
                                                 params[:verification][:credentials])
  end
end