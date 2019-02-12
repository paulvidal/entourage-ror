class SmsNotificationService
  def send_notification(phone_number, message, sms_type)
    if(ENV['SMS_PROVIDER']=='AWS')
      send_aws_sms(phone_number, message, sms_type)
    end
  end

  private
  def send_aws_sms(phone_number, message, sms_type)
    unless ENV.key?('SMS_SENDER_NAME')
      Rails.logger.warn 'No SMS has been sent. Please provide SMS_SENDER_NAME environment variables'
      return
    end

    deliveryState='Ok'
    begin
      sns = Aws::SNS::Client.new({
        region: 'eu-west-1',
        credentials: Aws::Credentials.new(ENV['ENTOURAGE_AWS_ACCESS_KEY_ID'], ENV['ENTOURAGE_AWS_SECRET_ACCESS_KEY']),
        })

      sns.set_sms_attributes(attributes: { 'DefaultSenderID' => ENV['SMS_SENDER_NAME'],'DefaultSMSType' => 'Transactional'  })

      response = sns.publish({
        phone_number: phone_number,
        message: message
      })

      if response.message_id
        Rails.logger.info "Sent SMS to #{phone_number} response=#{response.inspect}"
      else
        Rails.logger.info "Error trying to send SMS to #{phone_number} response=#{response.inspect}"
        deliveryState='Provider Error'
      end
    rescue  => e
      Rails.logger.error "Error trying to send SMS to #{phone_number} error=#{e.message}"
      deliveryState='Sending Error'
    end
    SmsDelivery.create(phone_number: phone_number, status: deliveryState, sms_type: sms_type)
  end
end
