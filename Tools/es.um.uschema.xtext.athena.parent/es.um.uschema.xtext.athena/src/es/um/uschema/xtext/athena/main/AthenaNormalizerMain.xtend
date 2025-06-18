package es.um.uschema.xtext.athena.main

import es.um.uschema.xtext.athena.m2m.AthenaNormalizer
import es.um.uschema.xtext.athena.utils.config.AthenaNormalizerConfig
import es.um.uschema.xtext.athena.utils.io.AthenaIO

class AthenaNormalizerMain
{
  def static void main(String[] args)
  {
    // val customArgs = newArrayList("-i", "../../es.um.uschema.xtext.models/thesis/athena/SoftwareDev.athena", "-o", "../../es.um.uschema.xtext.models/thesis/athena/")

    val config = new AthenaNormalizerConfig(args)

    runAthenaNormalizer(config)
  }

  private static def runAthenaNormalizer(AthenaNormalizerConfig config)
  {
    val inputModel = config.inputModel
    val inputPath = config.inputPath
    val outputPath = config.outputPath

    val athenaIO = new AthenaIO()
    val normalizer = new AthenaNormalizer()

    println("ATHENA> Normalizing Athena schemas...")

    outputPath.toFile.mkdirs

    val iterateModels = inputModel === null ? inputPath.toFile.listFiles[f | f.name.endsWith(".athena")].toSet : #{ inputModel.toFile }

    for (model : iterateModels)
    {
      println("ATHENA>> Model: " + model.name)
      val schema = normalizer.m2m(athenaIO.load(model.toPath))
      athenaIO.write(schema, outputPath.resolve(schema.id.name + "_" + schema.id.version + ".athena"))
    }

    println("ATHENA> Athena generation finished!")
  }
}
