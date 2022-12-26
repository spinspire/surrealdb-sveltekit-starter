--- see https://gist.github.com/koakh/fbbc37cde630bedcf57acfd4d6a6956b

---opt1:SCHEMALESS
---DEFINE TABLE user SCHEMALESS
---  PERMISSIONS 
---    FOR select, update WHERE id = $auth.id, 
---    FOR create, delete NONE;

---opt2:SCHEMAFULL
DEFINE TABLE user SCHEMAFULL
  PERMISSIONS 
    FOR select, update WHERE id = $auth.id, 
    FOR create, delete NONE;

DEFINE FIELD user ON user TYPE string;
DEFINE FIELD pass ON user TYPE string;
DEFINE FIELD settings.* ON user TYPE object;
DEFINE FIELD settings.marketing ON user TYPE string;
DEFINE FIELD tags ON user TYPE array;
DEFINE INDEX idx_user ON user COLUMNS user UNIQUE;

-- define scope
DEFINE SCOPE allusers
  -- the JWT session will be valid for 14 days
  SESSION 14d
  -- The optional SIGNUP clause will be run when calling the signup method for this scope
  -- It is designed to create or add a new record to the database.
  -- If set, it needs to return a record or a record id
  -- The variables can be passed in to the signin method
  SIGNUP ( CREATE user SET settings.marketing = $marketing, user = $user, pass = crypto::argon2::generate($pass), tags = $tags )
  -- The optional SIGNIN clause will be run when calling the signin method for this scope
  -- It is designed to check if a record exists in the database.
  -- If set, it needs to return a record or a record id
  -- The variables can be passed in to the signin method
  SIGNIN ( SELECT * FROM user WHERE user = $user AND crypto::argon2::compare(pass, $pass) )
  ;

-- a table for everyone
--DEFINE TABLE todo SCHEMALESS PERMISSIONS FULL;
DEFINE TABLE todo SCHEMAFULL
  PERMISSIONS
    FOR select, update, create, delete WHERE user = $auth.id;

DEFINE FIELD title ON todo TYPE string;
DEFINE FIELD completed ON todo TYPE bool;
DEFINE FIELD user ON todo TYPE record(user) VALUE $session.sd ASSERT $value != null;
