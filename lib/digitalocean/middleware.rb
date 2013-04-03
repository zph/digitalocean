module DigitalOcean
  class AuthenticationMiddleware < Faraday::Middleware
    # AuthenticationMiddleware Class Code from DigitalOcean Library by RMoriz
    # See https://github.com/rmoriz/digital_ocean/ for License
    extend Forwardable
    def_delegators :'Faraday::Utils', :parse_query, :build_query

    def initialize(app, args)

      @client_id = args.fetch(:client_id) { DigitalOcean::Auth::CLIENT_ID }
      @api_key   = args.fetch(:api_key) { DigitalOcean::Auth::API_KEY}

      super(app)
    end

    def call(env)
      params = { 'client_id' => DigitalOcean::Auth::CLIENT_ID, 
                 'api_key' => DigitalOcean::Auth::API_KEY }
      params.update query_params(env[:url])

      env[:url].query = build_query params

      @app.call(env)
    end

    def query_params(url)
      if url.query.nil? or url.query.empty?
        {}
      else
        parse_query url.query
      end
    end
  end
end
