class WidgetsController < ApplicationController

    def index
        puts ApiCall.new("https://jsonplaceholder.typicode.com/todos/1").execute()
        #puts response 
    end

    def new
        
    end

    def create
        render plain: params[:post].inspect
    end

end
