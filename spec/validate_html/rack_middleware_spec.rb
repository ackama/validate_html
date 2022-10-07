RSpec.describe ValidateHTML::RackMiddleware do
  let(:path) { "/sessions/new" }
  let(:headers) { {} }
  let(:body) { "<strong><em>Emphasis</strong></em>" }
  let(:env) { Rack::MockRequest.env_for(path) }
  let(:app) { ->(env) { [200, headers, body] } }
  subject(:middleware) { ValidateHTML::RackMiddleware.new(app) }

  context 'with no content type' do
    it "dosen't check the response" do
      expect { middleware.call(env) }.to_not raise_error
    end
  end

  context 'with an html content type' do
    let(:headers) { { 'Content-Type' => 'text/html' } }

    it 'checks the response' do
      expect { middleware.call(env) }
        .to raise_error(ValidateHTML::InvalidHTMLError)
    end

    context 'with valid html' do
      let(:body) { "<strong><em>Emphasis</em></strong>" }

      it "doesn't raise an error" do
        expect { middleware.call(env) }.to_not raise_error
      end
    end

    context 'with string ignored path' do
      before do
        stub_config(ignored_paths: ["/sessions/new"])
      end

      it "doesn't raise an error" do
        expect { middleware.call(env) }.to_not raise_error
      end
    end

    context 'with included string ignored path' do
      before do
        stub_config(ignored_paths: ["/sessions"])
      end

      it 'checks the response' do
        expect { middleware.call(env) }
          .to raise_error(ValidateHTML::InvalidHTMLError)
      end
    end

    context 'with regexp ignored path' do
      before do
        stub_config(ignored_paths: [%r{\A/sessions}])
      end

      it "doesn't raise an error" do
        expect { middleware.call(env) }.to_not raise_error
      end
    end
  end

  context 'with a turbo content type' do
    let(:headers) { { 'Content-Type' => 'text/vnd.turbo-stream.html' } }

    it 'checks the response' do
      expect { middleware.call(env) }
        .to raise_error(ValidateHTML::InvalidHTMLError)
    end

    context 'with valid html' do
      let(:body) { "<strong><em>Emphasis</em></strong>" }

      it "doesn't raise an error" do
        expect { middleware.call(env) }.to_not raise_error
      end
    end
  end
end
