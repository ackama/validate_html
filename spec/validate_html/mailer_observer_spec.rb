# frozen_string_literal: true

require 'spec_helper'
require 'mail'

RSpec.describe ValidateHTML::MailerObserver do
  let(:snapshot_path) { Pathname.new(__dir__).join('../tmp/test_snapshots') }
  let(:email) do
    Mail.new(subject: 'The Subject', body: '>text body<')
  end
  let(:html) { '<strong><em>Very Emphasized</strong></em>' }
  let(:html_email) do
    email.html_part = html
    email
  end

  describe '.perform' do
    it 'validates html email' do
      stub_config(snapshot_path: snapshot_path)

      expect { described_class.perform(html_email) }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from email The Subject
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

    context 'with valid html' do
      let(:html) { '<strong><em>Very Emphasized</em></strong>' }

      it 'validates html email' do
        stub_config(snapshot_path: snapshot_path)

        expect { described_class.perform(html_email) }
          .not_to raise_error
      end
    end

    it 'ignores non-html email' do
      expect { described_class.perform(email) }
        .not_to raise_error
    end

    it 'has aliases to methods that rails uses' do
      expect(subject.method(:perform))
        .to eq(subject.method(:delivering_email))
        .and(eq subject.method(:delivered_email))
        .and(eq subject.method(:previewing_email))
    end
  end
end
