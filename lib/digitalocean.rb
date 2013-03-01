require 'pry'
require 'open-uri'
require 'json'
require 'faraday'


module DigitalOcean
  BadRequest = Class.new(StandardError)

  module Auth
    extend self
    CLIENT_ID, API_KEY = File.open(File.expand_path("~/.digitalocean.auth.rc")).read.split("\n")
  end

  module Core
    extend self

    def basic_connection
      Faraday.new(:url => "https://api.digitalocean.com/" ) do |f|
        f.request :url_encoded
        f.adapter Faraday.default_adapter
      end
    end

    def digital_ocean_url
      "https://api.digitalocean.com/"
    end

    def image_url
      "#{digital_ocean_url}images/"
    end

    def sizes_url
      "#{digital_ocean_url}sizes/"
    end

    def droplet_url
      "#{digital_ocean_url}droplet/"
    end

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
      response = JSON.parse(open(url).read)
      raise BadRequest unless response["status"] == "OK"
      if key[0]
        response.fetch(key[0])
      else
        response
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

  module APIRoot
    extend self
    extend DigitalOcean::Core

    def display_docs
      conn = basic_connection
      conn.get do |r|
      r.url '',  :client_id => DigitalOcean::Auth::CLIENT_ID,
                :api_key => DigitalOcean::Auth::API_KEY
      end
    end
  end
  module Images
    extend self
    extend DigitalOcean::Core

    def show_all
      url = "#{image_url}?#{auth_url}"
      gather_response(url, "images").map do |i|
        Image.new( i["id"], i["name"], i["distribution"] )
      end
    end

    def show(image)
      id = set_id(image)
      conn = basic_connection
      response = conn.get do |r|
        r.url "/image/#{id}"
        r.params['client_id'] = DigitalOcean::Auth::CLIENT_ID
        r.params['api_key'] = DigitalOcean::Auth::API_KEY
      end
      gather_response_faraday(reponse.body, "image")
    end

    def destroy!(image)
      #TODO
    end
  end

  module Sizes
    extend self
    extend DigitalOcean::Core

    def show_all
      url = "#{sizes_url}?#{auth_url}"
      gather_response(url, "sizes").map do |s|
        Size.new( s["id"], s["name"] )
      end
    end
  end

  module Droplets
    extend self
    extend DigitalOcean::Core
    def show_all
      response = basic_connection.get do |r|
        r.url "/droplets/"
        r.params['client_id'] = DigitalOcean::Auth::CLIENT_ID
        r.params['api_key'] = DigitalOcean::Auth::API_KEY
      end
      gather_response_faraday(response.body, "droplets").map { |d| Droplet.new(d) }
    end

    def droplets_request(args)
      id = set_id(args[:droplet])
      action = args.fetch(:action) { "" }
      key = args.fetch(:key) { nil }
      extra_params = args.fetch(:params) { Hash.new }
      response = basic_connection.get do |r|
        r.url "/droplets/#{id}/#{action}/"
        r.params['client_id'] = DigitalOcean::Auth::CLIENT_ID
        r.params['api_key'] = DigitalOcean::Auth::API_KEY
        r.params.merge!(extra_params)
      end
      gather_response_faraday(response.body, key )
    end

    def show(droplet)
      # Droplet.new droplets_request(:droplet => droplet)
      #
      id = set_id(droplet)
      key = "droplet"
      response = basic_connection.get do |r|
        r.url "/droplets/#{id}"
        r.params['client_id'] = DigitalOcean::Auth::CLIENT_ID
        r.params['api_key'] = DigitalOcean::Auth::API_KEY
      end
      Droplet.new gather_response_faraday(response.body, key )
    end

    def create(args)
      #TODO
    end

    def reboot(droplet)
      droplets_request(:droplet => droplet, :action => "reboot")
    end

    alias :restart :reboot

    def power_cycle(droplet)
      droplets_request(:droplet => droplet, :action => "power_cycle")
    end

    def shutdown(droplet)
      droplets_request(:droplet => droplet, :action => "shutdown")
    end

    def power_off(droplet)
      droplets_request(:droplet => droplet, :action => "power_off")
    end

    def power_on(droplet)
      droplets_request(:droplet => droplet, :action => "power_on")
    end

    def password_reset(droplet)
      droplets_request(:droplet => droplet, :action => "password_reset")
    end

    def enable_backups(droplet)
      droplets_request(:droplet => droplet, :action => "enable_backups")
    end

    def disable_backups(droplet)
      droplets_request(:droplet => droplet, :action => "disable_backups")
    end

    def destroy(droplet)
      droplets_request(:droplet => droplet, :action => "destroy")
    end

    def destroy(droplet)
      droplets_request(:droplet => droplet, :action => "destroy")
    end

    def snapshot(droplet, snapshot_name)
      droplets_request(:droplet => droplet,
                       :action => "snapshot",
                       :params => {"name" => snapshot_name},)
    end
    def resize(droplet, size_id)
      droplets_request(:droplet => droplet,
                       :action => "resize",
                       :params => {"size_id" => size_id},)
    end

    def restore(droplet, size_id)
      droplets_request(:droplet => droplet,
                       :action => "restore",
                       :params => {"image_id" => size_id},)

    end
    def rebuild(droplet, size_id)
      droplets_request(:droplet => droplet,
                       :action => "rebuild",
                       :params => {"image_id" => size_id},)

    end
  end

  module Regions
    extend self
    extend DigitalOcean::Core

    def show_all
      response = basic_connection.get do |r|
        r.url "/regions/"
        r.params['client_id'] = DigitalOcean::Auth::CLIENT_ID
        r.params['api_key'] = DigitalOcean::Auth::API_KEY
      end
      gather_response_faraday(response.body, "regions").map { |d| Region.new(d["id"], d["name"])}
    end

#    end
  end

  class Droplet
    include DigitalOcean::Core
    attr_accessor :response_status, :id, :name, :image_id, :size_id, \
      :region_id, :backups_active, :ip_address, :status
    def initialize(droplet)
      @id = droplet["id"]
      @name = droplet["name"]
      @image_id = droplet["image_id"]
      @size_id = droplet["size_id"]
      @region_id = droplet["region_id"]
      @backups_active = droplet["backups_active"]
      @ip_address = droplet["ip_address"]
      @status = droplet["status"]
    end

    def show
      url = "#{droplets_url}#{@id}?#{auth_url}"
      Droplet.new(gather_response(url, "droplet"))
    end

    alias :refresh_info :show

    def power_cycle
      action(self, "power_cycle")
    end

    def shutdown
      action(self, "shutdown")
    end

    def power_off
      action(self, "power_off")
    end

    def power_on
      action(self, "power_on")
    end
  end

  Image = Struct.new(:id, :name, :distribution)

  Size = Struct.new(:id, :name)

  Region = Struct.new(:id, :name)

end
