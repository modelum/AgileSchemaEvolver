package es.um.uschema.xtext.orion.main

import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.athena.utils.io.AthenaIO
import es.um.uschema.xtext.athena.utils.io.CodeWriter
import es.um.uschema.xtext.orion.m2t.Orion2MySQL
import es.um.uschema.xtext.orion.utils.config.Orion2MySQLConfig
import es.um.uschema.xtext.orion.m2t.utils.SqlProcedureModule

class Orion2MySQLMain {
	def static void main(String[] args)
  {
    val customArgs = newArrayList("-i", "models/sql/Umugram.orion", "-o", "models/sql/code-generated")

    val config = new Orion2MySQLConfig(customArgs)

    runOrion2SQL(config)
  }

  private static def void runOrion2SQL(Orion2MySQLConfig config)
  {
    val inputModel = config.inputModel
    val inputPath = config.inputPath
    val outputPath = config.outputPath
	
	// Load orion models from files
    val orionIO = new OrionIO()
    // Logic to transform Orion to MySQL
    val transformer = new Orion2MySQL()
    // Write with Athena format
    val athenaIO = new AthenaIO()
    // Helper to write files
    val codeWriter = new CodeWriter()
    // Helper to generate MySQL procedures
    val sqlProcedureModule = new SqlProcedureModule()

    println("ORION> Generating Cassandra code...")

    outputPath.toFile.mkdirs

    val iterateModels = inputModel === null ? inputPath.toFile.listFiles[f | f.name.endsWith(".orion")].toSet : #{ inputModel.toFile }
	
	codeWriter.write(sqlProcedureModule.generateProcedures, outputPath.resolve("procedureSQL.sql"))
    for (model : iterateModels)
    {
      println("ORION>> Model: " + model.name)
      try
      {
        // These two lists do have the same number of elements
        val scripts = transformer.m2t(orionIO.load(model.toPath))
        val schemas = transformer.schemas

        for (index : 0..schemas.length - 1)
        {
          athenaIO.write(schemas.get(index), outputPath.resolve(schemas.get(index).id.name + ( schemas.length > 1 ? "_" + schemas.get(index).id.version : "" ) + ".athena"))
          codeWriter.write(scripts.get(index), outputPath.resolve(schemas.get(index).id.name + ( schemas.length > 1 ? "_" + schemas.get(index).id.version : "" ) + ".sql"))
        }
      } catch (IllegalArgumentException e)
      {
        System.err.println("ORION>> Generation error for: " + model.name + " - " + e.message)
      }
    }

    println("ORION> SQL generation finished!")
  }
}