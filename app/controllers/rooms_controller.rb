class RoomsController < ApplicationController
  before_action :auth_user
  before_action :set_room, only: %i[ show destroy archive unarchive ]
  include BuildingApi

  # GET /rooms/1 or /rooms/1.json
  def show
    @common_attributes = CommonAttribute.active
    @new_note = Note.new(room: @room)
    @notes = @room.notes.order("created_at DESC")
  end

  # GET /rooms/new
  def new
    @room = Room.new
    @building = Building.find(params[:building_id])
    authorize @room
  end

  # POST /rooms or /rooms.json
  def create
    @building = Building.find(params[:building_id])
    rmrecnbr = room_params[:rmrecnbr]
    @room = Room.new(rmrecnbr: rmrecnbr)
    authorize @room
    bldrecnbr = @building.bldrecnbr
    result = get_room_info_by_rmrecnbr(bldrecnbr, rmrecnbr)
    if result['success']
      room_data = result['data']
      if Floor.find_by(name: room_data["FloorNumber"], building: @building).present?
        @floor = Floor.find_by(name: room_data["FloorNumber"], building: @building)
      else
       @floor = Floor.new(name: room_data["FloorNumber"], building: @building)
       @floor.save
      end
      @room = Room.new(rmrecnbr: room_data["RoomRecordNumber"], room_number: room_data["RoomNumber"], room_type: room_data["RoomTypeDescription"], floor: @floor)
      authorize @room
      if @room.save
        redirect_to building_path(@building), notice: "Room was successfully added to " + @floor.name + " floor."
      else
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = result['error']
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /rooms/1 or /rooms/1.json
  def destroy
    if @room.room_states.present?
      flash.now['alert'] = "The rooms has checked states - archive this room instead"
      @rooms = Room.active
    else
      @building = @room.floor.building
      if delete_room(@room)
        redirect_to building_path(@building), notice: "The room was deleted."
      else
        flash.now['alert'] = "error deleting room"
      end
    end
  end

  def archive
    session[:return_to] = request.referer
    if change_room_archived_mode(room: @room, archived: true)
      redirect_back_or_default(notice: "The room was archived")
    else
      @rooms = Room.active
    end
  end

  def unarchive
    session[:return_to] = request.referer
    @archived = true
    if change_room_archived_mode(room: @room, archived: false)
      redirect_back_or_default(notice: "The room was unarchived")
    else
      @rooms = Room.archived
    end
  end

  def upload_images
    @room = Room.find(params[:room_id])
    @room_state = @room.room_states.find(params[:room_state_id])
    @upload_images_announcement = Announcement.find_by(location: "upload_images_form")
    authorize @room

    return unless request.post?

    files = params.dig(:room, :images)
    unless files.present?
      flash.now[:alert] = "Please select at least one image to upload."
      render :upload_images, status: :unprocessable_entity
      return
    end

    attached = @room.images.attach(files)
     if @room.invalid?
       attached&.each(&:purge)
       flash.now[:alert] = @room.errors.full_messages.to_sentence
       @room = Room.find(params[:room_id])
       render :upload_images, status: :unprocessable_entity
       return
     end

    redirect_to upload_room_images_path(room_state_id: @room_state.id, room_id: @room.id), notice: "Images uploaded successfully."
  end

  def delete_image
    @room = Room.find(params[:room_id])
    authorize @room, :delete_image?

    image = @room.images_attachments.find(params[:image_id])
    image.purge

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@room, :images_gallery),
          partial: 'rooms/images_gallery',
          locals: { room: @room }
        )
      end

      format.html do
        redirect_back fallback_location: room_path(@room), notice: 'Image deleted successfully.'
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_room
      @room = Room.find(params[:id])

      authorize @room
    end

    def delete_room(room)
      ActiveRecord::Base.transaction do
        begin
          Resource.where(room_id: room.id).delete_all
          SpecificAttribute.where(room_id: room.id).delete_all
          Note.where(room_id: room.id).delete_all
          floor = room.floor
          room.delete
          floor.delete unless floor.rooms.present?
        rescue StandardError 
          raise ActiveRecord::Rollback
          false
        end
        true
      end
    end

    def change_room_archived_mode(room:, archived:)
      ActiveRecord::Base.transaction do
        raise ActiveRecord::Rollback unless room.update(archived: archived)
        raise ActiveRecord::Rollback unless room.specific_attributes.update(archived: archived)
        raise ActiveRecord::Rollback unless room.resources.update(archived: archived)
      end
      true
    end

    # Only allow a list of trusted parameters through.
    def room_params
      params.require(:room).permit(:rmrecnbr, :room_number, :room_type, :floor_id, :archived)
    end
end
