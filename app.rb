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
		create_date	DATE,
		content TEXT
		)'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
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


	erb "You typed #{content}"
end