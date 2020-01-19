class ApiCall
    attr_accessor :url
    attr_accessor :request_method
    attr_accessor :path
    attr_accessor :request_body
    attr_accessor :get_params
    attr_accessor :headers

    def initialize(url, request_method, path, request_body, get_params, headers=default_headers)
        @url = url
        @request_method = request_method
        @path = path
        @request_body = request_body
        @get_params = get_params
        @headers = headers
    end

    def pretty_print_body
      pretty_print_data(request_body)
    end
  
    def pretty_print_success_message
      pretty_print_data(success_message)
    end

    def execute(options={})
      response = faraday(options).run_request(
        request_method.to_sym,
        path,
        request_body.to_json,
        headers
      )
    
      response_success = response.status >= 200 && response.status <= 299
      response_body = response.body
      response_status = response.status

      return response
    end
  
    def faraday(options={})
      params = if Rails.env.test? || Rails.env.development?
                 {timeout: 10, open_timeout: 10}
               else
                 {timeout: REQUEST_OPEN_READ_TIMEOUT_IN_SECONDS}
               end
  
      @faraday ||= Faraday.new(options.merge({ url: host, params: get_params, request: params, ssl: { verify: false } }))
  
      @faraday
    end
  
    def faraday=(value)
      @faraday = value
    end
  
    protected
  
    def default_headers
      {
        'Content-Type' => 'application/json',
      }
    end
  
    def host
      @host ||= URI.join(url, '/').to_s
    end
  
    # def path
    #   @path = uri(url).path
    #   query_params = uri(url).query
    #   @path += "?#{query_params}" if query_params.present?
    #   @path
    # end
  
    def query_params
      params = URI(url).query
      params.nil? ? nil : "?"+params
    end
  
    def uri(url)
      @_uri ||= URI(url)
    end
  
    private
  
    def pretty_print_data(data)
      headers = self.headers || {}
      if headers['Content-Type'].present? && headers['Content-Type'].match(/json/i) && data.present?
        pretty_print_data = JSON.pretty_generate(JSON.parse(data))
      elsif headers['Content-Type'].present? && headers['Content-Type'].match(/xml/i) && data.present?
        pretty_print_data = Nokogiri::XML.parse(data).to_s
      else
        pretty_print_data = data
      end
    end
  
  end