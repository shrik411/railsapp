class UsersController < ApplicationController
    def new_release
        respond_to do |format|
          format.js
        end
    end

    def show
      @post = Post.find(params[id])
      respond_to do |format|
        format.js
      end
    end
end
