require 'sinatra'
require 'sqlite3'
require 'securerandom'
require 'pp'

db = SQLite3::Database.new 'db/post.db'
db.results_as_hash = true

get '/' do
  posts = db.execute('SELECT * FROM posts ORDER BY id DESC')
  pp posts
  erb :index, { locals: { posts: posts } }
end

post '/' do
  file_name = ''

  if params['file']
    ext = ''
    if params['file'][:type].include? 'jpeg'
      ext = 'jpg'
    elsif params['file'][:type].include? 'png'
      ext = 'png'
    else
      return '投稿できる画像形式は jpg と png だけです'
    end

    # file_name の指定
    file_name = SecureRandom.hex + '.' + ext

    File.open('./public/uploads/' + file_name, 'wb') do |f|
      f.write params['file'][:tempfile].read
    end
  else
    return '画像が必須です'
  end

  stmt = db.prepare('INSERT INTO posts (text, img_file_name) VALUES (?, ?)')
  stmt.bind_params(params['ex_text'], file_name)
  stmt.execute
  redirect '/'
end

get '/hello' do
  'Hello world'
end

get '/example' do
  erb :example
end

get '/star' do
  post_id = params['post_id'].to_i
  post = db.execute('SELECT star_count FROM posts WHERE id = ?', post_id)
  return 'error' if post.empty?

  new_star_count = post[0]['star_count'] + 1
  stmt = db.prepare('UPDATE posts SET star_count = ? WHERE id = ?')
  stmt.bind_params(new_star_count, post_id)
  stmt.execute
  return 'スターを付けました'
end
