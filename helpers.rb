require 'pg'
require 'digest/sha1'
require 'securerandom'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'mercs')
    yield(connection)
  ensure
    connection.close
  end
end

def sign_up(username, password, role = nil, business_name = nil)
  salt = SecureRandom.hex(32)
  digest = Digest::SHA1.hexdigest(password + salt)
  business_id = nil
  if !business_name.nil?
    if existing_busines?(business_name) == false
      db_connection do |conn|
        query = "INSERT INTO businesses (business_name) VALUES ($1) RETURNING id"
        business_id = conn.exec_params(query,[business_name])[0]["id"]
      end
    end
  end

  if existing_username?(username) == false
    user_id = nil
    db_connection do |conn|
      query = "INSERT INTO users (business_id, username, salt, digest, user_role)
               VALUES ($1, $2, $3, $4, $5) RETURNING id"
      user_id = conn.exec_params(query, [business_id, username, salt, digest, role])[0]["id"]
      binding.pry
    end
    db_connection do |conn|
      query = "INSERT INTO user_roles (user_id, role_id) VALUES ($1, $2)"
      conn.exec_params(query,[user_id, role])
    end
  end
end

def existing_busines?(business)
  results = []
  db_connection do |conn|
    query = "SELECT businesses.business_name FROM businesses
             WHERE businesses.business_name = $1"
    results = conn.exec_params(query, [business])
  end
  if results.to_a.size == 0
    return false
  end
  true
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

def existing_role?(role)
  results = []
  db_connection do |conn|
    query = "SELECT roles.role_name FROM roles
             WHERE roles.role_name = $1"
    results = conn.exec_params(query, [role])
  end
  if results.to_a.size ==0
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
