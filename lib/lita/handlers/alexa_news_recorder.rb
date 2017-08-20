require 'pry'

module Lita
  module Handlers
    class AlexaNewsRecorder < Handler
      http.post '/alexa/recorder', :record_message

      def record_message(request, response)
        Lita.logger.debug "Inbound request params: "
        Lita.logger.debug request.params
        Lita.logger.debug "Inbound request body: "
        Lita.logger.debug request.body

        response.write request.body
      end

      Lita.register_handler(self)
    end
  end
end
