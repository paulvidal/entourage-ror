class RedirectionController < ActionController::Base
  def redirect
    if params[:signature] == signature(params[:url])
      redirect_to params[:url]
    else
      head status: 444
    end
  end

  private

  def signature url
    url = URI(url)
    without_params = url.dup.tap { |u| u.query = nil }.to_s
    params_keys = CGI.parse(url.query).keys.sort
    definition = [without_params, *params_keys].map { |str| Base64.strict_encode64(str) }.join(',')
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['ENTOURAGE_SECRET'], definition)[0...6]
  end
end
