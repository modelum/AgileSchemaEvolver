CREATE KEYSPACE IF NOT EXISTS CassScriptAttribute_Ops WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE CassScriptAttribute_Ops ;

// ADD ENTITY EntityToAdd: { +id: String }

CREATE TABLE IF NOT EXISTS EntityToAdd
(
  id text,
  PRIMARY KEY (id)
);

// ADD ATTR *::addAttrStr: String
ALTER TABLE EntityToAdd ADD addAttrStr text;

// ADD ATTR *::addAttrNum: Number
ALTER TABLE EntityToAdd ADD addAttrNum varint;

// ADD ATTR *::addAttrDouble: Double
ALTER TABLE EntityToAdd ADD addAttrDouble double;

// ADD ATTR *::addAttrBool: Boolean
ALTER TABLE EntityToAdd ADD addAttrBool boolean;

// ADD ATTR *::addAttrSet: Set<String>
ALTER TABLE EntityToAdd ADD addAttrSet set<text>;

// ADD ATTR *::addAttrList: List<String>
ALTER TABLE EntityToAdd ADD addAttrList list<text>;

// ADD ATTR *::addAttrTuple: Tuple<String, Integer>
ALTER TABLE EntityToAdd ADD addAttrTuple tuple<text,int>;

// ADD ATTR *::addAttrMap: Map<String, String>

ALTER TABLE EntityToAdd ADD addAttrMap map<text, text>;

// ADD ENTITY EntityToCast: { +id: Identifier, attrToCastStr: Boolean, attrToCastNum: String, attrToCastDouble: Number, attrToCastBool: Double }

CREATE TABLE IF NOT EXISTS EntityToCast
(
  id uuid,
  attrToCastStr boolean,
  attrToCastNum text,
  attrToCastDouble varint,
  attrToCastBool double,
  PRIMARY KEY (id)
);

// CAST ATTR EntityToCast::attrToCastBool TO Boolean
COPY EntityToCast TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToCast;
CREATE TABLE EntityToCast
(
  id uuid,
  attrToCastStr boolean,
  attrToCastNum text,
  attrToCastDouble varint,
  attrToCastBool boolean
  PRIMARY KEY (id)
);
COPY EntityToCast FROM 'tmp.csv' WITH HEADER = TRUE;

// CAST ATTR EntityToCast::attrToCastDouble TO Double
COPY EntityToCast TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToCast;
CREATE TABLE EntityToCast
(
  id uuid,
  attrToCastStr boolean,
  attrToCastNum text,
  attrToCastBool boolean,
  attrToCastDouble double
  PRIMARY KEY (id)
);
COPY EntityToCast FROM 'tmp.csv' WITH HEADER = TRUE;

// CAST ATTR EntityToCast::attrToCastNum TO Number
COPY EntityToCast TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToCast;
CREATE TABLE EntityToCast
(
  id uuid,
  attrToCastStr boolean,
  attrToCastDouble double,
  attrToCastBool boolean,
  attrToCastNum varint
  PRIMARY KEY (id)
);
COPY EntityToCast FROM 'tmp.csv' WITH HEADER = TRUE;

// CAST ATTR EntityToCast::attrToCastStr TO String

COPY EntityToCast TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToCast;
CREATE TABLE EntityToCast
(
  id uuid,
  attrToCastNum varint,
  attrToCastDouble double,
  attrToCastBool boolean,
  attrToCastStr text
  PRIMARY KEY (id)
);
COPY EntityToCast FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToPromote: { +id1: Identifier, id2: Double, id3: Number, id4: String }

CREATE TABLE IF NOT EXISTS EntityToPromote
(
  id1 uuid,
  id2 double,
  id3 varint,
  id4 text,
  PRIMARY KEY (id1)
);

// PROMOTE ATTR EntityToPromote::id2, id3, id4

COPY EntityToPromote TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToPromote;
CREATE TABLE EntityToPromote
(
  id1 uuid,
  id2 double,
  id3 varint,
  id4 text,
  PRIMARY KEY (id1, id2, id3, id4)
);
COPY EntityToPromote FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToDemote: { +id1: Identifier, +id2: Double, +id3: Number, +id4: String }

CREATE TABLE IF NOT EXISTS EntityToDemote
(
  id1 uuid,
  id2 double,
  id3 varint,
  id4 text,
  PRIMARY KEY (id1, id2, id3, id4)
);

// DEMOTE ATTR EntityToPromote::id2, id3, id4
COPY EntityToPromote TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToPromote;
CREATE TABLE EntityToPromote
(
  id1 uuid,
  id2 double,
  id3 varint,
  id4 text,
  PRIMARY KEY (id1)
);
COPY EntityToPromote FROM 'tmp.csv' WITH HEADER = TRUE;
