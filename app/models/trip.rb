class Trip < ActiveRecord::Base

  belongs_to :start_station, class_name: "Station", foreign_key: "start_station_id"
  belongs_to :end_station, class_name: "Station", foreign_key: "end_station_id"
  belongs_to :date, class_name: "Weather", foreign_key: "date"

  validates :id, uniqueness: true if :id

	validates :duration, presence: true
	validates :start_date, presence: true
	validates :start_station, presence: true
	validates :end_date, presence: true
  validates :end_station, presence: true
  validates :bike_id, presence: true
  validates :subscription_type, presence: true

  def self.avg
    self.average(:duration).to_f.round(2)
  end

  def self.longest
    self.maximum(:duration)
  end

  def self.shortest
    self.minimum(:duration)
  end

  def self.most_start
    Station.find(Trip.group(:start_station_id).order(start_station_id: :desc).count.max_by {|k,v| v}.first).name
  end

  def self.most_end
    Station.find(Trip.group(:end_station_id).order(end_station_id: :desc).count.max_by {|k,v| v}.first).name
  end

  def self.by_month
    # Month by Month breakdown of number of rides with subtotals for each year.
    start_year = 2013
    month = 1
    month_hash = {}
    year_hash = {}
    12.times do
      month_hash[month] = Trip.where('extract(month from start_date) = ?', month).count
      month += 1
    end

    (Time.new.year - start_year).times do
      year_hash[start_year] = Trip.where('extract(year  from start_date) = ?', start_year).count
      start_year += 1
    end

    return_hash = {months: month_hash, years: year_hash}
  end

  def self.busiest_bike
    self.group(:bike_id).order('count_id DESC').limit(1).count(:id)
  end

  def self.least_busy_bike
    self.group(:bike_id).order('count_id ASC').limit(1).count(:id)
  end

  def self.subscription_info
    return_hash = {}
    return_hash[:customers] = self.where(subscription_type: "Customer").count
    return_hash[:subscribers] = self.where(subscription_type: "Subscriber").count

    return_hash[:customers_percentage] = ((return_hash[:customers].to_f / self.count) * 100).round(2)
    return_hash[:subscribers_percentage]  = ((return_hash[:subscribers].to_f / self.count) * 100).round(2)
    return_hash
  end

  def self.busiest_day
    self.group("DATE_TRUNC('day', start_date)").count.max_by {|k,v| v}
  end

  def self.least_busy_day
    self.group("DATE_TRUNC('day', start_date)").count.min_by {|k,v| v}
  end

  def self.ride_start_by_station(station_id)
    self.where(start_station_id: station_id).count
  end

  def self.ride_end_by_station(station_id)
    self.where(end_station_id: station_id).count
  end

  def self.destination_by_station(station_id)
    if self.where(start_station_id: station_id).group(:end_station).order('count_id DESC').limit(1).count(:id).first
        self.where(start_station_id: station_id).group(:end_station).order('count_id DESC').limit(1).count(:id).first[0].name
    else
      "no destinations"
    end
  end

  def self.origination_by_station(station_id)
    if self.where(end_station_id: station_id).group(:start_station).order('count_id DESC').limit(1).count(:id).first
        self.where(end_station_id: station_id).group(:start_station).order('count_id DESC').limit(1).count(:id).first[0].name
    else
      "no destinations?"
    end
  end

  def self.busiest_weather(date)
    Weather.find_by(date: date)
  end




end
