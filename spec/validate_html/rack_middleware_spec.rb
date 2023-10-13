# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ValidateHTML::RackMiddleware do
  subject(:middleware) { described_class.new(app) }

  let(:path) { '/sessions/new' }
  let(:headers) { {} }
  let(:body) { '<strong><em>Emphasis</strong></em>' }
  let(:env) { Rack::MockRequest.env_for(path) }
  let(:app) { ->(_env) { [200, headers, body] } }

  let(:snapshot_path) { Pathname.new(__dir__).join('../tmp/test_snapshots') }

  before { stub_config(snapshot_path: snapshot_path) }

  context 'with no content type' do
    it "doesn't check the response" do
      expect(middleware.call(env)).to eq [200, headers, body]
    end
  end

  context 'with an html content type' do
    let(:headers) { { 'Content-Type' => 'text/html' } }

    it 'checks the response' do
      expect { middleware.call(env) }
        .to raise_error(ValidateHTML::InvalidHTMLError)
    end

    context 'with valid html' do
      let(:body) { '<strong><em>Emphasis</em></strong>' }

      it "doesn't raise an error" do
        expect(middleware.call(env)).to eq [200, headers, body]
      end
    end

    context 'with config.action_view.annotate_rendered_view_with_filenames=true HTML' do
      let(:body_with_leading_comment_removed) { '<!DOCTYPE html><html><body><p>hi</p></body></html>' }
      let(:body) { "<!-- BEGIN app/views/layouts/site.html.erb -->#{body_with_leading_comment_removed}" }

      it 'does not raise an error' do
        expect(middleware.call(env)).to eq [200, headers, body]
      end

      it 'calls ValidateHTML.validate_html with the leading comment removed' do
        allow(ValidateHTML).to receive(:validate_html)

        middleware.call(env)

        expect(ValidateHTML).to have_received(:validate_html).with(body_with_leading_comment_removed, anything)
      end
    end

    context 'with invalid html in an array for some reason' do
      let(:body) { ['<strong><em>Emphasis</strong></em>'] }

      it 'checks the response' do
        expect { middleware.call(env) }
          .to raise_error(ValidateHTML::InvalidHTMLError)
      end
    end

    context 'with invalid html in a nested response for some reason' do
      let(:body) { Rack::MockResponse.new(200, headers, '<strong><em>Emphasis</strong></em>') }

      it 'checks the response' do
        expect { middleware.call(env) }
          .to raise_error(ValidateHTML::InvalidHTMLError)
      end
    end

    context 'with a body that lies about what it responds to' do
      let(:body) { +'' }

      before { allow(body).to receive(:to_str).and_raise(NoMethodError) }

      it "ignores it and doesn't raise an error" do
        expect(middleware.call(env)).to eq [200, headers, body]
      end
    end

    context 'with a body that is some other thing' do
      let(:body) { 1 }

      it "ignores it and doesn't raise an error" do
        expect(middleware.call(env)).to eq [200, headers, body]
      end
    end

    context 'with string ignored path' do
      before do
        stub_config(ignored_paths: ['/sessions/new'])
      end

      it "doesn't raise an error" do
        expect(middleware.call(env)).to eq [200, headers, body]
      end
    end

    context 'with included string ignored path' do
      before do
        stub_config(ignored_paths: ['/sessions'])
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
        expect(middleware.call(env)).to eq [200, headers, body]
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
      let(:body) { '<strong><em>Emphasis</em></strong>' }

      it "doesn't raise an error" do
        expect(middleware.call(env)).to eq [200, headers, body]
      end
    end
  end
end
