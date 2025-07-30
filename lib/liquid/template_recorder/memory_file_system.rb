# frozen_string_literal: true

module Liquid
  class TemplateRecorder
    class MemoryFileSystem
      def initialize(file_contents_hash)
        @files = file_contents_hash || {}
      end

      # Read a template file from memory
      #
      # @param template_path [String] Path to template file
      # @return [String] Template content
      # @raise [FileSystemError] If file not found
      def read_template_file(template_path, context: nil)
        content = @files[template_path]
        
        if content.nil?
          raise Liquid::FileSystemError, "No such template '#{template_path}' in recording"
        end
        
        content
      end

      # Check if a file exists in memory
      #
      # @param template_path [String] Path to check
      # @return [Boolean] True if file exists
      def file_exists?(template_path)
        @files.key?(template_path)
      end

      # Get all available file paths
      #
      # @return [Array<String>] List of available file paths
      def file_paths
        @files.keys
      end

      # Get file count
      #
      # @return [Integer] Number of files in memory
      def file_count
        @files.length
      end

      # Add a file to memory (for testing)
      #
      # @param path [String] File path
      # @param content [String] File content
      def add_file(path, content)
        @files[path] = content
      end

      # Remove a file from memory (for testing)
      #
      # @param path [String] File path to remove
      def remove_file(path)
        @files.delete(path)
      end

      # Clear all files (for testing)
      def clear!
        @files.clear
      end

      # Get a copy of all files (for debugging)
      #
      # @return [Hash] Copy of file contents hash
      def all_files
        @files.dup
      end
    end
  end
end