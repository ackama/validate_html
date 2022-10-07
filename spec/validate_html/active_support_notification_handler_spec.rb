require 'spec_helper'

RSpec.describe ValidateHTML::ActiveSupportNotificationHandler do
  let(:snapshot_path) { Pathname.new(__dir__).join('../tmp/test_snapshots') }

  describe '.call' do
    it "validates turbo html" do
      stub_config(snapshot_path: snapshot_path)

      payload = {
        channel_class: 'Turbo::StreamsChannel',
        data: '<strong><em>Very Emphasized</strong></em>'
      }

      expect { ValidateHTML::ActiveSupportNotificationHandler.call(nil, nil, nil, nil, payload) }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{File.dirname(__dir__)}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

            1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
            <strong><em>Very Emphasized</strong></em>
                                       ^
            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
          MESSAGE
      )
    end

    it "ignores non-turbo payloads" do
      stub_config(snapshot_path: snapshot_path)

      payload = {
        channel_class: 'something else',
        data: '<strong><em>Very Emphasized</strong></em>'
      }

      expect { ValidateHTML::ActiveSupportNotificationHandler.call(nil, nil, nil, nil, payload) }
        .to_not raise_error
    end

    it "ignores null payloads" do
      stub_config(snapshot_path: snapshot_path)

      payload = nil

      expect { ValidateHTML::ActiveSupportNotificationHandler.call(nil, nil, nil, nil, payload) }
        .to_not raise_error
    end
  end
end
