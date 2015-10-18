class Location < ActiveRecord::Base
	attr_accessible  :latitude, :longitude, :time, :valid_input, :gps_speed, :drifter_name, :sensor_data, :sensor_name, :battery_level, :gps_time, :gps_tower

	def self.to_csv(options = {})
  		CSV.generate(options) do |csv|
    		csv << column_names
    		all.each do |loc|
      			csv << loc.attributes.values_at(*column_names)
    		end
  		end
	end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      location = find_by_id(row["id"]) || new
      location.attributes = row.to_hash.slice(*accessible_attributes)
      location.save!
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
    when ".xls" then Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

end

