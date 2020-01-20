class UsersController < ApplicationController
    
    def new_release
        respond_to do |format|
          format.js
        end
    end

    def new 
      @user = User.new 
    end

    def create
      if params[:user].nil?
        redirect_to home_path
      end

      userDetails =  {
        "client_id": ENV.fetch('CLIENT_ID'),
        "client_secret": ENV.fetch('CLIENT_SECRET'),
        "user": {
          "first_name": params[:user]["firstname"],
          "last_name": params[:user]["lastname"],
          "password": params[:user]["password"],
          "email": params[:user]["email"],
          "image_url": params[:user]["image_url"]
        }
      }

      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "post", "/api/v1/users", userDetails,  {}).execute()
      @response = JSON.parse(response.body)
      @user =  @response["data"]

      if (!@user.nil?)
        session[:token] = @user["token"]
      end

      redirect_to home_path
    end
    
    def destroy
      session[:token] = nil
      redirect_to home_url, notice: 'Logged out!'
    end

    def new_release
      respond_to do |format|
        format.html
        format.js
      end
    end

    def show
      id = params["id"]

      # check if id is present and user is logged in
      if (id and !session[:token].nil?) 
        token = session[:token]["token"]["access_token"]
        puts token
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}" 
        }
        @widget = get_widgets(id)
        puts @widget
        
        response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/users/#{id}", {},  {}, headers).execute()
        @response = JSON.parse(response.body)
        @message = @response["message"]
        @user =  @response["data"]

        puts @user
      else
        redirect_to home_path
      end
      
    end

    def details
      #puts JWT_ID
      params = {
        "client_id": ENV.fetch('CLIENT_ID'),
        "client_secret": ENV.fetch('CLIENT_SECRET'),
      }
      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "", "/api/v1/widgets/visible", params).execute()
      response = JSON.parse(response.body)
      @widgets = response["data"]
    end

    def login
        #auth_object = Authentication.new(login_params)
        if params[:session].nil?
          redirect_to home_path
        end


        body =  {
            "grant_type": "password",
            "client_id": ENV.fetch('CLIENT_ID'),
            "client_secret": ENV.fetch('CLIENT_SECRET'),
            "username": params[:session][:username],
            "password": params[:session][:password]
        }

        response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "post", "/oauth/token", body , {}).execute()
        response = JSON.parse(response.body)
        @token = response["data"]
        if (!@token.nil?)
          session[:token] = @token
        end

        redirect_to home_path

        # if auth_object.authenticate
        #   render json: {
        #     message: "Login successful!", token: auth_object.generate_token }, status: :ok
        # else
        #   render json: {
        #     message: "Incorrect username/password combination"}, status: :unauthorized
        # end
    end

    private
    def login_params
      params.permit(:username, :password)
    end

    def get_widgets(id)
      params = {
          "client_id": ENV.fetch('CLIENT_ID'),
          "client_secret": ENV.fetch('CLIENT_SECRET')
      }
      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/users/#{id}/widgets", "", params).execute()
      response = JSON.parse(response.body)
      @widgets = response["data"]
    end
end
