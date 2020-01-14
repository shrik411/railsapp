class ApiCall < ActiveRecord::Base
    extend Enumerize
  
    REQUEST_OPEN_READ_TIMEOUT_IN_SECONDS = 300
  
    belongs_to :parent, polymorphic: true
  
    enumerize :request_method, in: [:post, :patch, :get, :delete]
    enumerize :state, in: [:new, :sent, :retry, :failed], methods: true, predicates: true
  
    default_scope { order(:created_at.desc) }
  
    serialize :headers, PureJSONWithIndifferentAccess
    before_save :set_headers
  
    def pretty_print_body
      pretty_print_data(request_body)
    end
  
    def pretty_print_success_message
      pretty_print_data(success_message)
    end
  
    def add_available_attempts(value)
      increment!(:available_attempts, value)
    end
  
    def retry
      if has_available_attempts?
        update_attributes(
          state: :retry,
          available_attempts: self.available_attempts - 1,
        )
      end
    end
  
    def has_available_attempts?
      available_attempts.to_i > 0
    end
  
    STATES_FOR_EXECUTION = [:retry, :new]
    def execute(options={})
      return unless STATES_FOR_EXECUTION.include?(self.state.try(:to_sym))
  
      response = faraday(options).run_request(
        request_method.to_sym,
        path,
        request_body,
        headers
      )
  
      response_success = response.status >= 200 && response.status <= 299
      response_body = response.body
      response_status = response.status
  
      if response_success
        update_attributes(
          state: :sent,
          sent_at: DateTime.now,
          new_issue: nil,
        )
        write_success "#{response_body}"
      else
        write_error "Server returned #{response_status}:\n\n#{response_body}"
      end
      return response
  
    rescue StandardError => e
      write_error "#{e.message}\n\n#{e.backtrace.join("\n")}"
    end
  
    def faraday(options={})
      params = if Rails.env.test? || Rails.env.development?
                 {timeout: 10, open_timeout: 10}
               else
                 {timeout: REQUEST_OPEN_READ_TIMEOUT_IN_SECONDS}
               end
  
      @faraday ||= Faraday.new(options.merge({ url: host, request: params }))
  
      @faraday
    end
  
    def faraday=(value)
      @faraday = value
    end
  
    protected
  
    def set_headers
      self.headers = {
        'Content-Type' => 'application/json',
      } unless self.headers.present?
    end
  
    def host
      @host ||= URI.join(url, '/').to_s
    end
  
    def path
      @path = uri(url).path
      query_params = uri(url).query
      @path += "?#{query_params}" if query_params.present?
      @path
    end
  
    def query_params
      params = URI(url).query
      params.nil? ? nil : "?"+params
    end
  
    def uri(url)
      @_uri ||= URI(url)
    end
  
    def write_error(message)
      update_attributes(
        error_message: message,
        state: :failed,
        new_issue: true,
      )
    end
  
    def write_success(message)
      update_attributes(
        success_message: message
      )
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