module DigitalOcean
  module Images
    extend self
    extend DigitalOcean::Core

    def show_all
      response = basic_connection.get("/images/")
      response.body["images"].map do |i|
        Image.new( i["id"], i["name"], i["distribution"] )
      end
    end

    def show(image)
      id = set_id(image)
      response = basic_connection.get("/image/#{id}")
      response.body["image"]
    end

    def destroy!(image)
      #TODO
    end
  end
end
