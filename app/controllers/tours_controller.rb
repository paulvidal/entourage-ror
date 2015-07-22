class ToursController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def create
    @tour = Tour.new(tour_params)
    if @tour.save
      render "show", status: 201
    else
      render '400', status: 400
    end
  end

  def show
    if @tour = Tour.find_by(id: params[:id])
      render status: 200
    else
      @id = params[:id]
      render '404', status: 404
    end
  end

  def index
    @tours = Tour.all
    render status: 200
  end

  def tour_params
    params.require(:tour).permit(:tour_type)
  end

end