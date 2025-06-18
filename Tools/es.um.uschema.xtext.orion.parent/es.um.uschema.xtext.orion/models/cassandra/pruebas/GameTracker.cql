CREATE KEYSPACE IF NOT EXISTS gametracker WITH REPLICATION = { 'class': 'SimpleStrategy', 'replication_factor' : 3 } ;
USE gametracker ;

// ADD RELATIONSHIP RelationshipAdded1: { tiempo: Timestamp }

-- Operation not supported.

// ADD REF RelationshipAdded1::ref1: String? TO Player
ALTER TABLE relationshipadded1 ADD ref1 text;

// ADD REF RelationshipAdded1::ref2: String? TO Game

ALTER TABLE relationshipadded1 ADD ref2 text;

// RENAME RELATIONSHIP RelationshipAdded1 TO RelationshipRenamed

-- Operation not supported.

// DELETE RELATIONSHIP RelationshipRenamed
-- Operation not supported.
