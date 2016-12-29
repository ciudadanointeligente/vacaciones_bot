# to-do
# calcular días de vacaciones usados sin considerar fin de semana y festivos
# calcular días restantes
# entregar informe sobre los días consumidos por usuario y como grupo
# mejorar este código de mierda!

require 'telegram/bot'
require 'date'
require 'sqlite3'
require 'yaml'

$cnfg = YAML::load_file('config.yml')

token = $cnfg["token_bot"]
sqlite_db_name = $cnfg["db_name"]

db = SQLite3::Database.new sqlite_db_name
db.execute "CREATE TABLE IF NOT EXISTS Equipo(id INTEGER PRIMARY KEY,
          user_id INTEGER, email TEXT, tipo TEXT, fecha_inicio DATETIME, fecha_termino DATETIME)"

def valid_email message
  emails = $cnfg["users"]
  is_email = message.text.split '@'
  if is_email[1] == 'ciudadanointeligente.org'
    if emails.include? message.text
      return true
    end
  end
  return false
end

def valid_date message
  d,m,a = message.text.split '-'
  if Date.valid_date? a.to_i, m.to_i, d.to_i
    return true
  end
  return false
end

def evento_valido message
  t_eventos = $cnfg["event_types"]
  if t_eventos.include? message.text
    return true
  end
  return false
end

Telegram::Bot::Client.run(token) do |bot|
  e, te, fi, ft = false
  bot.listen do |message|
    #user_id
    u_id = message.from.id
    if u_id
      last_id = db.execute "SELECT id FROM Equipo WHERE user_id = #{u_id} ORDER BY id DESC LIMIT 1;"
    end

    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text:"Hola\nBienvenido al robot gestionador de <i>Vacaciones</i> y <i>Administrativos</i>\nPara poder ayudarte con tus días necesito obtener un poco de información, para lo cual necesito que me envíes tu /email el /tipo_evento la /fecha_inicio y /fecha_termino (msgId:#{message.message_id})", parse_mode: "HTML")
    when '/email'
      bot.api.send_message(chat_id: message.chat.id, text:"mandame tu _correo@ciudadanointeligente.org_", parse_mode: "Markdown")
      e = true
    when '/tipo_evento'
      bot.api.send_message(chat_id: message.chat.id, text: "Enviame _Vacaciones_ o _Administrativo_", parse_mode: "Markdown" )
      te = true
    when '/fecha_inicio'
      bot.api.send_message(chat_id: message.chat.id, text: "Enviame la fecha de inicio en formato _DD-MM-AAAA_, x ejemplo _15-09-2016_", parse_mode: "Markdown" )
      fi = true
    when '/fecha_termino'
      bot.api.send_message(chat_id: message.chat.id, text: "Enviame la fecha de término en formato _DD-MM-AAAA_, x ejemplo _20-09-2016_", parse_mode: "Markdown" )
      ft = true
    else
      if (e && valid_email(message))
        txt = "email: #{message.text}.\nAhora enviame el tipo de evento con el comando <i>/tipo_evento</i>"
        bot.api.send_message(chat_id: message.chat.id, text: "#{txt}", parse_mode: "HTML")
        e = false

        #db insert
        db.execute "INSERT INTO Equipo (id, user_id, email) VALUES (NULL, #{u_id}, '#{message.text}');"
      elsif e
        txt = "El correo que me enviaste no es válido o no se encuentra dentro de los permitidos, seguro que me enviaste el comando correcto y luego tu correo?"
        bot.api.send_message(chat_id: message.chat.id, text: "#{txt}")
      end
      if (te && evento_valido(message))
        txt = "evento: #{message.text}.\nAhora enviame la fecha de inicio con el comando <i>/fecha_inicio</i>"
        bot.api.send_message(chat_id: message.chat.id, text: "#{txt}", parse_mode: "HTML")
        te = false
        #db update
        db.execute "UPDATE Equipo SET tipo='#{message.text}' WHERE id = #{last_id[0][0]}"
      end
      if ((fi || ft) && valid_date(message))
        if fi
          txt = "fecha: #{message.text}.\nAhora enviame la fecha de termino con el comando <i>/fecha_termino</i>"
        else
          txt = "fecha: #{message.text}.\nEstamos procesando tu solicitud, pronto nos comunicaremos contigo."
        end
        bot.api.send_message(chat_id: message.chat.id, text: "#{txt}", parse_mode: "HTML")
        # db update
        d = DateTime.parse("#{message.text}").strftime("%Y-%m-%d") #transform from DD-MM-AAAA to AAAA-MM-DD
        if fi
          db.execute "UPDATE Equipo SET fecha_inicio='#{d} 00:00:00' WHERE id = #{last_id[0][0]} AND tipo IS NOT NULL"
        else
          db.execute "UPDATE Equipo SET fecha_termino='#{d} 23:59:59' WHERE id = #{last_id[0][0]} AND tipo IS NOT NULL AND fecha_inicio IS NOT NULL"
        end
        fi, ft = false
      elsif (fi||ft)
        txt = 'la fecha no es válida, el formato es DD-MM-AAAA'
        bot.api.send_message(chat_id: message.chat.id, text: "#{txt}", parse_mode: "HTML")
      end
    end
  end
end
