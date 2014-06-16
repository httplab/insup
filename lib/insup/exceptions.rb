module Insup::Exceptions
  InsupError = Class.new(StandardError)
  UploaderError = Class.new(InsupError)
  RecoverableUploaderError = Class.new(UploaderError)
  FatalUploaderError = Class.new(UploaderError)
  NotAGitRepositoryError = Class.new(InsupError)
end
