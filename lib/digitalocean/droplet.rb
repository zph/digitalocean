module DigitalOcean

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
      response = basic_connection.get("/droplets/#{@id}")
      Droplet.new(response.body["droplet"])
      droplet = response.body["droplet"]
      update_values(droplet)
    end

    def update_values(new_values)
      if new_values.is_a? Hash
        droplet = new_values
      else
        raise ArgumentError
      end

      @id = droplet["id"]
      @name = droplet["name"]
      @image_id = droplet["image_id"]
      @size_id = droplet["size_id"]
      @region_id = droplet["region_id"]
      @backups_active = droplet["backups_active"]
      @ip_address = droplet["ip_address"]
      @status = droplet["status"]
      self
    end

    def size
      @size = DigitalOcean::Sizes.show_all.select { |d| d if d.id == @size_id }[0]
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
end
