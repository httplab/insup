module Insup::Exceptions
  InsupError = Class.new(StandardError)
  UploaderError = Class.new(InsupError)
  NotAGitRepositoryError = Class.new(InsupError)
end
