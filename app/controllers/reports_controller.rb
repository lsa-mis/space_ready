class ReportsController < ApplicationController
  before_action :auth_user
  before_action :set_form_values, :collect_form_params

  def index
    authorize :report, :index?

    @reports_list = [
      {title: "Number of Room Issues", url: number_of_room_issues_report_reports_path, description: "This report shows information on number of Room Issues" },
      {title: "Room Issues", url: room_issues_report_reports_path, description: "This report shows list of Room Issues" },
      {title: "Inspection Rate", url: inspection_rate_report_reports_path, description: "Calculated by dividing the number of checks a given room has by the total amount of days for a given date rage" },
      {title: "No Access", url: no_access_report_reports_path, description: "This report shows information on Rooms that were not able to be accessed" },
      {title: "No Access During Last Checks", url: no_access_for_n_times_report_reports_path, description: "This report shows information on Rooms that were not able to be accessed during several last checks" },
      {title: "Rooms not Checked during Last Days", url: not_checked_rooms_report_reports_path, description: "This report shows information on Rooms that were not checked during last days" },
      {title: "Common Attribute States", url: common_attribute_states_report_reports_path, description: "This report shows the responses to the Common Questions in the Rover form" },
      {title: "Specific Attribute States", url: specific_attribute_states_report_reports_path, description: "This report shows the responses to the Specific Questions in the Rover form" },
      # {title: "Resource States", url: resource_states_report_reports_path, description: "This report shows the responses to the Resource Questions in the Rover form" },
    ]
  end

  @show_archived = true

  # Design - For each new report:
  # 1) run the logic / activerecord query based on params
  # 2) if there is no record returned, do none of the below
  # 3) define a title for the report: @title
  # 4) calculate summary metrics in a hash of description:value pairs : @metrics
  # 5) for a basic report:
  #   a) define an array of headers/column titles: @headers
  #   b) convert the query results into an array of arrays in order same as headers: @data
  # 6) for a grouped pivot-table report (w/ dates as columns):
  #   a) set @grouped = true
  #   b) define an array of date headers: @date_headers
  #   c) define an array of all headers (indluding date headers): @headers
  #   d) convert the query results into a grouped hash of hashes: @data
  #     i) the first key should be an array of 'grouped' keys, like for e.g [zone, building, room]
  #     ii) the second key should be the date
  #     iii) the value should be the cell value
  #     iv) for e.g: @data[[Zone, Building, Room]][Date] = Value

  def number_of_room_issues_report
    authorize :report, :number_of_room_issues_report?
    @show_archived = false

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      rooms = Room.joins(floor: :building).joins(:room_tickets)
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_tickets: { created_at: start_time..end_time })
                  .group('rooms.id')
                  .select('rooms.*, COUNT(room_tickets.id) AS tickets_count')
                  .having('COUNT(room_tickets.id) > 0')
                  .order('tickets_count DESC')

      if rooms.any?
        days = (end_time.to_date - start_time.to_date).to_i + 1
        @title = 'Number of Room Issues Report'
        @metrics = {
          'Total Issues' => rooms.sum(&:tickets_count),
          'Time Range' => "#{start_time.strftime('%m/%d/%y')} - #{end_time.strftime('%m/%d/%y')} (#{days} days)",
        }
        @headers = ['Room Number', 'Building', 'Zone', 'Issues Count']
        @room_link = true
        @data = rooms.map do |room|
          [
            room,
            room.floor.building.name,
            show_zone(room.floor.building),
            room.tickets_count,
          ]
        end
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'room_issues_report.csv', type: 'text/csv' }
    end
  end

  def room_issues_report
    authorize :report, :room_issues_report?
    @show_archived = false

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      tickets = RoomTicket.includes(room: { floor: :building }).where(created_at: start_time..end_time).where(room: { archived: archived })
              .where(buildings: { id: building_id, zone_id: zone_id })
              .order(created_at: :desc)

      if tickets.any?
        days = (end_time.to_date - start_time.to_date).to_i + 1
        @title = 'Room Issues Report'
        @metrics = {
          'Total Issues' => tickets.count,
          'Time Range' => "#{start_time.strftime('%m/%d/%y')} - #{end_time.strftime('%m/%d/%y')} (#{days} days)"
        }
        @headers = ['Submitted On', 'Room Number', 'Building', 'Zone', 'Send to', 'Description', 'Submitted By']
        @data = tickets.map do |ticket|
          [
            show_date_with_time(ticket.created_at),
            ticket.room.room_number,
            ticket.room.floor.building.name,
            ticket.room.floor.building.zone.present? ? ticket.room.floor.building.zone.name : "",
            ticket.tdx_email,
            ticket.description.to_plain_text,
            ticket.submitted_by
          ]
        end
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'room_issues_report.csv', type: 'text/csv' }
    end
  end

  def inspection_rate_report
    authorize :report, :inspection_rate_report?
    
    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      rooms = Room.left_outer_joins(floor: { building: :zone })
                  .joins(:room_states)
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_states: { updated_at: start_time..end_time })
                  .group('rooms.id')
                  .select('rooms.*')
                  .select('COUNT(room_states.id) AS room_check_count')
                  .order('room_check_count DESC')

      rooms_no_room_state = archived ? [] : Room.active
                                                .left_outer_joins(:room_states)
                                                .joins(floor: { building: :zone })
                                                .where(buildings: { id: building_id, zone_id: zone_id })
                                                .where(room_states: { id: nil })
                                                .where.not(id: rooms.map(&:id))
                                                .select('rooms.*')
                                                .select('0 AS room_check_count')
                                                .order('rooms.room_number')

      if rooms.any?
        days = (end_time.to_date - start_time.to_date).to_i + 1

        rooms = rooms + rooms_no_room_state

        @title = 'Inspection Rate Report'
        @metrics = {
          'Total room checks' => rooms.sum(&:room_check_count),
          'Time Range' => "#{start_time.strftime('%m/%d/%y')} - #{end_time.strftime('%m/%d/%y')} (#{days} days)",
        }
        @headers = ['Room Number', 'Building', 'Zone', '# Checks', 'Inspection Rate']
        @room_link = true
        @data = rooms.map do |room|
          [
            room,
            room.floor.building.name,
            show_zone(room.floor.building),
            room.room_check_count,
            "#{(room.room_check_count.to_f / days * 100).round(2)}%"
          ]
        end
        @data = @data.sort_by { |k| [k[4], k[2], k[0]] }.reverse!
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'inpection_rate_report.csv', type: 'text/csv' }
    end
  end

  def no_access_report
    authorize :report, :no_access_report?

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      rooms = Room.joins(floor: :building).joins(:room_states)
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_states: { updated_at: start_time..end_time })
                  .where(room_states: { is_accessed: false })
                  .group('rooms.id')
                  .select('rooms.*')
                  .select('COUNT(room_states.id) AS na_states_count')
                  .select('array_agg(room_states.updated_at) as na_states_dates')
                  .select('array_agg(room_states.no_access_reason) as na_states_reasons')
                  .having('COUNT(room_states.id) > 0')
                  .order('na_states_count DESC')

      if rooms.any?
        days = (end_time.to_date - start_time.to_date).to_i + 1
        @title = 'No Access Report'
        @metrics = {
          'Total No Access Count' => rooms.sum(&:na_states_count),
          'Time Range' => "#{start_time.strftime('%m/%d/%y')} - #{end_time.strftime('%m/%d/%y')} (#{days} days)"
        }
        @headers = ['Room Number', 'Building', 'Zone', 'No Access Count', 'Dates and Reasons for No Access (Most Recent 5)']
        @room_link = true
        @data = rooms.map do |room|
          [
            room,
            room.floor.building.name,
            show_zone(room.floor.building),
            room.na_states_count,
            room.na_states_dates.zip(room.na_states_reasons)
                .sort_by { |date, _reason| date }
                .reverse
                .first(5)
                .map { |date, reason| "#{date.strftime('%m/%d/%y')} (#{reason})" }
                .join(', ')
          ]
        end
        @data = @data.sort_by { |k| [k[3], k[1], k[0]] }.reverse!
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'no_access_report.csv', type: 'text/csv' }
    end
  end

  def no_access_for_n_times_report
    authorize :report, :no_access_for_n_times_report?

    @need_dates = false
    @number_label = "Number of Last Checks:"
    if params[:commit]
      zone_id, building_id, archived, number = collect_form_with_number_params

      rooms = Room.joins(floor: :building)
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })

      if rooms.any?
        result_rooms = []
        rooms.each do |room|
          states = room.room_states.order('updated_at DESC').limit(number).pluck(:is_accessed)
          if states.length == number && (states.all? false)
            result_rooms << room
          end
        end
        if result_rooms.present?
          @metrics = {
            'Total Rooms' => result_rooms.count
          }
          @title = 'No Access for ' + number.to_s + ' Days Report'
          @headers = ['Room Number', 'Building', 'Zone']
          @room_link = true
          @data = result_rooms.map do |room|
            [
              room,
              room.floor.building.name,
              show_zone(room.floor.building)
            ]
          end
          @data = @data.sort_by { |k| [k[1], k[0]] }
        end
      end
    end
    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'no_access_for_n_times_report.csv', type: 'text/csv' }
    end
  end

  def not_checked_rooms_report
    authorize :report, :not_checked_rooms_report?

    @need_dates = false
    @number_label = "Number of Days:"
    if params[:commit]
      zone_id, building_id, archived, number = collect_form_with_number_params

      rooms = Room.joins(floor: :building)
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where('DATE(last_time_checked) < ?', number.days.ago.to_date)
      if rooms.any?
        @metrics = {
          'Total Rooms' => rooms.count
        }
        @title = 'Not Checked for ' + number.to_s + ' Days Report'

        @headers = ['Room Number', 'Building', 'Zone']
        @room_link = true
        @data = rooms.map do |room|
          [
            room,
            room.floor.building.name,
            show_zone(room.floor.building),
          ]
        end
        @data = @data.sort_by { |k| [k[1], k[0]] }
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'not_checked_rooms_report.csv', type: 'text/csv' }
    end
  end

  def common_attribute_states_report
    authorize :report, :common_attribute_states_report?
    @show_archived = false

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      rooms = Room.left_outer_joins(floor: { building: :zone }).joins(room_states: { common_attribute_states: :common_attribute })
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_states: { updated_at: start_time..end_time })
                  .select('rooms.*')
                  .select('buildings.name AS building')
                  .select('zones.name AS zone')
                  .select('room_states.updated_at')
                  .select('common_attributes.description AS common_attribute_description')
                  .select('common_attributes.need_checkbox as need_checkbox')
                  .select('common_attribute_states.checkbox_value as checkbox_value')
                  .select('common_attribute_states.quantity_box_value as quantity_box_value')
                  .order('zones.name ASC, buildings.name ASC, rooms.room_number ASC')

      if rooms.any?
        @grouped = true
        @room_link = true
        @title = 'Common Attribute States Report'

        @date_headers = (start_time.to_date..end_time.to_date).to_a
        @headers = [ 'Room', 'Building', 'zone'] + @date_headers

        grouped_rooms = rooms.group_by { |room| room.common_attribute_description }
        @data = grouped_rooms.transform_values do |room_group|
          room_group.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |room, pivot_table|
            key = [[room.room_number, room.id], room.building, room.zone]
            value = room.need_checkbox ? (room.checkbox_value ? 'Yes' : 'No') : room.quantity_box_value
            pivot_table[key][room.updated_at.to_date] = value
          end
        end
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'common_attribute_states_report.csv', type: 'text/csv' }
    end
  end

  def specific_attribute_states_report
    authorize :report, :specific_attribute_states_report?
    @show_archived = false

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params

      rooms = Room.left_outer_joins(floor: { building: :zone }).joins(room_states: { specific_attribute_states: :specific_attribute })
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_states: { updated_at: start_time..end_time })
                  .select('rooms.*')
                  .select('buildings.name AS building')
                  .select('zones.name AS zone')
                  .select('specific_attributes.description AS specific_attribute_description')
                  .select('room_states.updated_at')
                  .select('specific_attributes.need_checkbox as need_checkbox')
                  .select('specific_attribute_states.checkbox_value as checkbox_value')
                  .select('specific_attribute_states.quantity_box_value as quantity_box_value')
                  .order('zones.name ASC, buildings.name ASC, rooms.room_number ASC, specific_attributes.description ASC')

      if rooms.any?
        @grouped = true
        @title = 'Specific Attribute States Report'

        @date_headers = (start_time.to_date..end_time.to_date).to_a
        @headers = ['Specific Attribute'] + @date_headers

        grouped_rooms = rooms.group_by { |room| ["#{room.zone} | #{room.building} |",  room] }
        @group_link = true
        @data = grouped_rooms.transform_values do |room_group|
          room_group.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |room, pivot_table|
            key = ["#{room.specific_attribute_description}"]
            value = room.need_checkbox ? (room.checkbox_value ? 'Yes' : 'No') : room.quantity_box_value
            pivot_table[key][room.updated_at.to_date] = value
          end
        end
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'specific_attribute_states_report.csv', type: 'text/csv' }
    end
  end

  def resource_states_report
    authorize :report, :resource_states_report?
    @show_archived = false

    @resource_types = AppPreference.find_by(name: "resource_types").value.split(",").each(&:strip!)

    if params[:commit]
      zone_id, building_id, start_time, end_time, archived = collect_form_params
      resource_type = params[:resource_type].presence

      rooms = Room.left_outer_joins(floor: { building: :zone }).joins(room_states: { resource_states: :resource })
                  .where(archived: archived)
                  .where(buildings: { id: building_id, zone_id: zone_id })
                  .where(room_states: { updated_at: start_time..end_time })
                  .select('rooms.*')
                  .select('buildings.name AS building')
                  .select('zones.name AS zone')
                  .select('resources.name AS resource_name')
                  .select("resources.resource_type as resource_type")
                  .select('room_states.updated_at')
                  .select('resource_states.is_checked as check_value')
                  .where("resources.resource_type ILIKE ?", "%#{resource_type}%") # need to do a manual query for this because of circular definition of resources
                  .order('zones.name ASC, buildings.name ASC, rooms.room_number ASC, resources.name ASC')

      if rooms.any?
        @grouped = true
        @title = 'Resource States Report'

        @date_headers = (start_time.to_date..end_time.to_date).to_a
        @headers = ['Resource'] + @date_headers

        grouped_rooms = rooms.group_by { |room| ["#{room.zone} | #{room.building} |", room] }
        @group_link = true
        @data = grouped_rooms.transform_values do |room_group|
          room_group.each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |room, pivot_table|
            key = ["#{room.resource_name} (#{room.resource_type})"]
            value = room.check_value ? 'Yes' : 'No'
            pivot_table[key][room.updated_at.to_date] = value
          end
        end
      end
    end

    respond_to do |format|
      format.html
      format.csv { send_data csv_data, filename: 'resource_states_report.csv', type: 'text/csv' }
    end
  end

  private

  def set_form_values
    @zones = Zone.all.order(:name).map { |z| [z.name, z.id] }
    @buildings = Building.active.where.not(zone: nil).map { |building| [building.zone_id, building.name, building.id] }
    @need_dates = true
  end

  def collect_form_params
    zone_id = params[:zone_id].presence || Zone.all.pluck(:id).push(nil)
    building_id = params[:building_id].presence || Building.all.pluck(:id).push(nil)
    start_time = params[:from].present? ? Date.parse(params[:from]).beginning_of_day : DateTime.new(0)
    end_time = params[:to].present? ? Date.parse(params[:to]).end_of_day : DateTime::Infinity.new
    archived = params[:archived].to_s == "1"
    [zone_id, building_id, start_time, end_time, archived]
  end

  def collect_form_with_number_params
    zone_id = params[:zone_id].presence || Zone.all.pluck(:id).push(nil)
    building_id = params[:building_id].presence || Building.all.pluck(:id).push(nil)
    number = params[:number].presence.to_i || 1
    archived = params[:archived].to_s == "1"
    [zone_id, building_id, archived, number]
  end


  def csv_data
    CSV.generate(headers: true) do |csv|
      next csv << ["No data found"] if !@data

      csv << [@title]
      csv << []
      @metrics && @metrics.each { |desc, value| csv << [desc, value] }

      if @grouped
        @data.each do |group, pivot_table|
          csv << []
          csv << (@group_link && group.is_a?(Array) ? ["#{group[0]} #{group[1].room_number}"] : [group])
          csv << @headers
          pivot_table.each do |keys, record|
            keys = [keys[0][0]] + keys[1..] if @room_link && keys[0].is_a?(Array)
            csv << keys + @date_headers.map { |date| record[date] }
          end          
        end
      else
        csv << []
        csv << @headers
        @data.each do |row|
          if @room_link
            row[0] = row[0].room_number
          end
          csv << row
        end
      end
    end
  end
end
