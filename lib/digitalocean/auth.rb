module DigitalOcean
  module Auth
    extend self
    CLIENT_ID, API_KEY = File.open(File.expand_path("~/.digitalocean.auth.rc")).read.split("\n")
  end
end
