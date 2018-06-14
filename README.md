# Day06 : Controller와 Model



## 1. Controller

- '서비스 로직'을 가지고 있음
- `sinatra`의`app.rb`에서 작성했던 내용이 `controller`에 들어감
- `Controller`는 하나의 서비스에 대해서만 관련함
- `Controller를 `만들 때의 명령어는 `$ rails g controller`

```command
# home 이란 controller 생성
# app/controllers/home_controllers
$ rails g controller home
```

*app/controllers/home_controller.rb*

``` rb
class HomeController < ApplicationController
	# 상단의 코드는 ApplicationController를 상속받는 코드
end
```

- `HomeController`를 만들면 app/views 하위에 컨트롤러 명과 일치하는 폴더가 생김
- `HomeController`에서 액션(`def`)을 작성하면 해당 액션명과 일치하는 `view`파일을 *app/views/home*폴더 밑에 작성함
- *config/routes.rb*에서 사용자의 요청을 받는 url 설정



*config/routes.rb*

```ruby
Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # /home/index에 접속하면 home 컨트롤러의 index 액션을 실행함
  get '/home/index' => 'home#index'
  post '/home/index' => 'home#create'
end
```



- `$ rails s -b $IP -p $PORT` 서버를 실행 

  (상단의 'Run' 버튼을 클릭해 주소를 미리 알아둔 후 stop, 위의 명령어를 입력할 것)



> Rails에서 Development, Test, Production 환경(모드) 3가지가 있음
>
> Development 환경: 변경사항이 자동적으로 확인되고, 모든 로그가 찍힘
>
> Production 환경: 변경사항도 자동적으로 저장되지 않고, 로그도 일부만  `$ rails s`로 서버를 실행하지 않음



#### 간단과제. 점심 메뉴 추천 시스템

- 점심메뉴를 랜덤으로 보여줌
- 글자 + 이미지가 출력
- 점심메뉴를 저장하는 변수는 `Hash`타입
  - @lunch = {"점심메뉴 이름" => "https:// ... .jpg"}
  - `Hash`에서 모든 key 값을 가져오는 메소드는 `.keys`
- 요청은 /lunch로 받음



*config/routes.rb*

```ruby
Rails.application.routes.draw do
	get '/lunch' => 'home#lunch'
end
```

*controllers/home_controller*

```ruby
class HomeController < ApplicationController
    ...
    def lunch
        @menu = {
            "순대국밥" => "(구글 이미지 주소 삽입)",
            "김밥카페" => "(구글 이미지 주소 삽입)",
            "순남시래기" => "(구글 이미지 주소 삽입)"
            }
    		@lunch = @menu.keys.sample
	end
end
```

*views/home/lunch*

```erb
<img src= "<%= @menu[@lunch] %>">
<h1>오늘의 점심 메뉴는 <%= @lunch %> 입니다.</h1>
```





## 2. Model

`$ rails g model 모델명` : Model 생성하기

```command
# user 라는 Model을 생성
$ rails g model user
Running via Spring preloader in process 3984
      invoke  active_record
      # spring VO 역할을 함
      create    db/migrate/20180614021019_create_users.rb
      # 아무것도 입력돼있지 않더라도, 테이블이 존재하는 곳
      create    app/models/user.rb
      invoke    test_unit
      create      test/models/user_test.rb
      create      test/fixtures/users.yml
```

*db/migrate/20180614021019_create_users.rb*

```erb
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      # string 타입의 "user_name"과 "password"를 선언                                 
      t.string "user_name"
      t.string "password"
    
      t.timestamps
    end
  end
end
```

- `$ rake db:migrate` 명령어를 통해 db를 생성해줘야 함
  - *db/schema.rb* 에서 table이 생성된 것을 확인할 수 있음
  - *db/development.sqlite3* 가 생성된 것을 확인함

- 테이블에 새로운 변수를 추가했을 때, table을 drop한 후 다시 migrate 해야 함

  - `$ rake db:drop` 한 후,  `$ rake db:migrate` 

  

*`$ rails c`* *를 통해 db가 잘 만들어졌는지 확인할 수 있음*

```ruby
2.3.4 :01 > u1 = User.new	# 테이블 row 한줄을 추가함
2.3.4 :012 > u1.user_name = "HaHa"  # 한 줄의 속성(user_name)을 변경함
 => "HaHa" 
2.3.4 :013 > u1.save	# memory로 있던 것이 '.save'실행 후 db에 반영됨
   (0.2ms)  begin transaction
  SQL (0.6ms)  UPDATE "users" SET "user_name" = ?, "updated_at" = ? WHERE "users"."id" = ?  [["user_name", "HaHa"], ["updated_at", "2018-06-14 02:28:27.289147"], ["id", 1]]
   (14.7ms)  commit transaction
 => true 
2.3.4 :014 > u1
 => #<User id: 1, user_name: "HaHa", password: nil, created_at: "2018-06-14 02:23:20", updated_at: "2018-06-14 02:28:27"> er
```

- Model 파일( /models/user.rb)을 이용해서 DB에 있는 자료를 조작
- 위의 내용이 `controller`에 들어갈 내용



#### 간단과제. 로또 번호 추천

- 그동안에 뽑혔던 내역을 저장해주는 로또번호 추천기
- /lotto => 새로 추천받은 번호를 출력
  - a 태그를 이용해서 새로운 번호를 발급
  - 새로 발급된 번호가 가장 마지막과 최상단에 같이 나옴
  - 최상단의 메시지는 이번주 로또 번호는 [..] 입니다.
- /lotto/new => 신규 번호를 발급, 저장 후 /lotto로 redirect
- 모델명: Lotto
- Controller명 : LottoController



`$ rails g controller lotto` : controller와 view가 생성됨

`$ rails g model lotto` : model과 db를 구축할 구역이 생성됨

1. *db/migrate/20180614052514_create_lottos.rb*

```ruby
# 6자리 숫자를 저장했다가 다시 화면에 보여줘야 함
# "numbers" 변수를 string 타입으로 선엄
class CreateLottos < ActiveRecord::Migration[5.0]
  def change
    create_table :lottos do |t|
      t.string "numbers"
      t.timestamps
    end
  end
end
```

`$ rake db:migrate`

2. config/routes.rb  : controller와 view를 연결

```ruby
# 어떤 url을 입력했을 때, 어떤 action이 발생할 것인지 설정
# 1. 샘플링한 로또번호를 보여줘야 함, 2. 새로운 로또번호 받기 버튼, 3. 전에 나왔던 번호 계속 기록해서 보여주기
Rails.application.routes.draw do
    # 전체 화면 보여주기
    # index 뷰 생성할 예정
    get '/lotto' => 'lotto#index'
    # '새로운 로또번호 받기' 버튼을 눌렀을 때
    get '/lotto/new' => 'lotto#new'
end
```

3. *controller/lotto_controller.rb*

```ruby
class LottoController < ApplicationController
   def index
       @new_number = Lotto.last
       @numbers = Lotto.all
   end
    
   def new
       number = (1..45).to_a.sample(6).sort.to_s
       # db에 있는 Lotto라는 테이블에 새로운 row를 생성하는데, 이름은 lotto
       lotto = Lotto.new
       # db/migrate/20180614.. 이곳에서 선언한 t.string "numbers"
       # numbers에 새로 뽑힌 number를 저장
       lotto.numbers = number
       lotto.save  # 테이블에 반영 완료
       redirect_to '/lotto'
   end
    
end
```

4. *views/lotto/index.html.erb*

```html
<p>이번주 추천 숫자는 <%= @new_number.numbers %></%></p>
<a href="/lotto/new">새번호 받기</a>
<ul>
    <% @numbers.each do |number| %>
    <li><%= number.numbers %></%></li>
    <% end %>
</ul>
```

- 최초 접속시 @new_number가 nil이기 때문에 url로 `/lotto/new`로 우선 접속을 하는 것이 좋음





#### 간단과제. 회원가입

- 회원가입을 위한 id, password 입력창이 있는 폼이 필요함

  /users/new => new 액션 실행

- 회원가입 버튼을 통해 db에 데이터가 저장되야 함

  /user/create => create 액션 실행

- 회원가입 되면서 개인 페이지로 연결됨

  /user/:id => show 액션 실행

- 유저를 모두 보여주는 리스트를 출력

  /users  =>  index 액션 실행



`$ rails g controller user`

`$ rails g model user`



1. *db/migrate/20180614021019_create_users.rb*

```ruby
# id와 password를 저장해야 함, 변수로 선언하기
class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string "user_name"
      t.string "password"
    
      t.timestamps
    end
  end
end
```

2. *config/routes*

```ruby
Rails.application.routes.draw do
    # 회원가입
    get '/users/new' => 'user#new'
    # db에 정보 저장
    post '/user/create' => 'user#create'
    # my page
    get '/user/:id' => 'user#show'
    # 전제 유저 목록 보기
    get '/users' => 'user#index'
end
```

3. *controllers/user_controller.rb*

```ruby
class UserController < ApplicationController
    def new
    end
    
    def create
        user_name password
        u1 = User.new
        u1.user_name = params[:user_name]
        u1.password = params[:password]
        u1.save
        redirect_to "/user/#{u1.id}"
    end
    
    # id를 보여주면서 환영하는 my page 구간으로, 변수 정의
    def show
        @user = User.find(params[:id])
    end
    
    # 유저 전체의 데이터를 가지고 있는 변수 정의
    def index
        @users = User.all
    end
end
```

4. 1.views/user/new.html.erb

```html
<form action="/user/create" method="POST">
    <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
    <input type="text" name="user_name" placeholder="ID" > <br>
    <input type="password" name="password" placeholder="비밀번호"> <br>
    <input type="submit" value="회원가입">
</form>
```

- Rails에서 POST 방식으로 요청을 보낼 때 반드시 특정 토큰을 함께 보내야 함 (새로운 정보가 등록될 때)
- `form_authenticity_token `형식으로 토큰을 만들어 보내기
- `application_controller.rb`에서 아래와 같이 주석처리 한다면 토큰을 만들 필요가 없지만, 보안상의 이슈로 주석처리를 안하는 것이 좋음

*controllers/application_controller.rb*

```ruby
class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
end
```



4. 2.views/user/show.html.erb

```html
<h3><%= @user.user_name %>님 환영합니다.</h3>
<p><%= @user.password %></p>
<a href="/users">전체 유저 보기</a>
```

4. 3.views/user/index.html.erb

```html
<ul>
    <% @users.each do |user| %>
        <li><%= user.user_name %></li>
    <% end %>
</ul>	  
<a href="/users/new">새 회원 등록</a>
```

