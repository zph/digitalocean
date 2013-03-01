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
      "client_id=#{ CLIENT_ID }&api_key=#{ API_KEY }"
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
      url = "#{image_url}#{id}?#{auth_url}"
      gather_response(url, "image")
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
      url = "#{droplets_url}?#{auth_url}"
      gather_response(url, "droplets").map { |d| Droplet.new(d) }
    end

    def show(droplet)
      id = set_id(droplet)
      url = "#{droplets_url}#{id}?#{auth_url}"
      Droplet.new(gather_response(url, "droplet"))
    end

    def create(args)
      #TODO
    end

    def reboot(droplet)
      action(droplet, "reboot")
    end

    alias :restart :reboot

    def power_cycle(droplet)
      action(droplet, "power_cycle")
    end

    def shutdown(droplet)
      action(droplet, "shutdown")
    end

    def power_off(droplet)
      action(droplet, "power_off")
    end

    def power_on(droplet)
      action(droplet, "power_on")
    end

    def root_password_reset!(droplet)
      action(droplet, "password_reset")
    end

    def resize!(droplet, new_size_id)
      id = set_id(droplet)
      url = "#{droplets_url}#{id}/resize/?size_id=#{new_size_id}&#{auth_url}"
      gather_response(url)
    end
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

end

# d = DigitalOcean::Droplets.show_all.first

