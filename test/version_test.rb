require 'test/unit'
require 'yaml'
require 'app_version'

class VersionTest < Test::Unit::TestCase

  def setup
    @version = Version.new
    @version.major = 1
    @version.minor = 2
    @version.milestone = 3
    @version.build = 400
  end

  def test_load_from_file
    version = Version.load 'test/version.yml'
    assert_equal @version, version
  end

  def test_create_from_string
    version = Version.parse '1.2.3 (400)'
    assert_equal @version, version

    version = Version.parse '1.2 (400)'
    @version.milestone = nil
    assert_equal @version, version

    version = Version.parse '1.2'
    @version.build = nil
    assert_equal @version, version

    version = Version.parse '1.2.1'
    @version.milestone = 1
    assert_equal @version, version

    version = Version.parse '2007.200.10 (6)'
    @version.major = 2007
    @version.minor = 200
    @version.milestone = 10
    @version.build = 6
    assert_equal @version, version
    
    assert_raises(ArgumentError) { Version.parse 'This is not a valid version' }
  end

  def test_create_from_int_hash_with_symbol_keys
    version = Version.new :major => 1, :minor => 2, :milestone => 3, :build => 400
    assert_equal @version, version
  end

  def test_create_from_int_hash_with_string_keys
    version = Version.new 'major' => 1, 'minor' => 2, 'milestone' => 3, 'build' => 400
    assert_equal @version, version
  end

  def test_create_from_string_hash_with_symbol_keys
    version = Version.new :major => '1', :minor => '2', :milestone => '3', :build => '400'
    assert_equal @version, version
  end

  def test_create_from_string_hash_with_string_keys
    version = Version.new 'major' => '1', 'minor' => '2', 'milestone' => '3', 'build' => '400'
    assert_equal @version, version
  end

  def test_create_without_required_parameters
    assert_raises(ArgumentError) {
      Version.new :minor => 2, :milestone => 3, :build => 400
    }
    
    assert_raises(ArgumentError) {
      Version.new :major => 1, :milestone => 3, :build => 400
    }
  end

  def test_create_without_optional_parameters
    version = Version.new :major => 1, :minor => 2

    @version.milestone = nil
    @version.build = nil
    assert_equal @version, version    
  end

  def test_to_s
    assert_equal '1.2.3 (400)', @version.to_s
  end

  def test_to_s_with_no_milestone
    @version.milestone = nil
    assert_equal '1.2 (400)', @version.to_s
  end

  def test_to_s_with_no_build
    @version.build = nil
    assert_equal '1.2.3', @version.to_s
  end

  def test_to_s_with_no_build_or_milestone
    @version.milestone = nil
    @version.build = nil
    assert_equal '1.2', @version.to_s
  end
end
