# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ValidateHTML do
  let(:snapshot_path) { Pathname.new(__dir__).join('tmp/test_snapshots') }
  let(:invalid_html) { '<strong><em>Very Emphasized</strong></em>' }
  let(:valid_html) { '<strong><em>Very Emphasized</em></strong>' }

  it 'has a version number' do
    expect(ValidateHTML::VERSION).to eq '0.1.0'
  end

  describe '.validate_html' do
    it 'raises for invalid html' do
      stub_config(snapshot_path: snapshot_path)

      expect { described_class.validate_html(invalid_html, name: 'My Emphasized Fragment') }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from My Emphasized Fragment
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

            1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
            <strong><em>Very Emphasized</strong></em>
                                       ^
            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
          MESSAGE
        )
    end

    it 'raises for invalid html5 document' do
      stub_config(snapshot_path: snapshot_path)
      expect { described_class.validate_html("<!doctype html>#{invalid_html}", name: 'My Emphasized Fragment') }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from My Emphasized Fragment
            Parsed using Nokogiri::HTML5::Document
            document saved at: #{__dir__}/tmp/test_snapshots/6a3314cce39b0b1361363560c085c70265f886c6.html

            1:43: ERROR: That tag isn't allowed here  Currently open tags: html, body, strong, em.
            <!doctype html><strong><em>Very Emphasized</strong></em>
                                                      ^
            1:52: ERROR: That tag isn't allowed here  Currently open tags: html, body.
            <!doctype html><strong><em>Very Emphasized</strong></em>
                                                               ^
          MESSAGE
        )
    end

    it 'raises for invalid html4 document' do
      stub_config(snapshot_path: snapshot_path)
      html4dtd = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
      expect { described_class.validate_html("#{html4dtd}#{invalid_html}", name: 'My Emphasized Fragment') }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from My Emphasized Fragment
            Parsed using Nokogiri::HTML4::Document
            document saved at: #{__dir__}/tmp/test_snapshots/dc0e625033c7fb309e89725ef947564991f651b1.html

            1:127: ERROR: Opening and ending tag mismatch: strong and em
            1:132: ERROR: Unexpected end tag : em
          MESSAGE
        )
    end

    it 'ignores errors that have been ignored with regexp' do
      stub_config(ignored_errors: [/That tag isn't allowed here/])

      expect { described_class.validate_html(invalid_html, name: 'My Emphasized Fragment') }
        .not_to raise_error
    end

    it 'only ignores errors that have been ignored with strings when they match exactly' do
      stub_config(ignored_errors: ["That tag isn't allowed here"], snapshot_path: snapshot_path)

      expect { described_class.validate_html(invalid_html, name: 'My Emphasized Fragment') }
        .to raise_error(ValidateHTML::InvalidHTMLError)
    end

    it 'ignores errors that have been ignored with strings' do
      stub_config(snapshot_path: snapshot_path, ignored_errors: [
        <<~MESSAGE.chomp
          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
        MESSAGE
      ])

      expect { described_class.validate_html(invalid_html, name: 'My Emphasized Fragment') }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from My Emphasized Fragment
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
          MESSAGE
        )
    end

    it 'returns true for valid html' do
      expect(described_class.validate_html(valid_html)).to be true
    end

    it 'returns true for empty strings' do
      expect(described_class.validate_html('')).to be true
    end

    it 'can be given a content type' do
      allow(Nokogiri::HTML5).to receive(:fragment).and_call_original
      expect(described_class.validate_html('body', content_type: 'text/html; charset=utf-8')).to be true
      expect(Nokogiri::HTML5).to have_received(:fragment).with('body', 'utf-8', max_errors: -1)
    end
  end

  describe 'raise_remembered_messages' do
    it 'raises NotRememberingMessagesError if remember_messages is false' do
      stub_config(remember_messages?: false)

      expect { described_class.raise_remembered_messages }.to raise_error(ValidateHTML::NotRememberingMessagesError)
    end

    it 'raises nothing if remember_messages is true and there are no messages' do
      stub_config(remember_messages?: true)

      expect { described_class.raise_remembered_messages }.not_to raise_error
    end

    it 'raises with joined messages if remember_messages is true and there are messages' do
      stub_config(
        snapshot_path: snapshot_path,
        raise_on_invalid_html?: false,
        remember_messages?: true
      )

      described_class.validate_html(invalid_html, name: 'My First Emphasized Fragment')
      described_class.validate_html(invalid_html, name: 'My Second Emphasized Fragment')
      expect { described_class.raise_remembered_messages }.to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~ERROR
          Invalid html from My First Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
          ---
          Invalid html from My Second Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
        ERROR
      )
    end

    it 'can forget messages' do
      stub_config(
        snapshot_path: snapshot_path,
        raise_on_invalid_html?: false,
        remember_messages?: true
      )

      described_class.validate_html(invalid_html, name: 'My First Emphasized Fragment')
      described_class.validate_html(invalid_html, name: 'My Second Emphasized Fragment')
      expect { described_class.raise_remembered_messages }.to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~ERROR
          Invalid html from My First Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
          ---
          Invalid html from My Second Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
        ERROR
      )
      described_class.forget_messages
      expect { described_class.raise_remembered_messages }.not_to raise_error
    end

    it 'raises with joined messages if remember_messages is true and there are messages even when raising' do
      stub_config(
        snapshot_path: snapshot_path,
        raise_on_invalid_html?: true,
        remember_messages?: true
      )

      expect { described_class.validate_html(invalid_html, name: 'My First Emphasized Fragment') }
        .to raise_error(ValidateHTML::InvalidHTMLError)
      expect { described_class.validate_html(invalid_html, name: 'My Second Emphasized Fragment') }
        .to raise_error(ValidateHTML::InvalidHTMLError)

      expect { described_class.raise_remembered_messages }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~ERROR
            Invalid html from My First Emphasized Fragment
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

            1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
            <strong><em>Very Emphasized</strong></em>
                                       ^
            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
            ---
            Invalid html from My Second Emphasized Fragment
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{__dir__}/tmp/test_snapshots/1a8ce99806ddeccc3a5f2904ba07c7fa5ae4659d.html

            1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
            <strong><em>Very Emphasized</strong></em>
                                       ^
            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
          ERROR
        )
    end
  end

  describe '.configuration' do
    after do
      described_class.instance_variable_set(:@configuration, nil)
    end

    it 'can be controlled with configuration' do
      described_class.configuration.raise_on_invalid_html = false
      expect(described_class.configuration.raise_on_invalid_html?).to be false
    end

    it 'can be controlled with configure' do
      described_class.configure do |c|
        c.raise_on_invalid_html = false
      end
      expect(described_class.configuration.raise_on_invalid_html?).to be false
    end
  end
end
