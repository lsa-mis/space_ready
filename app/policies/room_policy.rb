class RoomPolicy < ApplicationPolicy
  def index?
    is_admin?
  end

  def show?
    is_admin?
  end

  def create?
    is_admin?
  end

  def new?
    create?
  end

  def destroy?
    is_admin?
  end

  def archive?
    is_admin?
  end

  def unarchive?
    is_admin?
  end

  def upload_images?
    is_admin? || is_rover?
  end

  def delete_image?
    is_admin? || is_rover?
  end

end
