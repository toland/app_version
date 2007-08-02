require 'yaml'

# A little hack to make regexs matches more readable...
# From http://pastie.caboo.se/25533
class String #:nodoc:
  alias _match match
  def match(*args)
    m = _match(args.shift)
    if m && m.length > 1
      meta = (class << m; self; end)
      args.each_with_index do |name, index|
        meta.send(:define_method, name) { self[index+1] }
      end
    end
    m
  end
end

class Version
  include Comparable

  attr_accessor :major, :minor, :patch, :milestone, :build

  # Creates a new instance of the Version class using information in the passed
  # Hash to construct the version number.
  #
  #   Version.new(:major => 1, :minor => 0) #=> "1.0"
  def initialize(args = nil)
    if args && args.is_a?(Hash)
      args.each_key {|key| args[key.to_sym] = args.delete(key) unless key.is_a?(Symbol)}
  
      [:major, :minor].each do |param|
        raise ArgumentError.new("The #{param.to_s} parameter is required") if args[param].nil?
      end

      @major = int_value(args[:major])
      @minor = int_value(args[:minor])

      if args[:patch] && int_value(args[:patch]) >= 0
        @patch = int_value(args[:patch])
      end
      
      if args[:milestone] && int_value(args[:milestone]) >= 0
        @milestone = int_value(args[:milestone])
      end

      if args[:build] == 'svn'
        @build = get_build_from_subversion
      else
        @build = args[:build] && int_value(args[:build])
      end
    end
  end

  # Parses a version string to create an instance of the Version class.
  def self.parse(version)
    m = version.match(/(\d+)\.(\d+)(?:\.(\d+))?(?:\sM(\d+))?(?:\s\((\d+)\))?/, 
											:major, :minor, :patch, :milestone, :build)

    raise ArgumentError.new("The version '#{version}' is unparsable") if m.nil?

    Version.new :major => m.major,
								:minor => m.minor,
								:patch => m.patch,
								:milestone => m.milestone,
								:build => m.build
  end

  # Loads the version information from a YAML file.
  def self.load(path)
    Version.new YAML::load(File.open(path))
  end

  def <=>(other)
    # if !self.build.nil? && !other.build.nil?
    #   return self.build <=> other.build
    # end

    %w(build major minor patch milestone).each do |meth|
      rhs = self.send(meth) || -1 
      lhs = other.send(meth) || -1

      ret = lhs <=> rhs
      return ret unless ret == 0
    end

    return 0
  end
  
  def to_s
    str = "#{major}.#{minor}" 
    str << ".#{patch}" unless patch.nil?
    str << " M#{milestone}" unless milestone.nil?
    str << " (#{build})" unless build.nil?

    str
  end

private

  def get_build_from_subversion
    if File.exists?(".svn")
      #YAML.parse(`svn info`)['Revision'].value
      match = /(?:\d+:)?(\d+)M?S?/.match(`svnversion .`)
      match && match[1]
    end
  end

  def int_value(value)
    value.to_i.abs
  end
end

if defined?(RAILS_ROOT) && File.exists?("#{RAILS_ROOT}/config/version.yml")
  APP_VERSION = Version.load "#{RAILS_ROOT}/config/version.yml"
end
