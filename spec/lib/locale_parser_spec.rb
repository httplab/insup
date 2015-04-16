describe LocaleParser do
  it 'works correctly' do
    samples = {
      'en' => 'en',
      'en-US' => 'en-US',
      'en_US' => 'en-US',
      'en_US.UTF-8' => 'en-US',
      'EN' => 'en',
      'enUS' => 'en',
      'RU' => 'en',
      'RUru' => 'en'
    }

    samples.each do |k, v|
      expect(LocaleParser.locale(k)).to eq(v)
    end
  end
end
