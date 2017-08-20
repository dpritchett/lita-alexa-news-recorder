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

        response.write JSON.dump(sample_response)
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

      def sample_response
        {
          "version": "1.0",
          "sessionAttributes": {
            "supportedHoriscopePeriods": {
              "daily": true,
              "weekly": false,
              "monthly": false
            }
          },
          "response": {
            "outputSpeech": {
              "type": "PlainText",
              "text": "Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless. Can I help you with anything else?"
            },
            "card": {
              "type": "Simple",
              "title": "Horoscope",
              "content": "Today will provide you a new learning opportunity.  Stick with it and the possibilities will be endless."
            },
            "reprompt": {
              "outputSpeech": {
                "type": "PlainText",
                "text": "Can I help you with anything else?"
              }
            },
            "shouldEndSession": false
          }
        }
      end

      Lita.register_handler(self)
    end
  end
end
