# DigitalOcean API in Ruby

If you found this by Googling, you might be in the wrong place. Go to [digital_ocean](https://github.com/rmoriz/digital_ocean) instead or install their Gem from RubyGems.  Their code is more established and tested.

###You've been warned! I can't be held responsible if your computer or Droplets explode in a shower of magma.

## Getting started

This is an _ALPHA_ library for wrapping the DigitalOcean VPS API in `Ruby` for my own use.  This is not thoroughly tested or ready for production. This is a project for fun and might/will be dropped when I no longer need the functionality.

But if you find something useful in here, cool!

## Getting started

Install via `Bundler`
Run `ruby ./lib/digitalocean.rb` (which will drop you into a Pry Session)

## Sample Commands
```ruby
1.9.3 (main):0 > DigitalOcean::Droplets.show_all
=> [#<DigitalOcean::Droplet:0x007f8dfc8ccad0
@backups_active=true,
@id=XXXXXX,
@image_id=42735,
@ip_address="XXX.XXX.XXX.XXX",
@name="civet",
@region_id=1,
@size_id=66,
@status="active">,
#<DigitalOcean::Droplet:0x007f8dfc8cc8f0
@backups_active=nil,
@id=XXXXX,
@image_id=42735,
@ip_address="XXX.XXX.XXX.XXX",
@name="railshost",
@region_id=1,
@size_id=66,
@status="active">]
1.9.3 (main):0 > droplet = DigitalOcean::Droplets.show_all.first
=> #<DigitalOcean::Droplet:0x007f8dfd1c23b0
@backups_active=true,
@id=XXXXX,
@image_id=42735,
@ip_address="XXX.XXX.XXX.XXX",
@name="civet",
@region_id=1,
@size_id=66,
@status="active">
1.9.3 (main):0 > droplet.size
=> #<struct DigitalOcean::Size id=66, name="512MB">
```

Code has nearly 100% Coverage of the DigitalOcean API.  Both a literal translation of the commands are available:

`DigitalOcean::Droplets.show_all`

This Ruby Wrapper also allows acting on individual servers as objects.  I.E. the values returned from traditional API calls are used to instantiate `Droplet` objects.  This enables easier manipulation of server collections:

`DigitalOcean::Droplets.show_all.each(&:shutdown)`

Explore library in your favorite REPL (hint: Use Pry Gem)

Questions, feedback, narwhals sounds: [@_ZPH](http://www.twitter.com/_ZPH)
