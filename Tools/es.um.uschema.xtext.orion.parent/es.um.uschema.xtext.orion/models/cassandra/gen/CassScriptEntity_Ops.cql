CREATE KEYSPACE IF NOT EXISTS CassScriptEntity_Ops WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE CassScriptEntity_Ops ;

// ADD ENTITY EntityAdded1: { +id: Identifier }
CREATE TABLE IF NOT EXISTS EntityAdded1
(
  id uuid,
  PRIMARY KEY (id)
);

// ADD ENTITY EntityAdded2: { +id: Identifier }
CREATE TABLE IF NOT EXISTS EntityAdded2
(
  id uuid,
  PRIMARY KEY (id)
);

// ADD ENTITY EntityAdded3: { +id: Identifier }

CREATE TABLE IF NOT EXISTS EntityAdded3
(
  id uuid,
  PRIMARY KEY (id)
);

// DELETE ENTITY EntityAdded2

DROP TABLE IF EXISTS EntityAdded2;

// RENAME ENTITY EntityAdded3 TO EntityRenamed

COPY EntityAdded3 TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityAdded3;
CREATE TABLE EntityRenamed
(
  id uuid,
  PRIMARY KEY (id)
);
COPY EntityRenamed FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToExtract: { +id: String ( "id" ), feat1: String ( "feat1" ), feat2: String ( "feat2" ), feat3: String ( "feat3" ), feat4: String ( "feat4" ) }

CREATE TABLE IF NOT EXISTS EntityToExtract
(
  id text,
  feat1 text,
  feat2 text,
  feat3 text,
  feat4 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToExtract (id, feat1, feat2, feat3, feat4) VALUES ('id', 'feat1', 'feat2', 'feat3', 'feat4');

// EXTRACT ENTITY EntityToExtract INTO EntityExtracted ( id, feat2, feat4 )

COPY EntityToExtract ( id, feat2, feat4 ) TO 'tmp.csv' WITH HEADER = TRUE;
CREATE TABLE EntityExtracted
(
  id text,
  feat2 text,
  feat4 text,
  PRIMARY KEY (id)
);
COPY EntityExtracted FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToSplit: { +id: String ( "id" ), attr1: String ( "attr1" ), attr2: String ( "attr2" ), attr3: String ( "attr3" ), attr4: String ( "attr4" ), attr5: String ( "attr5" ), attr6: String ( "attr6" ) }

CREATE TABLE IF NOT EXISTS EntityToSplit
(
  id text,
  attr1 text,
  attr2 text,
  attr3 text,
  attr4 text,
  attr5 text,
  attr6 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToSplit (id, attr1, attr2, attr3, attr4, attr5, attr6) VALUES ('id', 'attr1', 'attr2', 'attr3', 'attr4', 'attr5', 'attr6');

// SPLIT ENTITY EntityToSplit INTO EntitySplit1 ( id, attr1, attr2, attr3 ), EntitySplit2 ( id, attr1, attr5, attr6 )

COPY EntityToSplit ( id, attr1, attr2, attr3 ) TO 'tmp.csv' WITH HEADER = TRUE;
CREATE TABLE EntitySplit1
(
  id text,
  attr1 text,
  attr2 text,
  attr3 text,
  PRIMARY KEY (id)
);
COPY EntitySplit1 FROM 'tmp.csv' WITH HEADER = TRUE;
COPY EntityToSplit ( id, attr1, attr5, attr6 )  TO 'tmp.csv' WITH HEADER = TRUE;
CREATE TABLE EntitySplit2
(
  id text,
  attr1 text,
  attr5 text,
  attr6 text,
  PRIMARY KEY (id)
);
COPY EntitySplit2 FROM 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToSplit;

// ADD ENTITY EntityToMerge1: { +id: String ( "id" ), a: String ( "a" ), b: Number ( 33 ) }
CREATE TABLE IF NOT EXISTS EntityToMerge1
(
  id text,
  a text,
  b varint,
  PRIMARY KEY (id)
);
INSERT INTO EntityToMerge1 (id, a, b) VALUES ('id', 'a', 33);

// ADD ENTITY EntityToMerge2: { +id: String ( "id" ), c: List<String>, b: String ( "b" ) }

CREATE TABLE IF NOT EXISTS EntityToMerge2
(
  id text,
  c list<text>,
  b text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToMerge2 (id, b) VALUES ('id', 'b');

// MERGE ENTITY EntityToMerge1, EntityToMerge2 INTO EntityMerged WHERE EntityToMerge1.id = EntityToMerge2.id
CREATE TABLE EntityMerged
(
  id text,
  a text,
  b varint,
  c list<text>,
  PRIMARY KEY (id)
);
COPY EntityToMerge2 TO 'tmp.csv' WITH HEADER = TRUE;
COPY EntityMerged ( id, c, b ) FROM 'tmp.csv' WITH HEADER = TRUE;
COPY EntityToMerge1 TO 'tmp.csv' WITH HEADER = TRUE;
COPY EntityMerged ( id, a, b ) FROM 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToMerge2;
DROP TABLE EntityToMerge1;
