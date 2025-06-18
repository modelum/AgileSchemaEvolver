package es.um.uschema.xtext.orion.main

import es.um.uschema.xtext.orion.m2m.Athena2Orion
import es.um.uschema.xtext.orion.utils.config.Athena2OrionConfig
import es.um.uschema.xtext.athena.utils.io.AthenaIO
import es.um.uschema.xtext.orion.utils.io.OrionIO

class Athena2OrionMain
{
  def static void main(String[] args)
  {
    // val customArgs = newArrayList("-f", "../../es.um.uschema.xtext.athena.parent/es.um.uschema.xtext.athena/models/uschema2athena/", "-o", "models/")

    val config = new Athena2OrionConfig(args)

    runAthena2Orion(config)
  }

  private static def void runAthena2Orion(Athena2OrionConfig config)
  {
    val inputModel = config.inputModel
    val inputPath = config.inputPath
    val outputPath = config.outputPath

    val athenaIO = new AthenaIO()
    val transformer = new Athena2Orion()
    val orionIO = new OrionIO()

    println("ORION> Generating Orion operations...")

    outputPath.toFile.mkdirs

    val iterateModels = inputModel === null ? inputPath.toFile.listFiles[f | f.name.endsWith(".athena")].toSet : #{ inputModel.toFile }

    for (model : iterateModels)
    {
      println("ORION>> Model: " + model.name)
      val operations = transformer.m2m(athenaIO.load(model.toPath))
      orionIO.write(operations, outputPath.resolve(operations.name + ".orion"))
    }

    println("ORION> Orion generation finished!")
  }
}
