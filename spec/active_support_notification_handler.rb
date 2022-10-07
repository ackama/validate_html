RSpec.describe ValidateHTML::ActiveSupportNotificationHandler do
  let(:snapshot_path) { Pathname.new(__dir__).join('../tmp/test_snapshots') }

  describe '.call' do
    it "validates turbo html" do
      stub_config(snapshot_path: snapshot_path)

      payload = {
        channel_class: 'Turbo::StreamsChannel',
        data: '<strong><em>Very Emphasised</strong></em>'
      }

      expect { ValidateHTML::ActiveSupportNotificationHandler.call(nil, nil, nil, nil, payload) }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{File.dirname(__dir__)}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

            1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
            <strong><em>Very Emphasised</strong></em>
                                       ^
            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasised</strong></em>
                                                ^
          MESSAGE
      )
    end

    it "ignores non-turbo payloads" do
      stub_config(snapshot_path: snapshot_path)

      payload = {
        channel_class: 'something else',
        data: '<strong><em>Very Emphasised</strong></em>'
      }

      expect { ValidateHTML::ActiveSupportNotificationHandler.call(nil, nil, nil, nil, payload) }
        .to_not raise_error
    end
  end
end
