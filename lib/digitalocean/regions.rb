module DigitalOcean
  module Regions
    extend self
    extend DigitalOcean::Core

    def show_all
      response = basic_connection.get('/regions/')
      response.body[ "regions" ].map { |d| Region.new(d["id"], d["name"])}
    end
  end
end
