module DigitalOcean

  module SSHKeys
    extend self
    extend DigitalOcean::Core

    def show_all
      response = basic_connection.get("/ssh_keys/")
      response.body["ssh_keys"].map { |k| SSHKey.new(k["id"], k["name"])}
    end

    def show(id)
      response = basic_connection.get("/ssh_keys/#{set_id(id)}/")
      k = response.body["ssh_key"]
      SSHKey.new(k["id"], k["name"], k["ssh_pub_key"])
    end

    def add(name, pub_key)
      response = basic_connection.get("/ssh_keys/new/") do |f|
        f.params = {:name => name, :ssh_key_pub => pub_key }
      end
      k = response.body["ssh_key"]
      SSHKey.new(k["id"], k["name"], k["ssh_pub_key"])
    end

    def edit()
      #TODO
      #Not yet implemented in DigitalOcean
    end

    def destroy(id)
      response = basic_connection.get("/ssh_keys/#{set_id(id)}/destroy/")
      response.body["status"]
    end
  end
end
