# https://developers.google.com/sheets/api/quickstart/ruby

require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Google Sheets API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "sheets.googleapis.com-ruby-quickstart.yaml")
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'jbari@ciudadanointeligente.org'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

def init_api
# Initialize the API
  service = Google::Apis::SheetsV4::SheetsService.new
  service.client_options.application_name = APPLICATION_NAME
  service.authorization = authorize
  service
end

def read(service, spreadsheet_id, range)
  spreadsheet_id = '1jjOplhY9yJ7MMuaXSvJqAukNMcK0i155gMUzH6D-vzE'
  #range = 'bot_output!1:1'
  response = service.get_spreadsheet_values(spreadsheet_id, range)

  puts 'No data found.' if response.values.empty?
  response.values.each do |row|
    row.each_with_index do |value, i|
      puts "#{i}, #{value}"
    end
  end
end

def write(service, spreadsheet_id, range, values)
  # range = 'bot_output!A5:E5'
  # # majorDimension: "ROWS",
  # values = {
  #   values: [
  #     ["300","300","300","300","300"]
  #   ]
  # }
  response = service.update_spreadsheet_value(spreadsheet_id, range, values, value_input_option: 'USER_ENTERED')
end

def append(service, spreadsheet_id, range, values)
  # range = 'bot_output!A5:E5'
  # # majorDimension: "ROWS",
  # values = {
  #   values: [
  #     ["300","300","300","300","300"]
  #   ]
  # }
  response = service.append_spreadsheet_value(spreadsheet_id, range, values, value_input_option: 'USER_ENTERED')
end


service = init_api
spreadsheet_id = '1jjOplhY9yJ7MMuaXSvJqAukNMcK0i155gMUzH6D-vzE'

range = 'bot_output!1:1'
read service, spreadsheet_id, range
#
# range = 'bot_output!A5:E5'
# # majorDimension: "ROWS",
# values = {
#   values: [
#     ["300","300","300","300","300"]
#   ]
# }
# write service, spreadsheet_id, range, values
