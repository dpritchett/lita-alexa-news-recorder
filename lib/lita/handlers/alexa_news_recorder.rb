require 'pry'
require 'json'

module Lita
  module Handlers
    class AlexaNewsRecorder < Handler
      http.post '/alexa/recorder', :record_message

      def record_message(request, response)
        check_for_publisher!

        Lita.logger.debug "Inbound request params: "
        Lita.logger.debug request.params
        Lita.logger.debug "Inbound request body: "

        Lita.logger.debug request.body.string # it's a StringIO

        message = extract_message(request.body.string)

        robot.trigger(:save_alexa_message, username: 'Alexa News Recorder', message: message)

        response.write JSON.dump(alexa_response)
      end

      def check_for_publisher!
        return if robot.handlers.include?(Lita::Handlers::AlexaNewsPublisher)
        raise ConfigurationError, "Must install AlexaNewsPublisher handler to make me work!"
      end

      def extract_message(payload)
        parsed = JSON.parse(payload)

        value = parsed.dig('request', 'intent', 'slots', 'Message', 'value')

        raise ArgumentError if value.nil?
        value
      end

      def alexa_response(message)
        {
          "version": "1.0",
          "sessionAttributes": {
          },
          "response": {
            "outputSpeech": {
              "type": "PlainText",
              "text": "Added your message to Lita's flash briefing: #{message}"
            },
            "card": {
              "type": "Simple",
              "title": "Recorded flash message",
              "content": "Added your message to Lita's flash briefing: #{message}"
            },
            "shouldEndSession": true
          }
        }
      end

      Lita.register_handler(self)
    end
  end
end
