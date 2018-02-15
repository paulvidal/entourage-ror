class PlivoController < ActionController::Base
  before_filter :validate_signature

  # https://api-reference.plivo.com/latest/ruby/plivo-xml/overview
  def sms
    # https://api-reference.plivo.com/latest/ruby/plivo-xml/request/messages
    # https://api-reference.plivo.com/latest/ruby/elements/message

    # From
    # To
    # Type: sms
    # Text
    # MessageUUID
    head :success
  end

  def call
    # CallUUID: A unique identifier for this call.
    # From: the caller's caller ID (phone with country code).
    # To: our incoming phone number (with country code).
    # CallStatus: ringing (or in-progress or completed).
    # Direction: inbound (or outbound)
    #
    # https://api-reference.plivo.com/latest/ruby/plivo-xml/request
    # https://api-reference.plivo.com/latest/ruby/elements/dial

    response = Plivo::XML::Response.new do |r|
      r.Dial(
        callbackUrl: plivo_event_url,
        callerName: "Greg",

      ) do |n|
        # n.Number '+33768037348'
        n.Number '+33768639325'
      end
    end.to_xml

    puts response

    render xml: response
  end

  def event
    # DialAction: answer or hangup or digits
    # DialALegUUID
    # DialBLegDuration
    # DialBLegBillDuration
    # DialBLegFrom
    # DialBLegTo
    p params
    head :success
  end

  def hangup
    # HangupCause
    # Duration
    # BillDuration
    p params
    head :success
  end

  private

  def validate_signature
    # https://api-reference.plivo.com/latest/ruby/plivo-xml/request/validation

    valid = Plivo::Utils.valid_signature?(
      request.url,
      request.headers['X-Plivo-Signature-V2-Nonce'].to_s,
      request.headers['X-Plivo-Signature-V2'].to_s,
      ENV['PLIVO_TOKEN'].to_s
    )

    return head :unauthorized if !valid
  end
end
