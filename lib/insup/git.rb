class Insup::Git

  def initialize(base)
    @base = base
  end

  def status
    files = ls_files
    ignore = ignored_files

    Dir.chdir(@base) do
      Dir.glob('**/*', File::FNM_DOTMATCH) do |file|
        next if files[file] || File.directory?(file) || ignore.include?(file) || file =~ /^.git\/.+/
        files[file] = {:path => file, :untracked => true}
      end
    end

    diff_files.each do |path, data|
      files[path] ? files[path].merge!(data) : files[path] = data
    end

    diff_index('HEAD').each do |path, data|
      files[path] ? files[path].merge!(data) : files[path] = data
    end

    files.each do |k, file_hash|
      file_hash
    end

    files
  end

  private

  def ignored_files
    command_lines('ls-files', ['--others', '-i', '--exclude-standard'])
  end

  def ls_files
    hsh = {}
    command_lines('ls-files', ['--stage']).each do |line|
      (info, file) = line.split("\t")
      (mode, sha, stage) = info.split
      file = eval(file) if file =~ /^\".*\"$/
      hsh[file] = {:path => file, :stage => stage}
    end
    hsh
  end

  def command_lines(cmd, opts = [])
    command(cmd, opts).split("\n")
  end

  def command(cmd, opts = [])
    opts = [opts].flatten.map {|s| escape(s) }.join(' ')
    git_cmd = "git #{cmd} #{opts} 2>&1"
    out = nil

    if Dir.getwd != @base
      Dir.chdir(@base) { out = `#{git_cmd}` }
    else
      out = `#{git_cmd}`
    end

    if $?.exitstatus > 0
      if $?.exitstatus == 1 && out == ''
        return ''
      end

      raise 'git error'
    end
    out
  end

  def diff_files
    diff_as_hash('diff-files')
  end

  def diff_index(treeish)
    diff_as_hash('diff-index', treeish)
  end

  def diff_as_hash(diff_command, opts=[])
    command_lines(diff_command, opts).inject({}) do |memo, line|
      info, file = line.split("\t")
      mode_src, mode_dest, sha_src, sha_dest, type = info.split

      memo[file] = {
        # :mode_index => mode_dest,
        # :mode_repo => mode_src.to_s[1, 7],
        :path => file,
        # :sha_repo => sha_src,
        # :sha_index => sha_dest,
        :type => type
      }

      memo
    end
  end

  def escape(s)
    "'#{s && s.to_s.gsub('\'','\'"\'"\'')}'"
  end

end
