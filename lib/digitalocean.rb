require 'pry'
require 'open-uri'
require 'json'
require 'faraday'
require 'faraday_middleware'
require_relative './digitalocean/core'
require_relative './digitalocean/auth'
require_relative './digitalocean/default_droplets'
require_relative './digitalocean/images'
require_relative './digitalocean/ssh_keys'
require_relative './digitalocean/droplets'
require_relative './digitalocean/droplet'
require_relative './digitalocean/middleware'
require_relative './digitalocean/sizes'
require_relative './digitalocean/regions'


module DigitalOcean

  module APIRoot
    extend self
    extend DigitalOcean::Core

    def display_docs
      basic_connection.get.body
    end
  end

  Image = Struct.new(:id, :name, :distribution)

  Size = Struct.new(:id, :name) do
    alias :ram :name
  end

  Region = Struct.new(:id, :name)

  BadRequest = Class.new(StandardError)

  SSHKey = Struct.new(:id, :name, :ssh_pub_key)

end

if $0 == __FILE__
  binding.pry
end
