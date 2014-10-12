class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  before_filter :authenticate_user!
    
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def anchor_path
    flash[:anchor_path]
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:userid, :name, :email, :password, :password_confirmation, :remember_me, :category, :company_id) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:userid, :name, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:userid, :name, :email, :password, :password_confirmation, :current_password, :category, :company_id) }
  end

  private
  def anchor!
    unless request.format.csv?
      flash[:anchor_path] = request.original_fullpath
    end
  end

  def keep_anchor!
    flash.keep(:anchor_path)
  end

  def adjust_page(paginated_rel, action = :index)
    if paginated_rel.out_of_bounds?
      redirect_to action: action, page: paginated_rel.total_pages
    end
  end
end
