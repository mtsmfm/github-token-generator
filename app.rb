require 'bundler'
Bundler.require

require 'net/http'
require 'uri'
require 'sinatra/reloader' if development?

set :app_file, __FILE__
enable :inline_templates

unless ENV['GITHUB_APP_CLIENT_ID']
  raise 'GITHUB_APP_CLIENT_ID env var is missing'
end

unless ENV['GITHUB_APP_CLIENT_SECRET']
  raise 'GITHUB_APP_CLIENT_SECRET env var is missing'
end

get '/' do
  if params['code']
    response = Net::HTTP.post(
      URI('https://github.com/login/oauth/access_token'),
      {client_id: ENV['GITHUB_APP_CLIENT_ID'], client_secret: ENV['GITHUB_APP_CLIENT_SECRET'], code: params['code']}.to_json,
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    )
    data = JSON.parse(response.body)
    @access_token = data['access_token']
    @expires_at = Time.now + data['expires_in'].to_i
    @error = data['error']
  end

  erb :index
end

__END__

@@ index
<html>
  <body>
    <a href="https://github.com/login/oauth/authorize?client_id=<%= ENV['GITHUB_APP_CLIENT_ID'] %>">Generate token</a>
    <% if @error %>
      <div>Something wrong </div>
      <div><%= @error %></div>
    <% elsif @access_token %>
      <div>Your token:</div>
      <input value=<%= @access_token %> readonly='readonly' />
      <div id="expires_at" ></div>
    <% end %>
  </body>
  <script>
    const elem = document.getElementById('expires_at');
    if (elem) {
      const expiresAt = new Date(<%= @expires_at.to_i %> * 1000).toString();
      elem.innerText = `Expires at ${expiresAt}`
    }
  </script>
</html>
