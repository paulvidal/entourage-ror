module Storage
  class Bucket
    def initialize(bucket_name)
      Aws.config.update({
                            region: 'eu-west-1',
                            credentials: Aws::Credentials.new(ENV['ENTOURAGE_AWS_ACCESS_KEY_ID'], ENV['ENTOURAGE_AWS_SECRET_ACCESS_KEY']),
                        })
      @bucket = Aws::S3::Bucket.new(bucket_name)
    end

    def url_for(key:, extra: {})
      expire = extra[:expire] || 3600
      bucket.object(key).presigned_url(:get, expires_in: expire)
    end

    private
    attr_reader :bucket
  end
end