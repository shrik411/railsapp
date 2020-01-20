class WidgetsController < ApplicationController

    def index
        @session = session[:token].nil? ? nil : session[:token]

        token = @session["token"]["access_token"]

        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}" 
        }

        params = {
            "client_id": ENV.fetch('CLIENT_ID'),
            "client_secret": ENV.fetch('CLIENT_SECRET')
        }
        response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/users/me/widgets", "", params, headers).execute()
        puts response
        response = JSON.parse(response.body)
        @widgets = response["data"]
    end

    def edit
      @id = params[:id]
    end

    def update
      puts "I am here :)"
    end 
    
    def destroy
      
      @session = session[:token].nil? ? nil : session[:token]
      widget_id = params[:id]
      token = @session["token"]["access_token"]

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}" 
      }

      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "delete", "/api/v1/widgets/#{widget_id}", "", {}, headers).execute()
      response = JSON.parse(response.body)
      puts response
    end

    def listall
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
        #render plain: params[:post].inspect
        if params[:user].nil?
          redirect_to home_path
        end
  
        @session = session[:token].nil? ? nil : session[:token]
        
        token = @session["token"]["access_token"]

        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}" 
        }

        userDetails =  {
          "widget": {
            "name": params[:post]["name"],
            "description": params[:post]["description"],
            "kind": params[:post]["kind"]
          }
        }
  
        response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "post", "/api/v1/widgets", userDetails,  {}, headers).execute()
        puts response
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
