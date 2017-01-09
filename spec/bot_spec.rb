require './vacaciones_bot'
require './spec/api_mock' 

RSpec.describe VacacionesBot do
  describe "#score" do
    it "#start" do
        bot_api = ApiMock.new
        
        v = VacacionesBot.new bot_api
        v.start
        expect(v.e).to be(false)
        expect(v.te).to be(false)
        expect(v.fi).to be(false)
        expect(v.ft).to be(false)
    end
    it "#mail" do
        bot_api = ApiMock.new
        bot_api.send_message(chat_id: 1, text:"mandame tu _correo@ciudadanointeligente.org_", parse_mode: "Markdown")
         
        v = VacacionesBot.new bot_api 
        v.email 
        expect(bot_api.messages).to include('perrito')
    end
  end
end
