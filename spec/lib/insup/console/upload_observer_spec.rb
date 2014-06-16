require_relative '../../../spec_helper'

describe Insup::Console::UploadObserver do

  it 'should handle all types of events' do
    @observer = described_class.new

    [Insup::Uploader::CREATING_FILE,
    Insup::Uploader::CREATED_FILE,
    Insup::Uploader::MODIFYING_FILE,
    Insup::Uploader::MODIFIED_FILE,
    Insup::Uploader::DELETING_FILE,
    Insup::Uploader::DELETED_FILE,
    Insup::Uploader::BATCH_UPLOADING_FILES,
    Insup::Uploader::BATCH_UPLOADED_FILES,
    Insup::Uploader::ERROR
    ].each do |event|
      expect {@observer.update(event, Insup::TrackedFile.new('path/to.file'))}.not_to raise_error
    end
  end

end
