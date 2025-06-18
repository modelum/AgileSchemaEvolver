package es.um.uschema.xtext.athena.utils

class TypeConverter
{
  def String typeToCassandraType(String type)
  {
    switch (type.toLowerCase)
    {
      case "integer", case "int":  "int"
      case "number":               "varint"
      case "float":                "float"
      case "double":               "double"
      case "bool", case "boolean": "boolean"
      case "identifier":           "uuid"
      case "timestamp":            "timestamp"
      default:                     "text"
    }
  }

  def String typeToMongoDBType(String type)
  {
    switch (type.toLowerCase)
    {
      case "integer", case "int":  "int"
      case "number":               "number"
      case "float", case "double": "float"
      case "bool", case "boolean": "bool"
      case "identifier":           "objectId"
      case "timestamp":            "timestamp"
      default:                     "string"
    }
  }

  def Integer typeToNumericBSONType(String type)
  {
    switch (type.toLowerCase)
    {
      case "integer", case "int", case "number": 16 //Int
      case "float", case "double":                1 //Double
      case "bool", case "boolean":                8 //Boolean
      case "identifier":                          7 //ObjectId
      case "timestamp":                          17 //Timestamp
      default:                                    2 //String
    }
  }

  def String typeToMySQLType(String type)
  {
    switch (type.toLowerCase)
    {
      case "integer", case "int":  "INTEGER"
      case "number":               "NUMERIC"
      case "float":                "FLOAT"
      case "double":               "DOUBLE"
      case "bool", case "boolean": "BOOLEAN"
      case "identifier":           "VARCHAR(100)"
      case "timestamp":            "TIMESTAMP"
      default:                     "VARCHAR(100)"
    }
  }

  def String mySQLTypeToType(String type)
  {
    switch (type.toLowerCase)
    {
      case "tinyint", case "boolean", case "bool":                                            "Boolean"
      case "int", case "integer", case "smallint", case "mediumint":                          "Integer"
      case "dec", case "fixed", case "decimal", case "numeric", case "bit":                   "Number"
      case "float", case "real":                                                              "Float"
      case "double precision", case "double":                                                 "Double"
      case "date", case "time", case "datetime", case "timestamp", case "year":               "Timestamp"
      case "char", case "varchar", case "binary", case "varbinary", case "blob", case "text": "String"
      default: throw new IllegalArgumentException(type + " could not be converted to any Athena type")
    }
  }
}
