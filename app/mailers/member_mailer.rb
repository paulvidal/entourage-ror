class MemberMailer < ActionMailer::Base
  default from: "contact@entourage.social"
  add_template_helper(OrganizationHelper)

  def tour_report(tour)
    @tour = tour
    @user = tour.user

    exporter = ExportServices::TourExporter.new(tour: tour)
    attachments['tour_points.csv'] = File.read(exporter.export_tour_points)
    attachments['encounters.csv'] = File.read(exporter.export_encounters)

    mail(to: @user.email, subject: 'Résumé de la maraude')
  end
  
  def poi_report(poi, user, message)
    if ENV.key? "POI_REPORT_EMAIL"
      @poi = poi
      @user = user
      @message = message
    
      mail(to: ENV["POI_REPORT_EMAIL"], subject: 'Correction de POI')
    else
      logger.warn "Could not deliver POI report. Please provide POI_REPORT_EMAIL as an environment variable".red
    end
  end

  def registration_request_accepted(user)
    @user = user
    mail(to: @user.email, subject: "Votre demande d'adhésion à la plateforme Entourage a été acceptée")
  end
end
