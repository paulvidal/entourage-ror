module Api
  module V1
    class AnnouncementsController < Api::V1::BaseController
      skip_before_filter :authenticate_user!, only: [:icon, :avatar, :image]
      skip_before_filter :ensure_community!,  only: [:icon, :avatar, :image]
      allow_anonymous_access only: [:redirect]

      def icon
        icon = {
          2 => :heart,
          3 => :pin,
          4 => :video,
          5 => :megaphone,
          6 => :megaphone,
          7 => :trophy,
          8 => :heart,
          9 => :heart,
          10 => :heart,
          11 => :trophy,
          12 => :text,
          13 => :megaphone,
          14 => :heart,
          15 => :megaphone,
          16 => :pin,
          17 => :heart,
          18 => :video,
          19 => :megaphone,
          20 => :video,
          21 => :heart,
          22 => :megaphone,
          23 => :megaphone,
          24 => :heart,
          25 => :video,
          26 => :megaphone,
          27 => :heart,
          28 => :video,
          29 => :text,
          30 => :megaphone,
          31 => :pin,
          32 => :video,
          33 => :heart,
          34 => :heart,
          35 => :megaphone,
          36 => :video,
          37 => :trophy,
          38 => :video,
          39 => :megaphone,
          40 => :megaphone,
          41 => :megaphone,
          42 => :megaphone,
          43 => :megaphone,
          44 => :megaphone,
        }[params[:id].to_i]

        redirect_to view_context.asset_url("assets/announcements/icons/#{icon}.png")
      end

      def avatar
        avatar =
          case params[:id].to_i
          when 12
            'apero.png'
          else
            '1.jpg'
          end

        redirect_to view_context.asset_url("assets/announcements/avatars/#{avatar}")
      end

      def image
        image = {
          10 => 'guillaume.jpg',
          11 => 'action.jpg',
          13 => 'ambassadors.jpg',
          14 => 'collecte-2018.jpg',
          16 => 'noel.jpg',
          17 => '2.png',
          18 => 'scb.jpg',
          19 => 'grand-froid.png?2',
          20 => 'paroles-de-femmes.jpg',
          21 => 'talents-2018.jpg',
          22 => 'scb.jpg',
          23 => 'reseaux-sociaux.jpg',
          24 => 'webapp.jpg',
          25 => 'video-eric.jpg',
          26 => 'paperboard.jpg',
          27 => 'conversation.jpg',
          28 => 'video-nolwenn.jpg',
          29 => 'conversation-2.jpg',
          30 => 'ordinateur.jpg',
          31 => '31.jpg',
          32 => '32.jpg',
          33 => '33.jpg',
          34 => '34.jpg',
          35 => '35.jpg',
          36 => '36.jpg',
          37 => '37.jpg',
          38 => '38.jpg',
          39 => 'service-civique.jpg',
          40 => 'service-civique.jpg',
          41 => 'service-civique.jpg',
          42 => 'service-civique.jpg',
          43 => 'conversation-2.jpg',
          44 => 'linkedout.jpg',
        }[params[:id].to_i]

        return render nothing: true, status: :not_found if image.nil?

        redirect_to view_context.asset_url("assets/announcements/images/#{image}")
      end

      def redirect
        id = params[:id].to_i

        case id
        when 2
          url = "#{ENV['WEBSITE_URL']}/don"

          if current_user
            url +=
              "?firstname=#{current_user.first_name}" +
              "&lastname=#{current_user.last_name}" +
              "&email=#{current_user.email}" +
              "&external_id=#{current_user.id}" +
              "&utm_medium=APP" +
              "&utm_campaign=DEC2017"

            if current_user.id % 2 == 0
              url += "&utm_source=APP-S1"
            else
              url += "&utm_source=APP-S2"
            end
          end
        when 3
          user_id =
            if current_user
              UserServices::EncodedId.encode(current_user.id)
            else
              "anonymous"
            end
          url = "https://entourage-asso.typeform.com/to/WIg5A9?user_id=#{user_id}"
        when 4
          url = "http://www.simplecommebonjour.org/?p=153"
        when 6
          url = "https://blog.entourage.social/2018/01/15/securite-et-moderation/"
        when 7
          url = "https://blog.entourage.social/2018/03/02/top-5-des-actions-reussies/"
        when 8
          url = "https://blog.entourage.social/2017/07/28/le-comite-de-la-rue-quest-ce-que-cest/"
        when 9
          url = "https://blog.entourage.social/2018/05/17/fete-des-voisins-2018-invitons-aussi-nos-voisins-sdf/"
        when 11
          url = "https://blog.entourage.social/2017/04/28/quelles-actions-faire-avec-entourage/#site-content"
        when 12
          url = "https://blog.entourage.social/2018/07/27/roya-michael-il-avait-besoin-dun-semblant-de-famille/"
        when 13
          url = "https://www.entourage.social/devenir-ambassadeur"
        when 14
          url = "https://entourage.iraiser.eu/mon-don/~mon-don"
        when 15
          url = "https://blog.entourage.social/2018/11/30/noel-solidaire-faisons-tous-le-calendrier-de-lavent-inverse/"
        when 16
          url = "https://blog.entourage.social/2018/11/29/noel-solidaire-2018-aupres-des-personnes-sdf-du-benevolat-pour-le-reveillon/"
        when 17
          url = "https://www.entourage.social/"
        when 18
          url = "http://www.simplecommebonjour.org/?p=8"
        when 19
          url = "https://blog.entourage.social/2017/01/17/grand-froid-comment-aider-les-personnes-sans-abri-a-son-echelle/#site-content"
        when 20
          url = "http://www.simplecommebonjour.org/?p=12"
        when 21
          url = "https://blog.entourage.social/2019/01/02/soiree-de-noel-entourage-x-refettorio-la-rue-est-pleine-de-talents/#site-content"
        when 22
          url = "http://www.simplecommebonjour.org/"
        when 23
          url = "https://www.facebook.com/EntourageReseauCivique/"
        when 24
          url = "https://www.entourage.social/app"
        when 25
          url = "https://www.youtube.com/watch?v=AsUyal44DXk"
        when 26
          url = "http://bit.ly/2tvGgcH"
        when 27
          url = "https://blog.entourage.social/category/belles-histoires/#nav-search"
        when 28
          url = "https://www.youtube.com/watch?v=UcODKwV9bO8&list=PLwLEgqe22sVYuK9ySGExo8JfgAzlqWUV9"
        when 29
          url = "https://blog.entourage.social/2019/03/04/comment-puis-je-inviter-des-personnes-sdf-sur-le-reseau-entourage/#site-content"
        when 32
          url = "https://www.youtube.com/watch?v=QXcUptypnOY"
        when 33
          url = "https://blog.entourage.social/2017/07/06/appli-entourage-les-10-plus-belles-actions/#site-content"
        when 34
          url = "https://blog.entourage.social/2017/07/28/le-comite-de-la-rue-entourage/#site-content"
        when 36
          url = "https://www.youtube.com/watch?v=IYUo5WAZxXs"
        when 37
          url = "https://blog.entourage.social/2017/04/28/quelles-actions-faire-avec-entourage/#site-content"
        when 38
          url = "https://www.youtube.com/watch?v=Dk3bo__5dvs"
        when 39
          url = "https://www.service-civique.gouv.fr/missions/paris-creer-du-lien-social-autour-des-personnes-sans-abri"
        when 40
          url = "https://www.service-civique.gouv.fr/missions/lyon-creer-du-lien-social-autour-des-personnes-sans-abri"
        when 41
          url = "https://www.service-civique.gouv.fr/missions/lille-creer-du-lien-social-autour-des-personnes-sans-abri"
        when 42
          url = "https://www.welcometothejungle.co/fr/companies/entourage/jobs"
        when 43
          url = "https://blog.entourage.social/2017/06/19/charles-aznavour-avait-tort-la-misere-nest-pas-moins-penible-au-soleil/#site-content"
        when 44
          url = "https://www.linkedout.fr/"
        end

        begin
          uri = URI(url)
          url_params = CGI.parse(uri.query || '')
          {
            utm_source: 'app',
            utm_medium: 'announcement-card'
          }.each do |key, value|
            url_params[key] = value unless url_params.key?(key)
          end
          uri.query = URI.encode_www_form(url_params).presence
          url = uri.to_s
        rescue => e
          Raven.capture_exception(e)
        end

        unless current_user_or_anonymous.anonymous?
          mixpanel.track("Opened Announcement", { "Announcement" => id })
        end

        redirect_to url
      end
    end
  end
end
