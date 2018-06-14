class UserController < ApplicationController
    def index
        # User 테이블의 모든 정보를 변수에 담기
        @users = User.all
    end
    
    def new
    end
    
    def create
        u1 = User.new
        u1.user_name = params[:user_name]
        u1.password = params[:password]
        u1.save
        redirect_to "/user/#{u1.id}"
    end
    
    def show
        params[:id]
        @user = User.find(params[:id])
    end
    
end
