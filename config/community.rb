class Community < BasicObject
  include ::Kernel
  include ::PP::ObjectMixin if defined?(::PP)
  attr_reader :community

  @@struct = {}

  def initialize community
    @community = community
    load!
  end

  def method_missing name, *args
    super if args.any?
    return self == $1 if name =~ /^(.*)\?$/
    value = struct.send name
    if value != nil
      value
    else
      super
    end
  end

  def struct
    if ::Rails.env.development?
      load!
    else
      @struct || @@struct[community] || load!
    end
  end

  def inspect
    "#<Community #{community}>"
  end

  def == other
    case other
    when ::String, ::Symbol
      community == other.to_s
    when ::Community
      community == other.community
    else
      raise ::ArgumentError, "comparison of Community with #{other.class.name} failed"
    end
  end

  private

  def load!
    @file ||= ::File.expand_path("../communities/#{community}.yml", __FILE__)
    @@struct[community] = @struct = ::OpenStruct.new(::YAML.load_file(@file))
  rescue ::Errno::ENOENT
    raise "Community '#{community}' is not defined"
  end
end
