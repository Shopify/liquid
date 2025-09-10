# frozen_string_literal: true

require 'test_helper'

class MemoryFileSystemUnitTest < Minitest::Test
  def setup
    @files = {
      'header' => 'Welcome {{ user.name }}!',
      'footer' => '© 2023 Company',
      'nav/menu' => '<nav>Menu</nav>'
    }
    @fs = Liquid::TemplateRecorder::MemoryFileSystem.new(@files)
  end

  def test_read_existing_file
    content = @fs.read_template_file('header')
    assert_equal 'Welcome {{ user.name }}!', content
  end

  def test_read_nested_file
    content = @fs.read_template_file('nav/menu')  
    assert_equal '<nav>Menu</nav>', content
  end

  def test_read_nonexistent_file
    error = assert_raises(Liquid::FileSystemError) do
      @fs.read_template_file('nonexistent')
    end
    
    assert error.message.include?("No such template 'nonexistent'")
  end

  def test_file_exists
    assert @fs.file_exists?('header')
    assert @fs.file_exists?('nav/menu')
    refute @fs.file_exists?('nonexistent')
  end

  def test_file_paths
    paths = @fs.file_paths
    assert_equal 3, paths.length
    assert_includes paths, 'header'
    assert_includes paths, 'footer'
    assert_includes paths, 'nav/menu'
  end

  def test_file_count
    assert_equal 3, @fs.file_count
  end

  def test_add_file
    @fs.add_file('sidebar', 'Sidebar content')
    
    assert @fs.file_exists?('sidebar')
    assert_equal 'Sidebar content', @fs.read_template_file('sidebar')
    assert_equal 4, @fs.file_count
  end

  def test_remove_file
    @fs.remove_file('header')
    
    refute @fs.file_exists?('header')
    assert_equal 2, @fs.file_count
    
    assert_raises(Liquid::FileSystemError) do
      @fs.read_template_file('header')
    end
  end

  def test_clear
    @fs.clear!
    
    assert_equal 0, @fs.file_count
    assert_equal [], @fs.file_paths
    
    assert_raises(Liquid::FileSystemError) do
      @fs.read_template_file('header')
    end
  end

  def test_all_files
    all_files = @fs.all_files
    
    assert_equal @files, all_files
    
    # Should be a copy, not the original
    all_files.clear
    assert_equal 3, @fs.file_count
  end

  def test_initialize_with_nil
    fs = Liquid::TemplateRecorder::MemoryFileSystem.new(nil)
    
    assert_equal 0, fs.file_count
    assert_equal [], fs.file_paths
  end

  def test_initialize_with_empty_hash
    fs = Liquid::TemplateRecorder::MemoryFileSystem.new({})
    
    assert_equal 0, fs.file_count
    assert_equal [], fs.file_paths
  end

  def test_case_sensitive_paths
    @fs.add_file('Header', 'Different header')
    
    # Should treat 'header' and 'Header' as different files
    refute_equal @fs.read_template_file('header'), @fs.read_template_file('Header')
    assert_equal 'Welcome {{ user.name }}!', @fs.read_template_file('header')
    assert_equal 'Different header', @fs.read_template_file('Header')
  end

  def test_empty_file_content
    @fs.add_file('empty', '')
    
    assert @fs.file_exists?('empty')
    assert_equal '', @fs.read_template_file('empty')
  end

  def test_whitespace_in_paths
    @fs.add_file('path with spaces', 'Content with spaces')
    
    assert @fs.file_exists?('path with spaces')
    assert_equal 'Content with spaces', @fs.read_template_file('path with spaces')
  end
end