require 'pry'
require 'will_paginate'
require 'will_paginate/active_record'

class BikeShareApp < Sinatra::Base
	include WillPaginate::Sinatra::Helpers

  get '/' do
    erb :home
  end

	get '/stations/new' do
		erb :new_station
	end

	get '/stations' do
		@stations = Station.all.paginate(:page => params[:page], :per_page => 30)
    @cities = City.all

		erb :station_index
	end

	post '/stations' do
    city = City.find_or_create_by(params[:city])

    params[:station][:city_id] = city.id
		Station.create(params[:station])

    if params["station"].any? {|_, v| (v.empty?) unless v.is_a?(Integer) || v.nil?}
      redirect '/stations/new'
    end

    if params["city"].any? {|_, v| (v.empty?) unless v.is_a?(Integer) || v.nil?}
      redirect '/stations/new'
    end

		redirect '/stations'
	end

  get '/stations/:id' do
		@trips = Trip
    @station = Station.find(params[:id])
    @city_name = City.find(@station.city_id).name
		@stations = Station
    erb :"stations/show"
  end

  put '/stations/:id' do
    city = City.find_or_create_by(params[:city])

    params[:station][:city_id] = city.id

    Station.update(params[:id], params[:station])
    redirect '/stations'
  end

  delete '/stations/:id' do
    Station.destroy(params[:id])
    redirect '/stations'
  end

	get '/station-dashboard' do
		@station = Station
		erb :"stations/dashboard"
	end

  get '/trips' do
    @trips = Trip.all.paginate(:page => params[:page], :per_page => 30)
    @station = Station
    erb :"trips/trip_index"
  end

  get '/trips/new' do
    @stations = Station.all

    erb :"trips/new"
  end

  post '/trips' do
    params[:trip][:duration] = (((DateTime.strptime(params[:trip][:end_date], "%Y-%m-%dT%H:%M")) - (DateTime.strptime(params[:trip][:start_date], "%Y-%m-%dT%H:%M"))) * 24 * 60 * 60).to_i
    Trip.create(params[:trip])

    redirect "/trips"
  end

  get '/trips/:id' do
    @trip = Trip.find(params[:id])
    @stations = Station.all
    erb :"trips/show"
  end

	delete '/trips/:id' do
    Trip.destroy(params[:id])
    redirect '/trips'
  end

  get '/conditions' do
    @weathers = Weather.all.paginate(:page => params[:page], :per_page => 30)
    erb :"weathers/weather_index"
  end

  get '/conditions/new' do
    erb :"weathers/new"
  end

  get '/conditions/:id' do
    @weather = Weather.find(params[:id])
    erb :"weathers/show"
  end

  post '/conditions' do
    Weather.create(params[:weather])
    redirect '/conditions'
  end

  put '/conditions/:id' do
    Weather.update(params[:id], params[:weather])
    redirect '/conditions'
  end

  delete '/conditions/:id' do
    Weather.destroy(params[:id])
    redirect '/conditions'
  end

  get '/weather-dashboard' do
    @weathers = Weather
    @trips = Trip
		x = 1.5
		@ranges = []
		1.times { @ranges << x..(x + 0.1); x += 0.1 }
    erb :"weathers/dashboard"
  end

	get '/trips-dashboard' do
		@trips = Trip
		erb :"trips/dashboard"
	end

	put '/trips/:id' do
		Trip.update(params[:id], params[:trip])
    redirect '/trips'
	end
end
