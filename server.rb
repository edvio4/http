require "sinatra"
require "pg"

def db_connection
  begin
    connection = PG.connect(dbname: "todo")
    yield(connection)
  ensure
    connection.close
  end
end

set :public_folder, File.join(File.dirname(__FILE__), "public")

get "/hello" do
  "<p>Hello, world! The current time is #{Time.now}.</p>"
end

get "/tasks" do
  # Retrieve the name of each task from the database
  @tasks = db_connection { |conn| conn.exec("SELECT name FROM tasks") }
  erb :index
end

post "/tasks" do
  task = params["task_name"]

  # Insert new task into the database
  db_connection do |conn|
    conn.exec_params("INSERT INTO tasks (name) VALUES ($1)", [task])
  end

  # Send the user back to the home page which shows
  # the list of tasks
  redirect "/tasks"
end
