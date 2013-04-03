module DigitalOcean
  module Core
    extend self

    def basic_connection
      Faraday.new(:url => "https://api.digitalocean.com/" ) do |f|
        f.use DigitalOcean::AuthenticationMiddleware, {:client_id => @client_id, :api_key => @api_key}
        f.request :url_encoded
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    def digital_ocean_url
      "https://api.digitalocean.com/"
    end

    # def image_url
    #   "#{digital_ocean_url}images/"
    # end

    # def sizes_url
    #   "#{digital_ocean_url}sizes/"
    # end

    # def droplet_url
    #   "#{digital_ocean_url}droplet/"
    # end

    def droplets_url
      "#{digital_ocean_url}droplets/"
    end

    def auth_url
      "client_id=#{ DigitalOcean::Auth::CLIENT_ID }&api_key=#{ DigitalOcean::Auth::API_KEY }"
    end

    def set_id(input)
      if input.respond_to?(:id)
        input.id
      else
        input
      end
    end

    def droplets_action_url(droplet, action)
      "#{droplets_url}#{set_id(droplet)}/#{action}/?#{auth_url}"
    end

    def action(droplet, action)
      url = droplets_action_url(droplet, action)
      gather_response(url)
    end

    def gather_response(url, *key)
      response = basic_connection.get(url)
      body = response.body
      # response = JSON.parse(open(url).read)
      raise BadRequest unless body["status"] == "OK"
      if key[0]
        body.fetch(key[0])
      else
        body
      end
    end

    def gather_response_faraday(body, *key)
      response = JSON.parse(body)
      raise BadRequest unless response["status"] == "OK"
      if key[0]
        response.fetch(key[0])
      else
        response
      end
    end
  end
end
