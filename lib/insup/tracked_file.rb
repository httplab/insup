require 'pathname'
# Represents a tracked file
class Insup
  class TrackedFile
    NEW = 0
    MODIFIED = 1
    DELETED = 2
    UNSURE = 3

    attr_reader :path, :state

    # Requires path to a tracked file relative to a base directory
    def initialize(path, state = NEW)
      @path = path

      if Pathname.new(path).absolute?
        fail Insup::Exceptions::InsupError, "Path must be relative. #{path} given."
      end

      @state = state
    end

    # Returns only the filename of the file
    def file_name
      File.basename(@path)
    end

    # Given the absolute path of a base directory, returns the absolute path of the file.
    def absolute_path(base)
      unless Pathname.new(base).absolute?
        fail Insup::Exceptions::InsupError, 'Base path must be absolute. #{base} given.'
      end

      File.expand_path(@path, base)
    end

    def exist?(base)
      File.exist?(absolute_path(base))
    end

    def new?
      state == NEW
    end

    def modified?
      state == MODIFIED
    end

    def deleted?
      state == DELETED
    end

    def unsure?
      state == UNSURE
    end
  end
end
