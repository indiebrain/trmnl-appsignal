# frozen_string_literal: true

require 'json'

# This plugin's tests, run with `trmnlp test` (add `--report report` for a page of every screen it drew).
# Docs: https://github.com/usetrmnl/trmnlp#testing-plugins
RSpec.describe 'AppSignal' do
  let(:now) { '2026-10-23T15:00:00Z' }
  let(:response) { JSON.parse(File.read(File.join(__dir__, 'fixtures/appsignal_response.json'))) }
  let(:mocks) { { 'https://appsignal.com/graphql*' => { json: response } } }
  let(:custom_fields) { { 'api_token' => 'test-token', 'app_id' => '5f0c3a9e8b1d2c4e6a7f9b10' } }

  it_behaves_like 'a publishable recipe'

  %w[full half_horizontal half_vertical quadrant].each do |view|
    it "draws the #{view} view without problems" do
      screen = trmnl.render(view:, mocks:, custom_fields:, now:)

      expect(screen.problems).to be_empty
      expect(screen.overflowing).to be_empty
    end
  end

  # Pictures of every view on the original TRMNL (og_plus) and TRMNL X (v2), compared pixel for pixel.
  # Record them again with `trmnlp test --update` after a deliberate change to the markup.
  %w[og_plus v2].product(%w[full half_horizontal half_vertical quadrant]).each do |device, view|
    it "looks as it did: #{view} on #{device}" do
      expect(trmnl.render(view:, device:, mocks:, custom_fields:, now:)).to match_snapshot
    end
  end

  it 'shows the open error count and the latest error' do
    screen = trmnl.render(mocks:, custom_fields:, now:)

    expect(screen.result.html).to include('ActiveRecord::RecordNotFound')
    expect(screen.result.html).to include('4m ago')
    expect(screen.result.html).to match(%r{1<span[^>]*>/3</span>})
  end

  it 'explains a rejected request' do
    rejected = { 'https://appsignal.com/graphql*' => { json: { errors: [{ message: 'Not authorized' }] } } }
    screen = trmnl.render(mocks: rejected, custom_fields:, now:)

    expect(screen.result.html).to include('AppSignal did not answer')
    expect(screen.result.html).to include('Not authorized')
  end
end
