class ApplicationController < ActionController::Base
  include Pundit::Authorization
  if Rails.env.production? || Rails.env.staging?
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, unless: :devise_controller?
  include ApplicationHelper

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  def auth_user
    unless user_signed_in?
      $baseURL = request.fullpath
      redirect_post(user_saml_omniauth_authorize_path, options: {authenticity_token: :auto})
    end
  end

  def after_sign_in_path_for(resource)
    if session[:role] == "rover"
      welcome_rovers_path
    elsif session[:role] == "developer" || session[:role] == "admin"
      if $baseURL.present?
        $baseURL
      else
        dashboard_path
      end
    else
      root_path
    end
  end

  def sort_floors(floors)
    sorted = floors.sort_by do |s|
      if s =~ /^\d+$/
        [2, $&.to_i]
      else
        [1, s]
      end
    end
    return sorted
  end

  def redirect_back_or_default(notice: '', alert: false, default: all_root_url)
    if alert
      flash[:alert] = notice
    else
      flash[:notice] = notice
    end
    url = session[:return_to]
    session[:return_to] = nil
    redirect_to(url, anchor: "top" || default)
  end

  def pundit_user
    { user: current_user, role: session[:role] }
  end

  def render_404
    respond_to do |format|
      format.any { render 'errors/not_found', status: :not_found, layout: 'error' }
      format.json { render json: { error: 'Not Found' }, status: :not_found }
    end
  end

  def render_500(exception)
    # Log the error, send it to error tracking services, etc.
    respond_to do |format|
      format.any { render 'errors/internal_server_error', status: :internal_server_error, layout: 'error' }
      format.json { render json: { error: 'Internal Server Error' }, status: :internal_server_error }
    end
  end

  def redirect_rover_to_correct_state(room:, room_state:, step:, mode: "new")
    state_to_redirect_to = confirmation_rover_navigation_path(room_id: room.id)
    steps = ["room", "common_attributes", "specific_attributes", "resources", "upload_images"]
    index = steps.find_index(step) + 1
    redirect = {}

    CommonAttribute.active.present? ? redirect["common_attributes"] = true : redirect["common_attributes"] = false
    room.active_specific_attributes.present? ? redirect["specific_attributes"] = true : redirect["specific_attributes"] = false
    room.active_resources.present? ? redirect["resources"] = true : redirect["resources"] = false
    redirect["upload_images"] = true

    new_path_to_redirect = {
      "common_attributes" => new_common_attribute_state_path(room_state_id: room_state.id),
      "specific_attributes" => new_specific_attribute_state_path(room_state_id: room_state.id), 
      "resources" => new_resource_state_path(room_state_id: room_state.id),
      "upload_images" => upload_room_images_path(room_state_id: room_state.id, room_id: room.id)
    }

    edit_path_to_redirect = {
      "common_attributes" => edit_common_attribute_state_path(room_state_id: room_state.id, id: room.id),
      "specific_attributes" => edit_specific_attribute_state_path(room_state_id: room_state.id, id: room.id), 
      "resources" => edit_resource_state_path(room_state_id: room_state.id, id: room.id),
      "upload_images" => upload_room_images_path(room_state_id: room_state.id, room_id: room.id)
    }

    while index < steps.count
      unless redirect[steps[index]]
        index += 1
        next
      end

      if mode == "new"
        state_to_redirect_to = new_path_to_redirect[steps[index]]
        return state_to_redirect_to
      end

      if mode == "edit"
        case steps[index]
        when "common_attributes"
          if room_state.common_attribute_states.any?
            state_to_redirect_to = edit_path_to_redirect[steps[index]]
            return state_to_redirect_to
          else
            state_to_redirect_to = new_path_to_redirect[steps[index]]
            return state_to_redirect_to
          end
        when "specific_attributes"
          if room_state.specific_attribute_states.any?
            state_to_redirect_to = edit_path_to_redirect[steps[index]]
            return state_to_redirect_to
          else
            state_to_redirect_to = new_path_to_redirect[steps[index]]
            return state_to_redirect_to
          end
        when "resources"
          if room_state.resource_states.any?
            state_to_redirect_to = edit_path_to_redirect[steps[index]]
            return state_to_redirect_to
          else
            state_to_redirect_to = new_path_to_redirect[steps[index]]
            return state_to_redirect_to
          end
        when "upload_images"
          state_to_redirect_to = new_path_to_redirect[steps[index]]
          return state_to_redirect_to
        end
      end
    end
    state_to_redirect_to
  end

end
