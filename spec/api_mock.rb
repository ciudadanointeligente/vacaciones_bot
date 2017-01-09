
class ApiMock
    attr_accessor :messages
    def initialize
        @messages = []
    end
    def send_message(chat_id:, text:, parse_mode:)
        @messages.push(text)
    end
end

