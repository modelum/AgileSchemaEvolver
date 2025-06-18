
package es.um.uschema.xtext.orion.main

import es.um.uschema.xtext.orion.m2t.Orion2Neo4j
import es.um.uschema.xtext.orion.utils.config.Orion2Neo4jConfig
import es.um.uschema.xtext.athena.utils.io.CodeWriter
import es.um.uschema.xtext.athena.utils.io.AthenaIO
import es.um.uschema.xtext.orion.utils.io.OrionIO

class Orion2Neo4jMain
{
  def static void main(String[] args)
  {
    val customArgs = newArrayList("-i", "models/neo4j/prueba.orion", "-o", "models/neo4j/prueba")

    val config = new Orion2Neo4jConfig(customArgs)

    runOrion2Neo4j(config)
  }

  private static def void runOrion2Neo4j(Orion2Neo4jConfig config)
  {
    val inputModel = config.inputModel
    val inputPath = config.inputPath
    val outputPath = config.outputPath

    val orionIO = new OrionIO()
    val transformer = new Orion2Neo4j()
    val athenaIO = new AthenaIO()
    val codeWriter = new CodeWriter()

    println("ORION> Generating Neo4j code...")

    outputPath.toFile.mkdirs

    val iterateModels = inputModel === null ? inputPath.toFile.listFiles[f | f.name.endsWith(".orion")].toSet : #{ inputModel.toFile }

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
          codeWriter.write(scripts.get(index), outputPath.resolve(schemas.get(index).id.name + ( schemas.length > 1 ? "_" + schemas.get(index).id.version : "" ) + ".cypher"))
        }
      } catch (IllegalArgumentException e)
      {e.printStackTrace()
        System.err.println("ORION>> Generation error for: " + model.name + " - " + e.message)
      }
    }

    println("ORION> Neo4j generation finished!")
  }
}
