require 'pg'
require 'digest/sha1'
require 'securerandom'

def db_connection
  begin
    connection = PG.connect(dbname: 'sessions')
    yield(connection)
  ensure
    connection.close
  end
end

def sign_up(username, password)
  salt = SecureRandom.hex(32)
  digest = Digest::SHA1.hexdigest(password + salt)
  if existing_username?(username) == false
    db_connection do |conn|
      query = "INSERT INTO users (username, salt, digest)
               VALUES ($1, $2, $3)"
      conn.exec_params(query, [username, salt, digest])
    end
  end
end

def existing_username?(username)
  results = []
  db_connection do |conn|
    query = "SELECT users.username FROM users
             WHERE users.username = $1"
    results = conn.exec_params(query, [username])
  end
  if results.to_a.size == 0
    return false
  end
  true
end

def login(username, password)
  login_results = []
  db_connection do |conn|
    query = "SELECT users.id, users.username, users.salt, users.digest
             FROM users WHERE $1 = users.username LIMIT 1"
    login_results = conn.exec_params(query, [username])
  end
  if login_results.to_a.size != 0
    test_digest = Digest::SHA1.hexdigest(password + login_results[0]["salt"])
    if test_digest == login_results[0]["digest"]
      return login_results[0]["id"]
    end
  end
  false
end

def check_user(id)
  results = ""
  db_connection do |conn|
    query = "SELECT users.id, users.username FROM users
             WHERE users.id = $1"
    results = conn.exec_params(query, [id])
  end
  results[0]["username"]
end
