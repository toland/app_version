require 'yaml'


class AppVersion
  include Comparable

  attr_accessor :major, :minor, :patch, :milestone, :build, :branch, :committer, :build_date, :format

  [:major, :minor, :patch, :milestone, :build, :branch, :committer, :format].each do |attr|
    define_method "#{attr}=".to_sym do |value|
      instance_variable_set("@#{attr}".to_sym, value.blank? ? nil : value.to_s)
    end
  end

  # Creates a new instance of the Version class using information in the passed
  # Hash to construct the version number.
  #
  #   Version.new(:major => 1, :minor => 0) #=> "1.0"
  def initialize(args = nil)
    if args && args.is_a?(Hash)
      args.keys.reject {|key| key.is_a?(Symbol) }.each {|key| args[key.to_sym] = args.delete(key) }

      [:major, :minor].each do |param|
        raise ArgumentError.new("The #{param.to_s} parameter is required") if args[param].blank?
      end

      @major      = args[:major].to_s
      @minor      = args[:minor].to_s
      @patch      = args[:patch].to_s     unless args[:patch].blank?
      @milestone  = args[:milestone].to_s unless args[:milestone].blank?
      @build      = args[:build].to_s     unless args[:build].blank?
      @branch     = args[:branch].to_s    unless args[:branch].blank?
      @committer  = args[:committer].to_s unless args[:committer].blank?
      @format     = args[:format].to_s    unless args[:format].blank?

      unless args[:build_date].blank?
        b_date = case args[:build_date]
             when 'git-revdate'
               get_revdate_from_git
             else
               args[:build_date].to_s
             end
        @build_date = Date.parse(b_date)
      end

      @build = case args[:build]
               when 'svn'
                 get_build_from_subversion
               when 'git-revcount'
                 get_revcount_from_git
               when 'git-hash'
                 get_hash_from_git
               when nil, ''
                 nil
               else
                 args[:build].to_s
               end
    end
  end

  # Parses a version string to create an instance of the Version class.
  def self.parse(version)
    m = version.match(/(\d+)\.(\d+)(?:\.(\d+))?(?:\sM(\d+))?(?:\s\((\d+)\))?(?:\sof\s(\w+))?(?:\sby\s(\w+))?(?:\son\s(\S+))?/)

    raise ArgumentError.new("The version '#{version}' is unparsable") if m.nil?

    version = AppVersion.new :major     => m[1],
                             :minor     => m[2],
                             :patch     => m[3],
                             :milestone => m[4],
                             :build     => m[5],
                             :branch    => m[6],
                             :committer => m[7]

    if (m[8] && m[8] != '')
      date = Date.parse(m[8])
      version.build_date = date
    end

    return version
  end

  # Loads the version information from a YAML file.
  def self.load(path)
    AppVersion.new YAML::load(File.open(path))
  end

  def <=>(other)
    # if !self.build.nil? && !other.build.nil?
    #   return self.build <=> other.build
    # end

    %w(build major minor patch milestone branch committer build_date).each do |meth|
      rhs = self.send(meth) || -1
      lhs = other.send(meth) || -1

      ret = lhs <=> rhs
      return ret unless ret == 0
    end

    return 0
  end

  def to_s
    if @format
      str = eval(@format.to_s.inspect)
    else
      str = "#{major}.#{minor}"
      str << ".#{patch}" unless patch.blank?
      str << " M#{milestone}" unless milestone.blank?
      str << " (#{build})" unless build.blank?
      str << " of #{branch}" unless branch.blank?
      str << " by #{committer}" unless committer.blank?
      str << " on #{build_date}" unless build_date.blank?
    end
    str
  end

private

  def get_build_from_subversion
    if File.exists?(".svn")
      #YAML.parse(`svn info`)['Revision'].value
      match = /(?:\d+:)?(\d+)M?S?/.match(`svnversion . -c`)
      match && match[1]
    end
  end

  def get_revcount_from_git
    if File.exists?(".git")
      `git rev-list --count HEAD`.strip
    end
  end
  
  def get_revdate_from_git
    if File.exists?(".git")
      `git show --date=short --pretty=format:%cd|head -n1`.strip
    end
  end
  
  def get_hash_from_git
    if File.exists?(".git")
      `git show --pretty=format:%H|head -n1|cut -c 1-6`.strip
    end
  end
end

if defined?(Rails.root.to_s) && File.exists?("#{(Rails.root.to_s)}/config/version.yml")
  APP_VERSION = AppVersion.load "#{(Rails.root.to_s)}/config/version.yml"
end
