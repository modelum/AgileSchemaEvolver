package config

import java.nio.file.Path
import java.util.Properties
import org.apache.commons.cli.Options
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.DefaultParser
import org.apache.commons.cli.ParseException
import config.defaults.DefaultConfig

class Orion2CodeQLConfig {
	Path inputScript
	Path outputPath
  
  	/**
   	* Constructor que parsea los argumentos de línea de comandos.
   	*   -h / --help      Muestra la ayuda
   	*   -i / --input     Ruta al fichero .orion
   	*   -o / --output    Ruta de salida (opcional)
   	*/
	new(String[] args) 
	{
		val options = new Options
		
		// Opción para mostrar la ayuda
		options.addOption(
		  Option.builder("h")
		    .longOpt("help")
		    .desc("Prints help")
		    .build()
		)
		
		// Opción para la ruta al script Orion
	    val inputOption = Option.builder("i")
	      .longOpt("input")
	      .desc("Path to an Orion script file (.orion)")
	      .hasArg()
	      .argName("orion_file")
	      .required(true) 
	      .build()
	    
	    options.addOption(inputOption)

	    // Opción de salida (opcional)
	    val outputOption = Option.builder("o")
	      .longOpt("output")
	      .desc("Path to an output folder")
	      .hasArg()
	      .argName("output_folder")
	      .build()
	    
	    options.addOption(outputOption)

	    val parser = new DefaultParser
	    val formatter = new HelpFormatter

	    try {
	      val cmd = parser.parse(options, args)
	
	      if (cmd.hasOption("h")) {
	        formatter.printHelp("<SpringDataJPA Predictor> ", options)
	        System.exit(0)
	      }
	
	      if (cmd.hasOption("i")) {
	        this.inputScript = Path.of(cmd.getOptionValue("i"))
	      }
	
	      if (cmd.hasOption("o")) {
	        this.outputPath = Path.of(cmd.getOptionValue("o"))
	      }
	
	    } catch (ParseException e) {
	      println(e.message)
	      formatter.printHelp("<SpringDataJPA Predictor> ", options)
	      System.exit(1)
	    }
  	}

  	def setInputScript(Path inputScript) {
    	this.inputScript = inputScript
  	}

  	def Path getInputScript() {
    	return this.inputScript
  	}

  	def setOutputPath(Path outputPath) {
    	this.outputPath = outputPath
  	}

  	def Path getOutputPath() {
    	return this.outputPath
  	}
		
}
