# frozen_string_literal: true

require 'json'

# This plugin's tests, run with `trmnlp test` (add `--report report` for a page of every screen it drew).
# Docs: https://github.com/usetrmnl/trmnlp#testing-plugins
RSpec.describe 'AppSignal' do
  let(:now) { '2026-10-23T15:00:00Z' }
  let(:response) { JSON.parse(File.read(File.join(__dir__, 'fixtures/appsignal_response.json'))) }
  let(:mocks) { { 'https://appsignal.com/graphql*' => { json: response } } }
  let(:custom_fields) { { 'organization' => 'example-org' } }

  it_behaves_like 'a publishable recipe'

  %w[full half_horizontal half_vertical quadrant].each do |view|
    it "draws the #{view} view without problems" do
      screen = trmnl.render(view:, mocks:, custom_fields:, now:)

      expect(screen.problems).to be_empty
      expect(screen.overflowing).to be_empty
    end

    it "draws the #{view} view without problems on a TRMNL X in portrait" do
      screen = trmnl.render(view:, device: 'v2', orientation: :portrait, mocks:, custom_fields:, now:)

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

  %w[full half_horizontal half_vertical quadrant].each do |view|
    it "looks as it did: #{view} on a TRMNL X in portrait" do
      expect(trmnl.render(view:, device: 'v2', orientation: :portrait, mocks:, custom_fields:, now:)).to match_snapshot
    end
  end

  it 'shows the open error count and the latest error' do
    screen = trmnl.render(mocks:, custom_fields:, now:)

    expect(screen.result.html).to include('ActiveRecord::&#8203;RecordNotFound')
    expect(screen.result.html).to include('4m ago')
    expect(screen.result.html).to match(%r{2<span[^>]*>/6</span>})
  end

  it 'lists only the monitors that are down in the full view' do
    html = trmnl.render(view: 'full', mocks:, custom_fields:, now:).result.html
    names = html.scan(/>(Homepage|API|Status|nightly-backup|invoice-sync|queue-worker)</).flatten

    expect(names).to eq(%w[API invoice-sync])
    expect(html).to include('Missed')
    expect(html).to include('1h ago')
  end

  it 'says every monitor is up when none is down' do
    apps = response.dig('data', 'organization', 'apps')
    apps.each { |app| app['uptimeMonitors'].each { |monitor| monitor['alerts'] = [] } }
    apps.each { |app| app['checkIns']['triggers'].each { |check_in| check_in['lastState'] = 'FINISHED' } }
    html = trmnl.render(view: 'full', mocks:, custom_fields:, now:).result.html

    expect(html).to include('All 6 monitors up.')
  end

  it 'merges every app, newest first, naming each row\'s app, when App is blank' do
    html = trmnl.render(view: 'full', mocks:, custom_fields:, now:).result.html
    errors = html.scan(/>(ActiveRecord::&#8203;RecordNotFound|Stripe::&#8203;RateLimitError|Net::&#8203;ReadTimeout)</).flatten

    expect(errors).to eq(%w[ActiveRecord::&#8203;RecordNotFound Stripe::&#8203;RateLimitError Net::&#8203;ReadTimeout])
    expect(html).to include('All apps (2)')
    expect(html).to match(/label--outline[^>]*>billing-api</)
  end

  it 'shows only the named app, ignoring case' do
    html = trmnl.render(view: 'full', mocks:, custom_fields: custom_fields.merge('app' => ' Billing-API '), now:).result.html

    expect(html).to include('billing-api production')
    expect(html).to include('Stripe::&#8203;RateLimitError')
    expect(html).not_to include('RecordNotFound')
    expect(html).not_to include('label--outline')
  end

  it 'picks one environment when App names it' do
    html = trmnl.render(mocks:, custom_fields: custom_fields.merge('app' => 'billing-api production'), now:).result.html

    expect(html).to include('Stripe::&#8203;RateLimitError')
    expect(html).not_to include('RecordNotFound')
  end

  it 'lists the apps it found when App matches none' do
    html = trmnl.render(mocks:, custom_fields: custom_fields.merge('app' => 'nope'), now:).result.html

    expect(html).to include('No app named &quot;nope&quot;')
    expect(html).to include('example-app production, billing-api production')
  end

  it 'lets long action names break after :: and # without mangling them' do
    screen = trmnl.render(mocks:, custom_fields:, now:)

    expect(screen.result.html).to include('Api::&#8203;ShiftsController#&#8203;update')
  end

  it 'shows example data when the organization is demo, whatever AppSignal answers' do
    not_found = { 'https://appsignal.com/graphql*' => { json: { errors: [{ message: 'Object not found.' }] } } }
    screen = trmnl.render(mocks: not_found, custom_fields: { 'organization' => ' Demo ' }, now:)

    expect(screen.result.html).to include('example-app')
    expect(screen.result.html).to include('4m ago')
    expect(screen.result.html).not_to include('AppSignal did not answer')
  end

  it 'explains a rejected request' do
    rejected = { 'https://appsignal.com/graphql*' => { json: { errors: [{ message: 'Not authorized' }] } } }
    screen = trmnl.render(mocks: rejected, custom_fields:, now:)

    expect(screen.result.html).to include('AppSignal did not answer')
    expect(screen.result.html).to include('Not authorized')
  end
end
