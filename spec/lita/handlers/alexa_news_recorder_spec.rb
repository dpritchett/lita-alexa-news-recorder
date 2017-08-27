require "spec_helper"
require 'pry'
require 'date'

describe Lita::Handlers::AlexaNewsRecorder, lita_handler: true do
  let(:robot) { Lita::Robot.new(registry) }

  subject { described_class.new(robot) }

  describe 'routes' do
    it { is_expected.to route_http(:post, "/alexa/recorder").to(:record_message) }
  end

  describe ':record_message' do
    # "hello, Alexa" fixture
    let(:amazon_formatted_json_request_body) { open("./spec/fixtures/inbound_message.json").read }
    
    it 'can accept an inbound message in alexa dictation format' do
      response = http.post('/alexa/recorder', amazon_formatted_json_request_body)
      body = JSON.parse(response.body, symbolize_names: true)

      expect(body.dig(:response, :outputSpeech, :text)).to include('hi dad')
    end

    it 'emits an event to trigger another handler to save alexa messages' do
      expect(robot).to receive(:trigger).with(:save_alexa_message, {:username=>"Alexa News Recorder", :message=>"hi dad"})

      response = http.post('/alexa/recorder', amazon_formatted_json_request_body)
    end
  end

  describe ':alexa_response' do
    let(:body) { 'responding to alexa' }

    it 'should return an alexa-shaped response hash with the supplied message body' do
      result = subject.alexa_response(body)

      expect(result.dig(:response, :outputSpeech, :text)).to include(body)
    end
  end

end
