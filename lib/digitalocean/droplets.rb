module DigitalOcean
  module Droplets
    extend self
    extend DigitalOcean::Core
    def show_all
      response = basic_connection.get("/droplets/")
      response.body["droplets"].map { |d| Droplet.new(d)}
    end

    # Deprecating this method
    def droplets_request(args)
      id = set_id(args[:droplet])
      action = args.fetch(:action) { "" }
      key = args.fetch(:key) { nil }
      extra_params = args.fetch(:params) { Hash.new }
      response = basic_connection.get do |r|
        r.url "/droplets/#{id}/#{action}/"
        r.params.merge!(extra_params)
      end
      gather_response_faraday(response.body, key )
    end

    def droplets_response(args)
      id = set_id(args[:droplet])
      action = args.fetch(:action) { "" }
      key = args.fetch(:key) { nil }
      extra_params = args.fetch(:params) { Hash.new }
      response = basic_connection.get("/droplets/#{id}/#{action}/") do |r|
        r.params.merge!(extra_params)
      end
    end
    
     # * name Required, String, this is the name of the droplet - must be formatted by hostname rules
     # * size_id Required, Numeric, this is the id of the size you would like the droplet created at
     # * image_id Required, Numeric, this is the id of the image you would like the droplet created with
     # * region_id Required, Numeric, this is the id of the region you would like your server in IE: US/Amsterdam
     # * ssh_key_ids Optional, Numeric CSV, comma separated list of ssh_key_ids that you would like to be added to the server
    def create(args)
      mandatory_variables = %w[name size_id image_id region_id]
      mandatory_variables.each do |d|
        args.fetch(d.to_sym) {raise ArgumentError}
      end

      optional_variables = %w[ssh_key_ids]
      variables = mandatory_variables + optional_variables

      binding.pry
     response = basic_connection.get("/droplets/new") do |c|
       c.params = args.reject { |d| d.nil? }
     end
     id = Droplet.new(response.body["droplet"]).id
     DigitalOcean::Droplets.show(id)
    end

    def show(droplet)
      id = set_id(droplet)
      key = "droplet"
      response = basic_connection.get("/droplets/#{id}")
      Droplet.new(response.body[key])
    end

    def reboot(droplet)
      droplets_response(:droplet => droplet, :action => "reboot").body
    end

    alias :restart :reboot

    def power_cycle(droplet)
      droplets_response(:droplet => droplet, :action => "power_cycle").body
    end

    def shutdown(droplet)
      droplets_response(:droplet => droplet, :action => "shutdown").body
    end

    def power_off(droplet)
      droplets_response(:droplet => droplet, :action => "power_off").body
    end

    def power_on(droplet)
      droplets_response(:droplet => droplet, :action => "power_on").body
    end

    def password_reset(droplet)
      droplets_response(:droplet => droplet, :action => "password_reset").body
    end

    def enable_backups(droplet)
      droplets_response(:droplet => droplet, :action => "enable_backups").body
    end

    def disable_backups(droplet)
      droplets_response(:droplet => droplet, :action => "disable_backups").body
    end

    def destroy(droplet)
      droplets_response(:droplet => droplet, :action => "destroy").body
    end

    def destroy(droplet)
      droplets_response(:droplet => droplet, :action => "destroy").body
    end

    def snapshot(droplet, snapshot_name)
      droplets_response(:droplet => droplet,
                       :action => "snapshot",
                       :params => {"name" => snapshot_name},).body
    end
    def resize(droplet, new_size_id)
      droplets_response(:droplet => droplet,
                       :action => "resize",
                       :params => {"size_id" => set_id(new_size_id)},).body
    end

    def restore(droplet, image_id)
      droplets_response(:droplet => droplet,
                       :action => "restore",
                       :params => {"image_id" => set_id(image_id)},).body

    end
    def rebuild(droplet, image_id)
      droplets_response(:droplet => droplet,
                       :action => "rebuild",
                       :params => {"image_id" => set_id(image_id)},).body

    end
  end
end
