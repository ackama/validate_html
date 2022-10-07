RSpec.describe ValidateHTML do
  let(:snapshot_path) { Pathname.new(__dir__).join('tmp/test_snapshots') }

  it "has a version number" do
    expect(ValidateHTML::VERSION).not_to be nil
  end

  describe '.validate_html' do
    it "raises for invalid html" do
      stub_config(snapshot_path: snapshot_path)

      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment') }
        .to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~MESSAGE
          Invalid html from My Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
        MESSAGE
      )
    end

    it "ignores errors that have been ignored with regexp" do
      stub_config(ignored_errors: [/That tag isn't allowed here/])

      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment') }
        .to_not raise_error
    end

    it "only ignores errors that have been ignored with strings when they match exactly" do
      stub_config(ignored_errors: ["That tag isn't allowed here"])

      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment') }
        .to raise_error(ValidateHTML::InvalidHTMLError)
    end

    it "ignores errors that have been ignored with strings" do
      stub_config(snapshot_path: snapshot_path, ignored_errors: [
        <<~MESSAGE.chomp
          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
        MESSAGE
      ])

      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Emphasized Fragment') }
        .to raise_error(
          ValidateHTML::InvalidHTMLError,
          <<~MESSAGE
            Invalid html from My Emphasized Fragment
            Parsed using Nokogiri::HTML5::DocumentFragment
            document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

            1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
            <strong><em>Very Emphasized</strong></em>
                                                ^
          MESSAGE
        )
    end

    it "returns true for valid html" do
      expect(ValidateHTML.validate_html('<strong><em>Very Emphasized</em></strong>')).to be true
    end
  end

  describe 'raise_remembered_messages' do
    it 'raises NotRememberingMessagesError if remember_messages is false' do
      stub_config(remember_messages?: false)

      expect { ValidateHTML.raise_remembered_messages }.to raise_error(ValidateHTML::NotRememberingMessagesError)
    end

    it 'raises nothing if remember_messages is true and there are no messages' do
      stub_config(remember_messages?: true)

      expect { ValidateHTML.raise_remembered_messages }.to_not raise_error
    end

    it 'raises with joined messages if remember_messages is true and there are messages' do
      stub_config(
        snapshot_path: snapshot_path,
        raise_on_invalid_html?: false,
        remember_messages?: true
      )

      ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My First Emphasized Fragment')
      ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Second Emphasized Fragment')
      expect { ValidateHTML.raise_remembered_messages }.to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~ERROR
          Invalid html from My First Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
          ---
          Invalid html from My Second Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

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

      ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My First Emphasized Fragment')
      ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Second Emphasized Fragment')
      expect { ValidateHTML.raise_remembered_messages }.to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~ERROR
          Invalid html from My First Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
          ---
          Invalid html from My Second Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
        ERROR
      )
      ValidateHTML.forget_messages
      expect { ValidateHTML.raise_remembered_messages }.to_not raise_error
    end

    it 'raises with joined messages if remember_messages is true and there are messages' do
      stub_config(
        snapshot_path: snapshot_path,
        raise_on_invalid_html?: true,
        remember_messages?: true
      )

      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My First Emphasized Fragment') }.to raise_error(ValidateHTML::InvalidHTMLError)
      expect { ValidateHTML.validate_html('<strong><em>Very Emphasized</strong></em>', name: 'My Second Emphasized Fragment') }.to raise_error(ValidateHTML::InvalidHTMLError)
      expect { ValidateHTML.raise_remembered_messages }.to raise_error(
        ValidateHTML::InvalidHTMLError,
        <<~ERROR
          Invalid html from My First Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

          1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
          <strong><em>Very Emphasized</strong></em>
                                     ^
          1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
          <strong><em>Very Emphasized</strong></em>
                                              ^
          ---
          Invalid html from My Second Emphasized Fragment
          Parsed using Nokogiri::HTML5::DocumentFragment
          document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

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
      ValidateHTML.instance_variable_set(:@configuration, nil)
    end

    it 'can be controlled with configuration' do
      ValidateHTML.configuration.raise_on_invalid_html = false
      expect(ValidateHTML.configuration.raise_on_invalid_html?).to be false
    end

    it 'can be controlled with configure' do
      ValidateHTML.configure do |c|
        c.raise_on_invalid_html = false
      end
      expect(ValidateHTML.configuration.raise_on_invalid_html?).to be false
    end
  end
end
