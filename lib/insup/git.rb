class Insup
  class Git
    def initialize(base)
      Dir.chdir(base) do
        `git status 2>&1`

        if $CHILD_STATUS.exitstatus == 128
          fail Insup::Exceptions::NotAGitRepositoryError, 'Not a GIT repository'
        end
      end

      @base = base
    end

    def status
      files = ls_files
      ignore = ignored_files

      Dir.chdir(@base) do
        Dir.glob('**/*', File::FNM_DOTMATCH) do |file|
          next if files[file] || File.directory?(file) || ignore.include?(file) || file =~ %r{^.git\/.+}
          files[file] = { path: file, untracked: true }
        end
      end

      diff_files.each do |path, data|
        files[path] ? files[path].merge!(data) : files[path] = data
      end

      diff_index('HEAD').each do |path, data|
        files[path] ? files[path].merge!(data) : files[path] = data
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
        info, file = line.split("\t")
        _mode, _sha, stage = info.split
        hsh[file] = { path: file, stage: stage }
      end
      hsh
    end

    def command_lines(cmd, opts = [])
      command(cmd, opts).split("\n")
    end

    def command(cmd, opts = [])
      opts = [opts].flatten.map { |s| escape(s) }.join(' ')
      git_cmd = "git #{cmd} #{opts} 2>&1"
      out = nil

      if Dir.getwd != @base
        Dir.chdir(@base) { out = `#{git_cmd}` }
      else
        out = `#{git_cmd}`
      end

      if $CHILD_STATUS.exitstatus > 0
        return '' if $CHILD_STATUS.exitstatus == 1 && out == ''
        fail Insup::Exceptions::InsupError, 'Git error'
      end
      out
    end

    def diff_files
      diff_as_hash('diff-files')
    end

    def diff_index(treeish)
      diff_as_hash('diff-index', treeish)
    end

    def diff_as_hash(diff_command, opts = [])
      command_lines(diff_command, opts).each_with_object({}) do |line, memo|
        info, file = line.split("\t")
        _mode_src, _mode_dest, _sha_src, _sha_dest, type = info.split

        memo[file] = {
          path: file,
          type: type
        }
      end
    end

    def escape(s)
      "'#{s && s.to_s.gsub('\'', '\'"\'"\'')}'"
    end
  end
end
