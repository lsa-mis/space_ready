# == Schema Information
#
# Table name: rooms
#
#  id                :bigint           not null, primary key
#  rmrecnbr          :string
#  room_number       :string
#  room_type         :string
#  floor_id          :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  last_time_checked :datetime
#  archived          :boolean          default(FALSE)
#
class Room < ApplicationRecord
  belongs_to :floor
  has_many :resources
  has_many :room_tickets
  has_many :specific_attributes
  has_many :active_specific_attributes, -> { active }, class_name: 'SpecificAttribute'
  has_many :archived_specific_attributes, -> { archived }, class_name: 'SpecificAttribute'
  has_many :active_resources, -> { active }, class_name: 'Resource'
  has_many :archived_resources, -> { archived }, class_name: 'Resource'
  has_many :room_states
  has_many :notes
  has_many_attached :images

  validates :rmrecnbr, presence: true, uniqueness: true
  validates :room_number, :room_type, presence: true
  validate :acceptable_image

  accepts_nested_attributes_for :specific_attributes

  scope :active, -> { where(archived: false).order(:room_number) }
  scope :active_in_zones, -> { active.joins(floor: :building).where.not(buildings: { zone_id: nil }) }
  scope :archived, -> { where(archived: true).order(:room_number) }

  def full_name
    archived = self.archived ? " - archived" : ""
    [floor.building.nick_name, room_number, archived].join(' ')
  end

  def room_state?
    RoomState.find_by(room_id: self).present?
  end

  def acceptable_image
    return unless images.attached?

    acceptable_types = ["image/jpg", 
    "image/jpeg",
    "image/png",
    "image/heic"]
    
    images.each do |image|
      unless image.blob.byte_size <= 10.megabyte
        errors.add(:base, "the image is too big")
      end

      unless acceptable_types.include?(image.content_type)
        errors.add(:base, "the image has incorrect file type")
      end
    end
  end

end
