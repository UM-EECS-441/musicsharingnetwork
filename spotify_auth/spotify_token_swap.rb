require 'sinatra'
require 'net/http'
require 'net/https'
require 'base64'
require 'encrypted_strings'
require 'json'

CLIENT_ID = "c0a5c9b2c5b94d00b5599dd76b092414"
CLIENT_SECRET = "225ff590d76d4d6db2168af29e627dd4"
ENCRYPTION_SECRET = "cFJLyifeUJUBFWdHzVbykfDmPHtLKLGzViHW9aHGmyTLD8hGXC"
CLIENT_CALLBACK_URL = "music-sharing-network://spotify-login-callback"
AUTH_HEADER = "Basic " + Base64.strict_encode64(CLIENT_ID + ":" + CLIENT_SECRET)
SPOTIFY_ACCOUNTS_ENDPOINT = URI.parse("https://accounts.spotify.com")

set :port, 8080
set :bind, '0.0.0.0'

get '/' do
"Working"    
end

post '/swap' do

    # This call takes a single POST parameter, "code", which
    # it combines with your client ID, secret and callback
    # URL to get an OAuth token from the Spotify Auth Service,
    # which it will pass back to the caller in a JSON payload.

    auth_code = params[:code]

    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host, SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new("/api/token")

    request.add_field("Authorization", AUTH_HEADER)

    request.form_data = {
        "grant_type" => "authorization_code",
        "redirect_uri" => CLIENT_CALLBACK_URL,
        "code" => auth_code
    }

    response = http.request(request)

    # encrypt the refresh token before forwarding to the client
    if response.code.to_i == 200
        token_data = JSON.parse(response.body)
        refresh_token = token_data["refresh_token"]
        encrypted_token = refresh_token.encrypt(:symmetric, :password => ENCRYPTION_SECRET)
        token_data["refresh_token"] = encrypted_token
        response.body = JSON.dump(token_data)
    end

    status response.code.to_i
    return response.body
end

post '/refresh' do

    # Request a new access token using the POST:ed refresh token

    http = Net::HTTP.new(SPOTIFY_ACCOUNTS_ENDPOINT.host, SPOTIFY_ACCOUNTS_ENDPOINT.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new("/api/token")

    request.add_field("Authorization", AUTH_HEADER)

    encrypted_token = params[:refresh_token]
    refresh_token = encrypted_token.decrypt(:symmetric, :password => ENCRYPTION_SECRET)

    request.form_data = {
        "grant_type" => "refresh_token",
        "refresh_token" => refresh_token
    }

    response = http.request(request)

    status response.code.to_i
    return response.body

end