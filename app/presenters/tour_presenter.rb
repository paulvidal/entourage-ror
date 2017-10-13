class TourPresenter
  attr_reader :tour

  include ActionView::Helpers
  delegate :id,
           :tour_type,
           :status,
           :vehicle_type,
           :organization_name,
           :organization_description,
           :length,
           :user_id,
           :created_at,
           to: :tour

  def initialize(tour:)
    @tour = tour
  end

  def tour_points
    tour.tour_points.ordered.map {|point| {long: point.longitude, lat: point.latitude} }
  end

  def simplified_tour_points
    tour.simplified_tour_points.ordered.map {|point| {long: point.longitude, lat: point.latitude} }
  end

  def kalman_tour_points
    points = tour.tour_points.ordered.to_a
    return simplified_tour_points if points.any? { |p| p.accuracy.nil? }

    filter = KalmanLatLng.new
    points.map do |point|
      lat, lng = filter.process(
        lat: point.latitude,
        lng: point.longitude,
        accuracy: point.accuracy,
        timestamp: point.passing_time
      )
      {long: lng, lat: lat}
    end
  end

  def can_see_detail?
    Authentication::UserTourAuthenticator.new(user: current_user, tour: @tour).allowed_to_see?
  end

  def duration
    return "-" if tour.tour_points.count == 0

    duration = (tour.tour_points.last.created_at - tour.tour_points.first.created_at).to_i
    if duration < 3600
      "environ "+distance_of_time_in_words(duration)
    else
      hours = duration/3600
      minutes = (duration % 3600)/60
      "#{pluralize(hours, "heure")} #{pluralize(minutes, "minute")}"
    end
  end

  def distance
    number_to_human(tour.length, precision: 4, units: {unit: "m", thousand: "km"})
  end

  def tour_summary(current_user)
    summary_text = "#{tour.user.full_name} a réalisé une maraude de #{duration}"
    summary_text += " et a rencontré #{pluralize tour.encounters.size, 'personne'}" if tour.encounters.size > 0
    if Authentication::UserTourAuthenticator.new(user: current_user, tour: tour).allowed_to_see?
      link_to summary_text, Rails.application.routes.url_helpers.tour_path(tour)
    else
      summary_text
    end
  end

  def self.color(total:, current:)
    start_color = "1d5a13".to_i(16)
    end_color = "3db927".to_i(16)
    step = (end_color-start_color)/total
    "#"+(start_color + step*current).to_s(16)
  end

  def start_time
    @start_time ||= tour.created_at.try(:strftime, "%H:%M")
  end

  def end_time
    @end_time ||= tour.closed_at.try(:strftime, "%H:%M")
  end

  # https://stackoverflow.com/a/15657798/1003545
  class KalmanLatLng
    MIN_ACCURACY = 1 # meters

    def initialize(q = 3) # meters per second
      @q = q # free parameter. describes how quickly the accuracy decays in the absence of any new location estimates
      @variance = nil # P matrix. NB: units irrelevant, as long as same units used throughout
    end

    # accuracy: standard deviation error in meters
    # timestamp: time of measurement in seconds
    def process(lat:, lng:, accuracy:, timestamp:)
      accuracy = [MIN_ACCURACY, accuracy].max

      if @variance.nil?
        # if variance is nil, object is unitialised, so initialise with current values
        @timestamp = timestamp
        @lat = lat
        @lng = lng
        @variance = accuracy * accuracy
      else
        # else apply Kalman filter methodology
        time_increase = timestamp - @timestamp
        # time has moved on, so the uncertainty in the current position increases
        if time_increase > 0
          @variance += time_increase * @q * @q
          @timestamp = timestamp
        end

        # Kalman gain matrix K = Covarariance * Inverse(Covariance + MeasurementVariance)
        # NB: because K is dimensionless, it doesn't matter that variance has different units to lat and lng
        k = @variance / (@variance + accuracy * accuracy)
        # apply K
        @lat += k * (lat - @lat)
        @lng += k * (lng - @lng)
        # new Covarariance  matrix is (IdentityMatrix - K) * Covarariance
        @variance = (1 - k) * @variance;
      end

      [@lat, @lng]
    end
  end
end