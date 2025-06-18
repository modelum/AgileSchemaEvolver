CREATE DATABASE IF NOT EXISTS umugram;

USE umugram;

/* ADD ENTITY User: { 
	+user_id: String, username: String, 
	!email: String /^.+@.+\\.com$/, password: String, created_at: Timestamp, updated_at: Timestamp }

 */
CREATE TABLE IF NOT EXISTS USER
(
	created_at TIMESTAMP,
	email VARCHAR(100) CHECK (email REGEXP '^.+@.+\\.com$'),
	password VARCHAR(100),
	updated_at TIMESTAMP,
	user_id VARCHAR(100),
	username VARCHAR(100),
	CONSTRAINT user_email_ak UNIQUE(email),
	CONSTRAINT user_pk PRIMARY KEY (user_id)  
);

/* EXTRACT ENTITY User INTO User_Metadata ( user_id, created_at, updated_at )

 */
-- (1) Crear nueva tabla con los atributos extraídos
CREATE TABLE IF NOT EXISTS USER_METADATA (
    user_id VARCHAR(100),
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT user_metadata_pk PRIMARY KEY (user_id)
);

-- (2) Copiar datos a la nueva tabla
INSERT INTO USER_METADATA (user_id, created_at, updated_at)
SELECT user_id, created_at, updated_at FROM USER;	

/* ADD AGGR User::profile: { nameProfile: String, avatar_url: String, description: String, website: String
}&

 */
CREATE TABLE IF NOT EXISTS USER_PROFILE
(
	user_id VARCHAR(100),
	nameprofile VARCHAR(100),
	avatar_url VARCHAR(100),
	description VARCHAR(100),
	website VARCHAR(100),
	CONSTRAINT profile_pk PRIMARY KEY(user_id),
	CONSTRAINT user_profile_fk FOREIGN KEY(user_id) REFERENCES USER(user_id) 
);

/* ADD RELATIONSHIP Followers

 */
-- YOU NEED ADD AT LEAST ONE REFERENCE TO GENERATE THE TABLE

/* ADD ENTITY Post: {
	+post_id: String, caption: String, description: String, created_at: Timestamp, updated_at: Timestamp }
 */
CREATE TABLE IF NOT EXISTS POST
(
	caption VARCHAR(100),
	created_at TIMESTAMP,
	description VARCHAR(100),
	post_id VARCHAR(100),
	updated_at TIMESTAMP,
	CONSTRAINT post_pk PRIMARY KEY (post_id)  
);

/* ADD ENTITY VideoPost: {
	+videopost_id: String, videoUrl: String, duration: double
}
 */
CREATE TABLE IF NOT EXISTS VIDEOPOST
(
	duration DOUBLE,
	videourl VARCHAR(100),
	videopost_id VARCHAR(100),
	CONSTRAINT videopost_pk PRIMARY KEY (videopost_id)  
);

/* ADD ENTITY PhotoPost: {
	+photopost_id: String, photoUrl: String
}
 */
CREATE TABLE IF NOT EXISTS PHOTOPOST
(
	photourl VARCHAR(100),
	photopost_id VARCHAR(100),
	CONSTRAINT photopost_pk PRIMARY KEY (photopost_id)  
);

/* ADD ENTITY LivePost: {
	+realpost_id: String,
	+duration : Timestamp }
 */
CREATE TABLE IF NOT EXISTS LIVEPOST
(
	duration TIMESTAMP,
	realpost_id VARCHAR(100),
	CONSTRAINT livepost_pk PRIMARY KEY (realpost_id, duration)  
);

/* ADD ENTITY Comment: {
	+comment_id: String, text: String, created_at: Timestamp, updated_at: Timestamp }

 */
CREATE TABLE IF NOT EXISTS COMMENT
(
	comment_id VARCHAR(100),
	created_at TIMESTAMP,
	text VARCHAR(100),
	updated_at TIMESTAMP,
	CONSTRAINT comment_pk PRIMARY KEY (comment_id)  
);

/* ADD REF Post::user_id : String& TO User
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE POST 
ADD COLUMN user_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE POST
ADD CONSTRAINT post_user_id_fk FOREIGN KEY (user_id)
REFERENCES USER(user_id);


/* ADD REF VideoPost::post_id : String& TO Post
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE VIDEOPOST 
ADD COLUMN post_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE VIDEOPOST
ADD CONSTRAINT videopost_post_id_fk FOREIGN KEY (post_id)
REFERENCES POST(post_id);


/* ADD REF PhotoPost::post_id : String& TO Post
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE PHOTOPOST 
ADD COLUMN post_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE PHOTOPOST
ADD CONSTRAINT photopost_post_id_fk FOREIGN KEY (post_id)
REFERENCES POST(post_id);


/* ADD REF Comment::user_id : String& TO User
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE COMMENT 
ADD COLUMN user_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE COMMENT
ADD CONSTRAINT comment_user_id_fk FOREIGN KEY (user_id)
REFERENCES USER(user_id);


/* ADD REF Comment::replyTo : String& TO Comment
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE COMMENT 
ADD COLUMN replyto VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE COMMENT
ADD CONSTRAINT comment_replyto_fk FOREIGN KEY (replyTo)
REFERENCES COMMENT(comment_id);


/* ADD REF Comment::post_id : String& TO Post
 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE COMMENT 
ADD COLUMN post_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE COMMENT
ADD CONSTRAINT comment_post_id_fk FOREIGN KEY (post_id)
REFERENCES POST(post_id);


/* ADD REF Followers::follower_id : String& TO User
 */
   CREATE TABLE IF NOT EXISTS FOLLOWERS (
   follower_id VARCHAR(100),
   	CONSTRAINT follower_id_pk PRIMARY KEY (follower_id),
   	CONSTRAINT followers_follower_id_fk FOREIGN KEY (follower_id) REFERENCES USER(user_id)
   );

/* ADD REF Followers::following_id : String& TO User

 */
-- (1) Multiplicity ? o &: Add reference column at actual table
ALTER TABLE FOLLOWERS 
ADD COLUMN following_id VARCHAR(100);

-- (2) Add foreign key
ALTER TABLE FOLLOWERS
ADD CONSTRAINT followers_following_id_fk FOREIGN KEY (following_id)
REFERENCES USER(user_id);

CALL dropFKsInTable("FOLLOWERS");
ALTER TABLE FOLLOWERS DROP PRIMARY KEY;


ALTER TABLE FOLLOWERS ADD PRIMARY KEY (follower_id, following_id);

ALTER TABLE FOLLOWERS 
ADD CONSTRAINT followers_following_id_fk FOREIGN KEY (following_id) 
REFERENCES USER (user_id);

ALTER TABLE FOLLOWERS 
ADD CONSTRAINT followers_follower_id_fk FOREIGN KEY (follower_id) 
REFERENCES USER (user_id);

/* CAST ATTR VideoPost::duration TO int

 */
ALTER TABLE VIDEOPOST MODIFY COLUMN duration INTEGER;

/* RENAME VideoPost::duration TO seconds

 */
ALTER TABLE VIDEOPOST RENAME COLUMN duration TO seconds;

/* ADD ATTR User::birthday : Timestamp
 */
ALTER TABLE USER ADD COLUMN birthday TIMESTAMP;

/* ADD ATTR VideoPost::lastMinute : Timestamp
 */
ALTER TABLE VIDEOPOST ADD COLUMN lastminute TIMESTAMP;

/* ADD ATTR Comment::hastag : List<String>
 */
ALTER TABLE COMMENT ADD COLUMN hastag JSON;

/* ADD ATTR Post::revision : int

 */
ALTER TABLE POST ADD COLUMN revision INTEGER;

/* PROMOTE ATTR Post::revision

 */
CREATE TABLE IF NOT EXISTS POST_NEW
(
	caption VARCHAR(100),
	created_at TIMESTAMP,
	description VARCHAR(100),
	post_id VARCHAR(100),
	revision INTEGER,
	updated_at TIMESTAMP,
	user_id VARCHAR(100),
	CONSTRAINT user_id_fk FOREIGN KEY(user_id) REFERENCES USER(user_id),
	CONSTRAINT post_new_pk PRIMARY KEY (post_id, revision)  
);
INSERT INTO POST_NEW SELECT * FROM POST;
CALL update_fk_schema("POST", "post_id", "revision");
CALL update_fk_data("POST", "post_id", "revision");
DROP TABLE POST;
ALTER TABLE POST_NEW RENAME TO POST;

/* RENAME ENTITY User TO UserUmugram

 */
RENAME TABLE USER_PROFILE TO USERUMUGRAM_PROFILE;
RENAME TABLE USER TO USERUMUGRAM;

/* DELETE ENTITY LivePost
 */
CALL dropWeakEntities("LIVEPOST");
CALL dropFKsFromTable("LIVEPOST");
DROP TABLE IF EXISTS LIVEPOST;

-- Delete helper procedures
DROP PROCEDURE IF EXISTS dropWeakEntities;
DROP PROCEDURE IF EXISTS dropFKsFromTable;
DROP PROCEDURE IF EXISTS dropFKsInTable;
DROP PROCEDURE IF EXISTS executeCommand;
DROP PROCEDURE IF EXISTS dropConstraintsForColumn;
DROP PROCEDURE IF EXISTS dropCheckConstraintsForColumn;
DROP PROCEDURE IF EXISTS update_fk_schema;
DROP PROCEDURE IF EXISTS update_fk_data;
DROP PROCEDURE IF EXISTS castColumnFKs;
