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
      user = User.find_by_email(params[:email])
      if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to root_url, notice: 'Logged in !'
      else
        render :new
      end
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

      
      token = {
          "access_token": "d2697427cfa244e2cbaf8bc848d264ce5bdfb7731929602a4f236c41797c0238",
          "token_type": "Bearer",
          "expires_in": 2592000,
          "refresh_token": "7011e4cbcd788a77cd023f9a2b5fe5f1874c7085c78f1e4e8e7d4fede5f4756b",
          "scope": "basic",
          "created_at": 1579248890
      }

      headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'Bearer 10'
      }

      response = ApiCall.new("https://showoff-rails-react-production.herokuapp.com", "get", "/api/v1/users/1", "", headers).execute()
      @response = JSON.parse(response.body)
    
      
    end

    def details
      #puts JWT_ID
      params = {
        "client_id": "277ef29692f9a70d511415dc60592daf4cf2c6f6552d3e1b769924b2f2e2e6fe",
        "client_secret": "d6106f26e8ff5b749a606a1fba557f44eb3dca8f48596847770beb9b643ea352"
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
        
        puts session[:token]

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
end
