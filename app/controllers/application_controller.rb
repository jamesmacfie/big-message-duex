class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?, :current_person

  # Error handling
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def current_person
    current_user&.person
  end

  def record_not_found(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "The resource you're looking for could not be found."
        redirect_to root_path
      end
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def record_invalid(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = exception.record.errors.full_messages.join(", ")
        redirect_back fallback_location: root_path
      end
      format.json do
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def parameter_missing(exception)
    respond_to do |format|
      format.html do
        flash[:alert] = "Required information is missing."
        redirect_back fallback_location: root_path
      end
      format.json { render json: { error: "Missing required parameters" }, status: :bad_request }
    end
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  def require_confirmed_email
    if logged_in? && !current_user.confirmed?
      flash[:alert] = "Please confirm your email address to continue."
      redirect_to login_path
    end
  end

  def log_in(user)
    session[:user_id] = user.id
    # Also set a signed cookie for Action Cable authentication
    # Action Cable can't access the session, so it needs this cookie
    cookies.signed.permanent[:user_id] = user.id
    @current_user = user
  end

  def log_out
    session.delete(:user_id)
    cookies.delete(:user_id)
    @current_user = nil
  end
end
