class Rad::TrackedFile < Struct.new(:path, :state)
  NEW = 0
  MODIFIED = 1
  DELETED = 2
end
