package es.um.uschema.xtext.orion.main

import es.um.uschema.xtext.orion.m2t.Orion2MongoDB
import es.um.uschema.xtext.athena.utils.io.CodeWriter
import java.nio.file.Path
import es.um.uschema.xtext.orion.utils.io.OrionIO
import es.um.uschema.xtext.athena.utils.io.AthenaIO

class RunningExampleMain
{
  public static val RUNNING_EXAMPLE_PATH = Path.of("../../es.um.uschema.xtext.athena.parent/es.um.uschema.xtext.athena/models/running_examples/tkde/performance/mongodb/")
  public static val ATHENA_MODEL             = "MongoDBSchema.athena"
  public static val ORION_MODEL              = "MongoDBOperations.orion"

  def static void main(String[] args)
  {
    val orionIO = new OrionIO()
    val athenaIO = new AthenaIO()
    val codeWriter = new CodeWriter()
    val transformer = new Orion2MongoDB(false)

    val iterateModels = RUNNING_EXAMPLE_PATH.toFile.listFiles[f | f.name.endsWith(".orion")].toSet

    for (model : iterateModels)
    {
      println("ORION>> Model: " + model.name)
      try
      {
        // These two lists do have the same number of elements
        val scripts = transformer.m2t(orionIO.load(model.toPath))
        val schemas = transformer.schemas

        for (index : 0..scripts.length - 1)
        {
          athenaIO.write(schemas.get(index), RUNNING_EXAMPLE_PATH.resolve(schemas.get(index).id.name + "_" + schemas.get(index).id.version + ".athena"))
          codeWriter.write(scripts.get(index), RUNNING_EXAMPLE_PATH.resolve(schemas.get(index).id.name + "_" + schemas.get(index).id.version + ".js"))
        }
      } catch (IllegalArgumentException e)
      {
        System.err.println("ORION>> Generation error for: " + model.name + " - " + e.message)
      }
    }

    println("ORION> MongoDB generation finished!")
  }
}