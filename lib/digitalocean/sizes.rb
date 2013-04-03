module DigitalOcean
  module Sizes
    extend self
    extend DigitalOcean::Core

    def show_all
      # url = "#{sizes_url}?#{auth_url}"
      response = basic_connection.get("/sizes/")
      response.body["sizes"].map do |s|
        Size.new( s["id"], s["name"] )
      end
    end
  end
end
