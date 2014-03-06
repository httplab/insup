require 'pathname'

class Insup::TrackedFile < Struct.new(:path, :state)
  NEW = 0
  MODIFIED = 1
  DELETED = 2

  def file_name
    Pathname.new(path).basename.to_s
  end
end
