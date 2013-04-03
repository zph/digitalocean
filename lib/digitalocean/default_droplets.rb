module DigitalOcean
  module DefaultDroplets
    extend self

    def small_us # Small, US, Ubuntu 12.04 x32 Server
      {:name => "smallus",
       :size_id => 66,
       :image_id => 42735,
       :region_id => 1,
       :ssh_key_ids => DigitalOcean::SSHKeys.show_all.first.id,
      }
    end
  end
end
