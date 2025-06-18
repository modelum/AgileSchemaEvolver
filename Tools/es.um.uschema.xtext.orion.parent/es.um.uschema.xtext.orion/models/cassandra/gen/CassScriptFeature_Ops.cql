CREATE KEYSPACE IF NOT EXISTS CassScriptFeature_Ops WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE CassScriptFeature_Ops ;

// ADD ENTITY EntityToRemove: { +id: Identifier, attrToDel: String, attrToDelStr: String, attrToDelNum: Number, attrToDelDouble: Double, attrToDelBool: Boolean, attrToRen: List<String>, attrToRenStr: String, attrToRenNum: Number, attrToRenDouble: Double, attrToRenBool: Boolean }

CREATE TABLE IF NOT EXISTS EntityToRemove
(
  id uuid,
  attrToDel text,
  attrToDelStr text,
  attrToDelNum varint,
  attrToDelDouble double,
  attrToDelBool boolean,
  attrToRen list<text>,
  attrToRenStr text,
  attrToRenNum varint,
  attrToRenDouble double,
  attrToRenBool boolean,
  PRIMARY KEY (id)
);

// DELETE EntityToRemove::attrToDel, attrToDelStr, attrToDelNum, attrToDelDouble, attrToDelBool

ALTER TABLE EntityToRemove DROP ( attrToDel, attrToDelStr, attrToDelNum, attrToDelDouble, attrToDelBool );

// RENAME EntityToRemove::attrToRen TO attrTrue1
COPY EntityToRemove ( id, attrToRen ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToRemove DROP ( attrToRen );
ALTER TABLE EntityToRemove ADD attrTrue1 list<text>;
COPY EntityToRemove ( id, attrTrue1 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// RENAME EntityToRemove::attrToRenStr TO attrTrue2
COPY EntityToRemove ( id, attrToRenStr ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToRemove DROP ( attrToRenStr );
ALTER TABLE EntityToRemove ADD attrTrue2 text;
COPY EntityToRemove ( id, attrTrue2 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// RENAME EntityToRemove::attrToRenNum TO attrTrue3
COPY EntityToRemove ( id, attrToRenNum ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToRemove DROP ( attrToRenNum );
ALTER TABLE EntityToRemove ADD attrTrue3 varint;
COPY EntityToRemove ( id, attrTrue3 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// RENAME EntityToRemove::attrToRenDouble TO attrTrue4
COPY EntityToRemove ( id, attrToRenDouble ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToRemove DROP ( attrToRenDouble );
ALTER TABLE EntityToRemove ADD attrTrue4 double;
COPY EntityToRemove ( id, attrTrue4 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// RENAME EntityToRemove::attrToRenBool TO attrTrue5

COPY EntityToRemove ( id, attrToRenBool ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToRemove DROP ( attrToRenBool );
ALTER TABLE EntityToRemove ADD attrTrue5 boolean;
COPY EntityToRemove ( id, attrTrue5 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToCopySource1: { +id: String ( "id1" ), aRef: String ( "idRef" ), valueToCopy1: String ( "COPY_THIS" ), valueToCopy2: List<String>, valueToCopy3: Map<String, Boolean> }
CREATE TABLE IF NOT EXISTS EntityToCopySource1
(
  id text,
  aRef text,
  valueToCopy1 text,
  valueToCopy2 list<text>,
  valueToCopy3 map<text, boolean>,
  PRIMARY KEY (id)
);
INSERT INTO EntityToCopySource1 (id, aRef, valueToCopy1) VALUES ('id1', 'idRef', 'COPY_THIS');

// ADD ENTITY EntityToCopySource2: { +id: String ( "id2" ), aRef: String ( "idRef" ), valueToCopy4: String ( "COPY_THAT" ) }
CREATE TABLE IF NOT EXISTS EntityToCopySource2
(
  id text,
  aRef text,
  valueToCopy4 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToCopySource2 (id, aRef, valueToCopy4) VALUES ('id2', 'idRef', 'COPY_THAT');

// ADD ENTITY EntityToCopyTarget: { +id: String ( "idRef" ) }

CREATE TABLE IF NOT EXISTS EntityToCopyTarget
(
  id text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToCopyTarget (id) VALUES ('idRef');

// COPY EntityToCopySource1::valueToCopy1 TO EntityToCopyTarget::copy1 WHERE aRef = id
COPY EntityToCopySource1 ( aRef, valueToCopy1 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToCopyTarget ADD copy1 text;
COPY EntityToCopyTarget ( id, copy1 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// COPY EntityToCopySource1::valueToCopy2 TO EntityToCopyTarget::copy2 WHERE aRef = id
COPY EntityToCopySource1 ( aRef, valueToCopy2 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToCopyTarget ADD copy2 list<text>;
COPY EntityToCopyTarget ( id, copy2 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// COPY EntityToCopySource1::valueToCopy3 TO EntityToCopyTarget::copy3 WHERE aRef = id
COPY EntityToCopySource1 ( aRef, valueToCopy3 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToCopyTarget ADD copy3 map<text, boolean>;
COPY EntityToCopyTarget ( id, copy3 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// COPY EntityToCopySource2::valueToCopy4 TO EntityToCopyTarget::valueToCopy4 WHERE aRef = id

COPY EntityToCopySource2 ( aRef, valueToCopy4 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToCopyTarget ADD valueToCopy4 text;
COPY EntityToCopyTarget ( id, valueToCopy4 ) FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityToMoveSource1: { +id: String ( "id1" ), aRef: String ( "idRef" ), valueToMove1: String ( "MOVE_THIS" ), valueToMove2: List<String>, valueToMove3: Map<String, Boolean> }
CREATE TABLE IF NOT EXISTS EntityToMoveSource1
(
  id text,
  aRef text,
  valueToMove1 text,
  valueToMove2 list<text>,
  valueToMove3 map<text, boolean>,
  PRIMARY KEY (id)
);
INSERT INTO EntityToMoveSource1 (id, aRef, valueToMove1) VALUES ('id1', 'idRef', 'MOVE_THIS');

// ADD ENTITY EntityToMoveSource2: { +id: String ( "id2" ), aRef: String ( "idRef" ), valueToMove4: String ( "MOVE_THAT" ) }
CREATE TABLE IF NOT EXISTS EntityToMoveSource2
(
  id text,
  aRef text,
  valueToMove4 text,
  PRIMARY KEY (id)
);
INSERT INTO EntityToMoveSource2 (id, aRef, valueToMove4) VALUES ('id2', 'idRef', 'MOVE_THAT');

// ADD ENTITY EntityToMoveTarget: { +id: String }

CREATE TABLE IF NOT EXISTS EntityToMoveTarget
(
  id text,
  PRIMARY KEY (id)
);

// MOVE EntityToMoveSource1::valueToMove1 TO EntityToMoveTarget::move1 WHERE aRef = id
COPY EntityToMoveSource1 ( aRef, valueToMove1 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveTarget ADD move1 text;
COPY EntityToMoveTarget ( id, move1 ) FROM 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveSource1 DROP ( valueToMove1 );

// MOVE EntityToMoveSource1::valueToMove2 TO EntityToMoveTarget::move2 WHERE aRef = id
COPY EntityToMoveSource1 ( aRef, valueToMove2 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveTarget ADD move2 list<text>;
COPY EntityToMoveTarget ( id, move2 ) FROM 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveSource1 DROP ( valueToMove2 );

// MOVE EntityToMoveSource1::valueToMove3 TO EntityToMoveTarget::move3 WHERE aRef = id
COPY EntityToMoveSource1 ( aRef, valueToMove3 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveTarget ADD move3 map<text, boolean>;
COPY EntityToMoveTarget ( id, move3 ) FROM 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveSource1 DROP ( valueToMove3 );

// MOVE EntityToMoveSource2::valueToMove4 TO EntityToMoveTarget::move4 WHERE aRef = id

COPY EntityToMoveSource2 ( aRef, valueToMove4 ) TO 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveTarget ADD move4 text;
COPY EntityToMoveTarget ( id, move4 ) FROM 'tmp.csv' WITH HEADER = TRUE;
ALTER TABLE EntityToMoveSource2 DROP ( valueToMove4 );

// ADD ENTITY EntityToNest: { +id: String, name: String, age: Integer, street: String, postalCode: String, city: String, aList: List<String>, aMap: Map<String, Boolean> }

CREATE TABLE IF NOT EXISTS EntityToNest
(
  id text,
  name text,
  age int,
  street text,
  postalCode text,
  city text,
  aList list<text>,
  aMap map<text, boolean>,
  PRIMARY KEY (id)
);

// ADD AGGR EntityToNest::nestAggrNest1: { nest1: Double, nest2: String, nest3: Boolean }&
CREATE TYPE IF NOT EXISTS NestAggrNest1
(
  nest1 double, 
  nest2 text, 
  nest3 boolean
);
ALTER TABLE EntityToNest ADD nestAggrNest1 NestAggrNest1;

// ADD AGGR EntityToNest::nestAggrNest2: { nest4: Double, nest5: String, nest6: Boolean }+

CREATE TYPE IF NOT EXISTS NestAggrNest2
(
  nest4 double, 
  nest5 text, 
  nest6 boolean
);
ALTER TABLE EntityToNest ADD nestAggrNest2 list<frozen<NestAggrNest2>>;

// NEST EntityToNest::street, postalCode, city, nestAggrNest1, nestAggrNest2 TO nestedAggr

CREATE TYPE IF NOT EXISTS NestedAggr
(
  street text, 
  postalCode text, 
  city text, 
  nestAggrNest1 frozen<NestAggrNest1>, 
  nestAggrNest2 frozen<list<frozen<NestAggrNest2>>>
);
ALTER TABLE EntityToNest ADD nestedAggr NestedAggr;
ALTER TABLE EntityToNest DROP ( street, postalCode, city, nestAggrNest1, nestAggrNest2 );

// ADD ENTITY EntityToUnnest: { +id: String, name: String, age: Integer }

CREATE TABLE IF NOT EXISTS EntityToUnnest
(
  id text,
  name text,
  age int,
  PRIMARY KEY (id)
);

// ADD AGGR EntityToUnnest::unnestAggrNest1: { nest1: Double, nest2: String, nest3: Boolean, street: String, postalCode: String, city: String, aList: List<String>, aMap: Map<String, Boolean> }+
CREATE TYPE IF NOT EXISTS UnnestAggrNest1
(
  nest1 double, 
  nest2 text, 
  nest3 boolean, 
  street text, 
  postalCode text, 
  city text, 
  aList frozen<list<text>>, 
  aMap frozen<map<text, boolean>>
);
ALTER TABLE EntityToUnnest ADD unnestAggrNest1 list<frozen<UnnestAggrNest1>>;

// ADD AGGR EntityToUnnest::unnestAggrNest2: { nest4: Double, nest5: String, nest6: Boolean }&

CREATE TYPE IF NOT EXISTS UnnestAggrNest2
(
  nest4 double, 
  nest5 text, 
  nest6 boolean
);
ALTER TABLE EntityToUnnest ADD unnestAggrNest2 UnnestAggrNest2;

// UNNEST EntityToUnnest::unnestAggrNest1.street, unnestAggrNest1.postalCode, unnestAggrNest1.city, unnestAggrNest1.aList, unnestAggrNest1.aMap, unnestAggrNest2.nest4
ALTER TABLE EntityToUnnest ADD
(
  street text, 
  postalCode text, 
  city text, 
  aList list<text>, 
  aMap map<text, boolean>, 
  nest4 double
);
