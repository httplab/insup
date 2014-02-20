require 'listen'
require 'colorize'

class ListenTracker < Rad::Tracker

  def get_changes
    nil
  end


  def listen &block
    return if @listener

    # @listener = Listen.to(tracked_locations) do |modified, added, removed|
    @listener = Listen.to(tracked_locations) do |changes|
      puts changes
      # flags = {}

      # added.each do |file|
      #   flags[file] = flags[file] ? flags[file] | 4 : 4
      # end

      # modified.each do |file|
      #   flags[file] = flags[file] ? flags[file] | 2 : 2
      # end

      # removed.each do |file|
      #   flags[file] = flags[file] ? flags[file] | 1 : 1
      # end

      # res = []

      # flags.each do |file,flags|
      #   case flags
      #   when 1
      #     res << Rad::TrackedFile.new(file, Rad::TrackedFile::DELETED)
      #   when 2
      #     res << Rad::TrackedFile.new(file, Rad::TrackedFile::MODIFIED)
      #   when 3
      #     res << Rad::TrackedFile.new(file, Rad::TrackedFile::DELETED)
      #   when 4
      #     res << Rad::TrackedFile.new(file, Rad::TrackedFile::NEW)
      #   when 5
      #     if File.exist?(file)
      #       puts "#{file} exists!"
      #       res << Rad::TrackedFile.new(file, Rad::TrackedFile::MODIFIED)
      #     end
      #   when 6
      #     res << Rad::TrackedFile.new(file, Rad::TrackedFile::NEW)
      #   when 7
      #     if File.exist?(file)
      #       puts "#{file} exists!"
      #       res << Rad::TrackedFile.new(file, Rad::TrackedFile::MODIFIED)
      #     end
      #   end
      # end

      # yield res

      # puts modified.to_s.yellow
      # puts added.to_s.green
      # puts removed.to_s.red

    end

    @listener.start_new
  end


  def stop
    if @listener
      @listener.stop
    end
  end

end
