RSpec.describe ValidateHTML do
  let(:snapshot_path) { Pathname.new(__dir__).join('tmp/test_snapshots') }

  it "has a version number" do
    expect(ValidateHTML::VERSION).not_to be nil
  end

  it "raises for invalid html" do
    allow(ValidateHTML.configuration).to receive(:snapshot_path).and_return(snapshot_path)

    expect { ValidateHTML.validate_html('<strong><em>Very Emphasised</strong></em>', name: 'My Emphasised Fragment') }
      .to raise_error(
      ValidateHTML::InvalidHTMLError,
      <<~MESSAGE
        Invalid html from My Emphasised Fragment
        Parsed using Nokogiri::HTML5::DocumentFragment
        document saved at: #{__dir__}/tmp/test_snapshots/2567357e17ee0c948b6bfe13a95120d1da678775.html

        1:28: ERROR: That tag isn't allowed here  Currently open tags: html, strong, em.
        <strong><em>Very Emphasised</strong></em>
                                   ^
        1:37: ERROR: That tag isn't allowed here  Currently open tags: html.
        <strong><em>Very Emphasised</strong></em>
                                            ^
      MESSAGE
    )
  end

  it "returns true for valid html" do
    expect(ValidateHTML.validate_html('<strong><em>Very Emphasised</em></strong>')).to be true
  end
end
