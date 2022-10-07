require 'mail'

RSpec.describe ValidateHTML::MailerObserver do
  let(:snapshot_path) { Pathname.new(__dir__).join('../tmp/test_snapshots') }
  let(:email) do
    Mail.new(subject: 'The Subject', body: '>text body<')
  end
  let(:html_email) do
    email.html_part = '<strong><em>Very Emphasised</strong></em>'
    email
  end

  describe '.perform' do
    it "validates html email" do
      stub_config(snapshot_path: snapshot_path)

      expect { ValidateHTML::MailerObserver.perform(html_email) }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from email The Subject
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

    it "ignores non-html email" do
      expect { ValidateHTML::MailerObserver.perform(email) }
        .to_not raise_error
    end

    it 'has aliases to methods that rails uses' do
      expect(subject.method(:perform))
        .to eq(subject.method(:delivering_email))
        .and(eq subject.method(:delivered_email))
        .and(eq subject.method(:previewing_email))
    end
  end
end
