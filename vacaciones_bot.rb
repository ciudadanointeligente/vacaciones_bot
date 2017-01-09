class VacacionesBot
    attr_accessor :e, :fi, :ft, :te, :bot_api
    def initialize(bot_api)
        @bot_api = bot_api
    end
    def start
        @e = false
        @fi = false
        @ft = false
        @te = false
    end
    def email
        @bot_api.send_message(chat_id: 1, text: "perrito", parse_mode: "HTML")
    end
end
