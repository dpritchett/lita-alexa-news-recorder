require 'pry'
require 'json'

module Lita
  module Handlers
    class AlexaNewsRecorder < Handler
      http.post '/alexa/recorder', :record_message

      def record_message(request, response)
        Lita.logger.debug "Inbound request params: "
        Lita.logger.debug request.params
        Lita.logger.debug "Inbound request body: "
        Lita.logger.debug request.body.string # it's a StringIO

        response.write JSON.dump(sample_response)
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
