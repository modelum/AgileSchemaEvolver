CREATE KEYSPACE IF NOT EXISTS umugram WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE umugram ;

// ADD ENTITY User: { 
	+user_id: String, username: String, 
	!email: String /^.+@.+\\.com$/, password: String, created_at: Timestamp, updated_at: Timestamp }

CREATE TABLE IF NOT EXISTS user
(
  user_id text,
  created_at timestamp,
  email text,
  password text,
  updated_at timestamp,
  username text,
  PRIMARY KEY (user_id)
);

// EXTRACT ENTITY User INTO User_Metadata ( user_id, created_at, updated_at )

COPY user ( user_id, created_at, updated_at ) TO 'tmp.csv' WITH HEADER = TRUE;
CREATE TABLE user_metadata
(
  user_id text,
  created_at timestamp,
  updated_at timestamp,
  PRIMARY KEY (user_id)
);
COPY user_metadata FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD AGGR User::profile: { nameProfile: String, avatar_url: String, description: String, website: String
}&

CREATE TYPE IF NOT EXISTS profile
(
  avatar_url text, 
  description text, 
  nameprofile text, 
  website text
);
ALTER TABLE user ADD profile profile;

// ADD RELATIONSHIP Followers

-- Operation not supported.

// ADD ENTITY Post: {
	+post_id: String, caption: String, description: String, created_at: Timestamp, updated_at: Timestamp }
CREATE TABLE IF NOT EXISTS post
(
  post_id text,
  caption text,
  created_at timestamp,
  description text,
  updated_at timestamp,
  PRIMARY KEY (post_id)
);

// ADD ENTITY VideoPost: {
	+videopost_id: String, videoUrl: String, duration: double
}
CREATE TABLE IF NOT EXISTS videopost
(
  videopost_id text,
  duration double,
  videourl text,
  PRIMARY KEY (videopost_id)
);

// ADD ENTITY PhotoPost: {
	+photopost_id: String, photoUrl: String
}
CREATE TABLE IF NOT EXISTS photopost
(
  photopost_id text,
  photourl text,
  PRIMARY KEY (photopost_id)
);

// ADD ENTITY LivePost: {
	+realpost_id: String,
	+duration : Timestamp }
CREATE TABLE IF NOT EXISTS livepost
(
  realpost_id text,
  duration timestamp,
  PRIMARY KEY (realpost_id, duration)
);

// ADD ENTITY Comment: {
	+comment_id: String, text: String, created_at: Timestamp, updated_at: Timestamp }

CREATE TABLE IF NOT EXISTS comment
(
  comment_id text,
  created_at timestamp,
  text text,
  updated_at timestamp,
  PRIMARY KEY (comment_id)
);

// ADD REF Post::user_id : String& TO User
ALTER TABLE post ADD user_id text;

// ADD REF VideoPost::post_id : String& TO Post
ALTER TABLE videopost ADD post_id text;

// ADD REF PhotoPost::post_id : String& TO Post
ALTER TABLE photopost ADD post_id text;

// ADD REF Comment::user_id : String& TO User
ALTER TABLE comment ADD user_id text;

// ADD REF Comment::replyTo : String& TO Comment
ALTER TABLE comment ADD replyto text;

// ADD REF Comment::post_id : String& TO Post
ALTER TABLE comment ADD post_id text;

// ADD REF Followers::follower_id : String& TO User
ALTER TABLE followers ADD follower_id text;

// ADD REF Followers::following_id : String& TO User

ALTER TABLE followers ADD following_id text;

// CAST ATTR VideoPost::duration TO int

COPY videopost TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE videopost;
CREATE TABLE videopost
(
  videopost_id text,
  post_id text,
  videourl text,
  duration int,
  PRIMARY KEY (videopost_id)
);
COPY videopost FROM 'tmp.csv' WITH HEADER = TRUE;

// RENAME VideoPost::duration TO seconds

COPY videopost ( videopost_id, duration ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE videopost DROP ( duration );
ALTER TABLE videopost ADD seconds int;
COPY videopost ( videopost_id, seconds ) FROM 'tmp.csv' WITH HEADER = TRUE;

// PROMOTE ATTR User::username

COPY user
(
  user_id,username,
  created_at,email,password,profile,updated_at
) TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE user;
CREATE TABLE user
(
  user_id text,
  created_at timestamp,
  email text,
  password text,
  profile profile,
  updated_at timestamp,
  username text,
  PRIMARY KEY (user_id, username)
);
COPY user FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ATTR User::birthday : Timestamp
ALTER TABLE user ADD birthday timestamp;

// ADD ATTR VideoPost::lastMinute : Timestamp
ALTER TABLE videopost ADD lastminute timestamp;

// ADD ATTR Comment::hastag : List<String>

ALTER TABLE comment ADD hastag list<text>;

// RENAME ENTITY User TO UserUmugram

COPY user TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE user;
CREATE TABLE userumugram
(
  user_id text,
  username text,
  birthday timestamp,
  created_at timestamp,
  email text,
  password text,
  profile profile,
  updated_at timestamp,
  PRIMARY KEY (user_id, username)
);
COPY userumugram FROM 'tmp.csv' WITH HEADER = TRUE;

// DELETE ENTITY LivePost
DROP TABLE IF EXISTS livepost;
