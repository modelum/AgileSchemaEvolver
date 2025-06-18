CREATE KEYSPACE IF NOT EXISTS CassScriptReference_Ops WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE CassScriptReference_Ops ;

// ADD ENTITY EntityDummy: { +id: String }
CREATE TABLE IF NOT EXISTS EntityDummy
(
  id text,
  PRIMARY KEY (id)
);

// ADD ENTITY EntityRefs: { +id: Identifier }

CREATE TABLE IF NOT EXISTS EntityRefs
(
  id uuid,
  PRIMARY KEY (id)
);

// ADD REF EntityRefs::nullRefSimple: String& TO EntityDummy
ALTER TABLE EntityRefs ADD nullRefSimple text;

// ADD REF EntityRefs::nullRefArray: String+ TO EntityDummy
ALTER TABLE EntityRefs ADD nullRefArray list<text>;

// ADD REF EntityRefs::strRefSimple: String& TO EntityDummy
ALTER TABLE EntityRefs ADD strRefSimple text;

// ADD REF EntityRefs::strRefArray: String+ TO EntityDummy
ALTER TABLE EntityRefs ADD strRefArray list<text>;

// ADD REF EntityRefs::numRefSimple: Number& TO EntityDummy
ALTER TABLE EntityRefs ADD numRefSimple varint;

// ADD REF EntityRefs::numRefArray: Number+ TO EntityDummy
ALTER TABLE EntityRefs ADD numRefArray list<varint>;

// ADD REF EntityRefs::nullRefSimpleChange: String& TO EntityDummy
ALTER TABLE EntityRefs ADD nullRefSimpleChange text;

// ADD REF EntityRefs::nullRefArrayChange: String+ TO EntityDummy
ALTER TABLE EntityRefs ADD nullRefArrayChange list<text>;

// ADD REF EntityRefs::strRefSimpleChange: String& TO EntityDummy
ALTER TABLE EntityRefs ADD strRefSimpleChange text;

// ADD REF EntityRefs::strRefArrayChange: String+ TO EntityDummy
ALTER TABLE EntityRefs ADD strRefArrayChange list<text>;

// ADD REF EntityRefs::numRefSimpleChange: Number& TO EntityDummy
ALTER TABLE EntityRefs ADD numRefSimpleChange varint;

// ADD REF EntityRefs::numRefArrayChange: Number+ TO EntityDummy

ALTER TABLE EntityRefs ADD numRefArrayChange list<varint>;

// MULT REF EntityRefs::nullRefSimpleChange, strRefSimpleChange, numRefSimpleChange TO +
COPY EntityRefs TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityRefs;
CREATE TABLE EntityRefs
(
  id uuid,
  nullRefSimple text,
  nullRefArray list<text>,
  strRefSimple text,
  strRefArray list<text>,
  numRefSimple varint,
  numRefArray list<varint>,
  nullRefArrayChange list<text>,
  strRefArrayChange list<text>,
  numRefArrayChange list<varint>,
  nullRefSimpleChange list<text>,, 
  strRefSimpleChange list<text>,, 
  numRefSimpleChange list<varint>,
  PRIMARY KEY (id)
);
COPY EntityRefs FROM 'tmp.csv' WITH HEADER = TRUE;

// MULT REF EntityRefs::nullRefArrayChange, strRefArrayChange, numRefArrayChange TO &

COPY EntityRefs TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityRefs;
CREATE TABLE EntityRefs
(
  id uuid,
  nullRefSimple text,
  nullRefArray list<text>,
  strRefSimple text,
  strRefArray list<text>,
  numRefSimple varint,
  numRefArray list<varint>,
  nullRefSimpleChange list<text>,
  strRefSimpleChange list<text>,
  numRefSimpleChange list<varint>,
  nullRefArrayChange text,, 
  strRefArrayChange text,, 
  numRefArrayChange varint,
  PRIMARY KEY (id)
);
COPY EntityRefs FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityRef1: { +id: String ( "refId1" ), value1: String ( "value1" ), value2: String ( "value2" ) }
CREATE TABLE IF NOT EXISTS EntityRef1
(
  id text,
  value1 text,
  value2 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityRef1 (id, value1, value2) VALUES ('refId1', 'value1', 'value2');

// ADD ENTITY EntityRef2: { +id: String ( "refId2" ), value3: String ( "value3" ), value4: String ( "value4" ) }
CREATE TABLE IF NOT EXISTS EntityRef2
(
  id text,
  value3 text,
  value4 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityRef2 (id, value3, value4) VALUES ('refId2', 'value3', 'value4');

// ADD ENTITY EntityRef3: { +id: String ( "refId3" ), value5: String ( "value6" ), value6: String ( "value6" ) }
CREATE TABLE IF NOT EXISTS EntityRef3
(
  id text,
  value5 text,
  value6 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityRef3 (id, value5, value6) VALUES ('refId3', 'value6', 'value6');

// ADD ENTITY EntityRef4: { +id: String ( "refId4" ), value7: String ( "value7" ), value8: String ( "value8" ) }
CREATE TABLE IF NOT EXISTS EntityRef4
(
  id text,
  value7 text,
  value8 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityRef4 (id, value7, value8) VALUES ('refId4', 'value7', 'value8');

// ADD ENTITY EntityMorphRef: { +id: String }

CREATE TABLE IF NOT EXISTS EntityMorphRef
(
  id text,
  PRIMARY KEY (id)
);

// ADD REF EntityMorphRef::refToEntity1: String ("refId1")& TO EntityRef1
ALTER TABLE EntityMorphRef ADD refToEntity1 text;

// ADD REF EntityMorphRef::refToEntity2: String ("refId2")& TO EntityRef2
ALTER TABLE EntityMorphRef ADD refToEntity2 text;

// ADD REF EntityMorphRef::refToEntity3: String ("refId3")+ TO EntityRef3
ALTER TABLE EntityMorphRef ADD refToEntity3 list<text>;

// ADD REF EntityMorphRef::refToEntity4: String ("refId4")+ TO EntityRef4

ALTER TABLE EntityMorphRef ADD refToEntity4 list<text>;

// MORPH REF EntityMorphRef::refToEntity1 TO aggrEntity1
CREATE TYPE IF NOT EXISTS RefToEntity1
(
  id text,
  value1 text,
  value2 text,
);
ALTER TABLE EntityMorphRef ADD aggrEntity1 RefToEntity1;

// MORPH REF EntityMorphRef::refToEntity2 ( rmEntity ) TO aggrEntity2
CREATE TYPE IF NOT EXISTS RefToEntity2
(
  id text,
  value3 text,
  value4 text,
);
ALTER TABLE EntityMorphRef ADD aggrEntity2 RefToEntity2;
DROP TABLE IF EXISTS EntityRef2;

// MORPH REF EntityMorphRef::refToEntity3 TO aggrEntity3
CREATE TYPE IF NOT EXISTS RefToEntity3
(
  id text,
  value5 text,
  value6 text,
);
ALTER TABLE EntityMorphRef ADD aggrEntity3 list<frozen<RefToEntity3>>;

// MORPH REF EntityMorphRef::refToEntity4 ( rmEntity ) TO aggrEntity4
CREATE TYPE IF NOT EXISTS RefToEntity4
(
  id text,
  value7 text,
  value8 text,
);
ALTER TABLE EntityMorphRef ADD aggrEntity4 list<frozen<RefToEntity4>>;
DROP TABLE IF EXISTS EntityRef4;
