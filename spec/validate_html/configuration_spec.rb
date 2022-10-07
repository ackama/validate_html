RSpec.describe ValidateHTML::Configuration do
  describe '#raise_on_invalid_html' do
    it 'defaults to true' do
      expect(subject.raise_on_invalid_html).to be true
    end

    it 'can be changed to false' do
      subject.raise_on_invalid_html = false
      expect(subject.raise_on_invalid_html).to be false
    end

    it 'has a predicate alias' do
      expect(subject.method(:raise_on_invalid_html))
        .to eq subject.method(:raise_on_invalid_html?)
    end
  end

  describe '#remember_messages' do
    it 'defaults to false' do
      expect(subject.remember_messages).to be false
    end

    it 'can be changed to true' do
      subject.remember_messages = true
      expect(subject.remember_messages).to be true
    end

    it 'has a predicate alias' do
      expect(subject.method(:remember_messages))
        .to eq subject.method(:remember_messages?)
    end
  end

  describe '#ignored_errors' do
    it 'defaults to empty array' do
      expect(subject.ignored_errors).to eq []
    end

    it 'can be written' do
      subject.ignored_errors = ['unavoidable upstream error']
      expect(subject.ignored_errors).to eq ['unavoidable upstream error']
    end
  end

  describe '#ignored_paths' do
    it 'defaults to empty array' do
      expect(subject.ignored_paths).to eq []
    end

    it 'can be written' do
      subject.ignored_paths = ['/admin']
      expect(subject.ignored_paths).to eq ['/admin']
    end
  end

  describe '#environments' do
    it 'defaults to development and test' do
      expect(subject.environments).to eq ["development", "test"]
    end

    it 'can be written' do
      subject.environments = ['development', 'test', 'staging']
      expect(subject.environments).to eq ['development', 'test', 'staging']
    end
  end

  describe '#snapshot_path' do
    it 'defaults to system tmp dir when no rails' do
      allow(Dir).to receive('mktmpdir').and_return('/my/tmp/dir')
      hide_const('Rails')
      expect(subject.snapshot_path).to eq Pathname.new('/my/tmp/dir')
    end

    it 'defaults to Rails.root tmp dir when rails' do
      require 'rails'

      allow(Rails).to receive(:root).and_return(Pathname.new('/my/rails/dir'))
      expect(subject.snapshot_path).to eq Pathname.new('/my/rails/dir/tmp/invalid_html')
    end

    it 'can be written with a string' do
      subject.snapshot_path = '/my/tmp/dir'
      expect(subject.snapshot_path).to eq Pathname.new('/my/tmp/dir')
    end

    it 'can be written with a pathname' do
      subject.snapshot_path = Pathname.new('/my/tmp/dir')
      expect(subject.snapshot_path).to eq Pathname.new('/my/tmp/dir')
    end
  end
end
