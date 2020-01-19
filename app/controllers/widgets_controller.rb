class WidgetsController < ApplicationController

    def index
        @session = session[:token].nil? ? nil : session[:token]
        params = {
            "client_id": ENV.fetch('CLIENT_ID'),
            "client_secret": ENV.fetch('CLIENT_SECRET')
        }
        response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/widgets/visible", "", params).execute()
        response = JSON.parse(response.body)
        @widgets = response["data"]
    end

    def new
      
    end

    def search
      @searchText = params[:search].split("=").last
      
      params = {
        "client_id": ENV.fetch('CLIENT_ID'),
        "client_secret": ENV.fetch('CLIENT_SECRET'),
        "term": @searchText
      }
      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/widgets/visible", "", params).execute()
      response = JSON.parse(response.body)
      @selected = response["data"]
      @selected = @selected["widgets"]
      
      respond_to do |format|
        format.js
      end
    end

    def create
        render plain: params[:post].inspect
    end

    def list
        authorization_object = Authorization.new(request)
        current_user = authorization_object.current_user
        if current_user == Group.find(params[:id]).created_by
          # post message
        else
          # respond: You are not allowed to post to this group
        end
      end

end
