#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new'Lepraz.db'
	@db.results_as_hash = true
end
# before вызывается каждый раз при загрузке 
# любой страницы

before do
	# инициализайия БД
	init_db
end
# configure вызывается каждый раз при инициализайии приложения:
# когда изминился код программы и перезагрузилась страница
configure do
	# инициализация БД
	init_db

	# создаёт таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		create_date DATE,
		content TEXT
	)'

	# создаёт таблицу если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		create_date DATE,
		content TEXT,
		post_id INTEGER
	)'	
end

get '/' do
	# выбираем список постов из БД

	@results = @db.execute 'select * from Posts order by id desc'

	erb :index			
end

# обработчик get-запроса /new
# браузер получает страницу с сервера
get '/new' do
	erb :new
end	

# обработчик post-запроса /new
# браузер отправляет данные на сервер
post '/new' do
	# Получаем переменную из post запроса
	content = params[:content]
	# Проверка параметров
	if content.length <= 0
		@error = 'Введите текст'
		return erb :new
	end


	# Сохранение данных в бд
	@db.execute 'insert into Posts (content, create_date) values (?, datetime())',[content]
	# перенаправление на гл стр
	redirect to '/'	
end

# вывод информации о посте (Универсальный оработчик)

get '/details/:post_id' do

	# Получаем переменную из url`a
	post_id = params[:post_id]
	# Получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	#выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем комментарий для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик пост запроса /details/... 
# (браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do
	# Получаем переменную из url`a
	post_id = params[:post_id]
	# Получаем переменную из post запроса
	content = params[:content]

	# Сохранение данных в бд
	@db.execute 'insert into Comments (content, create_date, post_id) values (?, datetime(), ?)',[content, post_id]

	# перенаправление на стр поста
	redirect to ('/details/' + post_id)	

	erb "You typed comment #{content} for post #{post_id}"
end



