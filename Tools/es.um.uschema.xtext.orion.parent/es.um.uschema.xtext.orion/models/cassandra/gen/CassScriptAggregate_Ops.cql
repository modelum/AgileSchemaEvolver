CREATE KEYSPACE IF NOT EXISTS CassScriptAggregate_Ops WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE CassScriptAggregate_Ops ;

// ADD ENTITY EntityToAggr: { +id: Identifier }

CREATE TABLE IF NOT EXISTS EntityToAggr
(
  id uuid,
  PRIMARY KEY (id)
);

// ADD AGGR EntityToAggr::aggrSimple : { attr1: String, attr2: Number, attr3: Map<String, Integer>, attr4: List<Integer> }&
CREATE TYPE IF NOT EXISTS AggrSimple
(
  attr1 text, 
  attr2 varint, 
  attr3 frozen<map<text, int>>, 
  attr4 frozen<list<int>>
);
ALTER TABLE EntityToAggr ADD aggrSimple AggrSimple;

// ADD AGGR EntityToAggr::aggrList : { attr1: String, attr2: Number, attr3: Map<String, Integer>, attr4: List<Integer> }+
CREATE TYPE IF NOT EXISTS AggrList
(
  attr1 text, 
  attr2 varint, 
  attr3 frozen<map<text, int>>, 
  attr4 frozen<list<int>>
);
ALTER TABLE EntityToAggr ADD aggrList list<frozen<AggrList>>;

// ADD AGGR EntityToAggr::aggrSimple.innerAggrSimple: { innerAttr1: String, innerAttr2: Number, innerAttr3: Map<String, Boolean>, innerAttr4: List<String> }&
CREATE TYPE IF NOT EXISTS InnerAggrSimple
(
  innerAttr1 text, 
  innerAttr2 varint, 
  innerAttr3 frozen<map<text, boolean>>, 
  innerAttr4 frozen<list<text>>
);
ALTER TYPE AggrSimple ADD innerAggrSimple frozen<InnerAggrSimple>;

// ADD AGGR EntityToAggr::aggrSimple.innerAggrList: { innerAttr1: String, innerAttr2: Number, innerAttr3: Map<String, String>, innerAttr4: List<String> }+
CREATE TYPE IF NOT EXISTS InnerAggrList
(
  innerAttr1 text, 
  innerAttr2 varint, 
  innerAttr3 frozen<map<text, text>>, 
  innerAttr4 frozen<list<text>>
);
ALTER TYPE AggrSimple ADD innerAggrList frozen<list<InnerAggrList>>;

// ADD AGGR EntityToAggr::strAggrSimpleChange: { attr1: String, attr2: Integer }&
CREATE TYPE IF NOT EXISTS StrAggrSimpleChange
(
  attr1 text, 
  attr2 int
);
ALTER TABLE EntityToAggr ADD strAggrSimpleChange StrAggrSimpleChange;

// ADD AGGR EntityToAggr::strAggrArrayChange: { attr1: String, attr2: Integer }+
CREATE TYPE IF NOT EXISTS StrAggrArrayChange
(
  attr1 text, 
  attr2 int
);
ALTER TABLE EntityToAggr ADD strAggrArrayChange list<frozen<StrAggrArrayChange>>;

// ADD AGGR EntityToAggr::numAggrSimpleChange: { attr1: Number, attr2: Integer }&
CREATE TYPE IF NOT EXISTS NumAggrSimpleChange
(
  attr1 varint, 
  attr2 int
);
ALTER TABLE EntityToAggr ADD numAggrSimpleChange NumAggrSimpleChange;

// ADD AGGR EntityToAggr::numAggrArrayChange: { attr1: Number, attr2: Integer }+

CREATE TYPE IF NOT EXISTS NumAggrArrayChange
(
  attr1 varint, 
  attr2 int
);
ALTER TABLE EntityToAggr ADD numAggrArrayChange list<frozen<NumAggrArrayChange>>;

// MULT AGGR EntityToAggr::strAggrSimpleChange, numAggrSimpleChange TO +
COPY EntityToAggr TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToAggr;
CREATE TABLE EntityToAggr
(
  id uuid,
  aggrSimple AggrSimple,
  aggrList list<frozen<AggrList>>,
  strAggrArrayChange list<frozen<StrAggrArrayChange>>,
  numAggrArrayChange list<frozen<NumAggrArrayChange>>,
  strAggrSimpleChange list<frozen<StrAggrSimpleChange>>,, 
  numAggrSimpleChange list<frozen<NumAggrSimpleChange>>,
  PRIMARY KEY (id)
);
COPY EntityToAggr FROM 'tmp.csv' WITH HEADER = TRUE;

// MULT AGGR EntityToAggr::strAggrArrayChange, numAggrArrayChange TO &

COPY EntityToAggr TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToAggr;
CREATE TABLE EntityToAggr
(
  id uuid,
  aggrSimple AggrSimple,
  aggrList list<frozen<AggrList>>,
  strAggrSimpleChange list<frozen<StrAggrSimpleChange>>,
  numAggrSimpleChange list<frozen<NumAggrSimpleChange>>,
  strAggrArrayChange StrAggrArrayChange,, 
  numAggrArrayChange NumAggrArrayChange,
  PRIMARY KEY (id)
);
COPY EntityToAggr FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD AGGR EntityToAggr::aggrByHand1: { string1: String }&

CREATE TYPE IF NOT EXISTS AggrByHand1
(
  string1 text
);
ALTER TABLE EntityToAggr ADD aggrByHand1 AggrByHand1;

// ADD ATTR EntityToAggr::aggrByHand1.nullAttrArrayChange: List<Integer>
ALTER TYPE AggrByHand1 ADD nullAttrArrayChange frozen<list<int>>;

// ADD ATTR EntityToAggr::aggrByHand1.strAttrSimpleChange: String
ALTER TYPE AggrByHand1 ADD strAttrSimpleChange text;

// ADD ATTR EntityToAggr::aggrByHand1.strAttrArrayChange: List<String>

ALTER TYPE AggrByHand1 ADD strAttrArrayChange frozen<list<text>>;

// ADD AGGR EntityToAggr::aggrByHand2: { string2: String }&

CREATE TYPE IF NOT EXISTS AggrByHand2
(
  string2 text
);
ALTER TABLE EntityToAggr ADD aggrByHand2 AggrByHand2;

// ADD ATTR EntityToAggr::aggrByHand2.numAttrSimpleChange: Number
ALTER TYPE AggrByHand2 ADD numAttrSimpleChange varint;

// ADD ATTR EntityToAggr::aggrByHand2.numAttrArrayChange: List<Number>

ALTER TYPE AggrByHand2 ADD numAttrArrayChange frozen<list<varint>>;

// MULT AGGR EntityToAggr::aggrByHand1 TO +

COPY EntityToAggr TO 'tmp.csv' WITH HEADER = TRUE;
DROP TABLE EntityToAggr;
CREATE TABLE EntityToAggr
(
  id uuid,
  aggrSimple AggrSimple,
  aggrList list<frozen<AggrList>>,
  strAggrSimpleChange list<frozen<StrAggrSimpleChange>>,
  strAggrArrayChange StrAggrArrayChange,
  numAggrSimpleChange list<frozen<NumAggrSimpleChange>>,
  numAggrArrayChange NumAggrArrayChange,
  aggrByHand2 AggrByHand2,
  aggrByHand1 list<frozen<AggrByHand1>>,
  PRIMARY KEY (id)
);
COPY EntityToAggr FROM 'tmp.csv' WITH HEADER = TRUE;

// ADD ENTITY EntityMorphAggr: { +id: String }

CREATE TABLE IF NOT EXISTS EntityMorphAggr
(
  id text,
  PRIMARY KEY (id)
);

// ADD AGGR EntityMorphAggr::aggr1: { string1: String, string2: String }&
CREATE TYPE IF NOT EXISTS Aggr1
(
  string1 text, 
  string2 text
);
ALTER TABLE EntityMorphAggr ADD aggr1 Aggr1;

// ADD AGGR EntityMorphAggr::aggr2: { aList: List<Integer>, aMap: Map<String, Integer> }&
CREATE TYPE IF NOT EXISTS Aggr2
(
  aList frozen<list<int>>, 
  aMap frozen<map<text, int>>
);
ALTER TABLE EntityMorphAggr ADD aggr2 Aggr2;

// ADD AGGR EntityMorphAggr::aggr3: { string5: String, string6: String }+
CREATE TYPE IF NOT EXISTS Aggr3
(
  string5 text, 
  string6 text
);
ALTER TABLE EntityMorphAggr ADD aggr3 list<frozen<Aggr3>>;

// ADD AGGR EntityMorphAggr::aggr4: { aSet: Set<Integer>, aTuple: Tuple<String> }+

CREATE TYPE IF NOT EXISTS Aggr4
(
  aSet frozen<set<int>>, 
  aTuple frozen<tuple<text>>
);
ALTER TABLE EntityMorphAggr ADD aggr4 list<frozen<Aggr4>>;

// MORPH AGGR EntityMorphAggr::aggr1 TO refToAggr1
CREATE TABLE IF NOT EXISTS Aggr1
(
  id uuid,
  string1 text,
  string2 text,
  PRIMARY KEY (id)
);
ALTER TABLE EntityMorphAggr ADD refToAggr1 uuid;

// MORPH AGGR EntityMorphAggr::aggr2 TO refToAggr2
CREATE TABLE IF NOT EXISTS Aggr2
(
  id uuid,
  aList list<int>,
  aMap map<text, int>,
  PRIMARY KEY (id)
);
ALTER TABLE EntityMorphAggr ADD refToAggr2 uuid;

// MORPH AGGR EntityMorphAggr::aggr3 TO refToAggr3
CREATE TABLE IF NOT EXISTS Aggr3
(
  id uuid,
  string5 text,
  string6 text,
  PRIMARY KEY (id)
);
ALTER TABLE EntityMorphAggr ADD refToAggr3 list<uuid>;

// MORPH AGGR EntityMorphAggr::aggr4 TO refToAggr4
CREATE TABLE IF NOT EXISTS Aggr4
(
  id uuid,
  aSet set<int>,
  aTuple tuple<text>,
  PRIMARY KEY (id)
);
ALTER TABLE EntityMorphAggr ADD refToAggr4 list<uuid>;
