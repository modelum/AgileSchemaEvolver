package config;

import java.nio.file.Path;
import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.InputOutput;

@SuppressWarnings("all")
public class PredictorConfig {
  private Path inputScript;

  private Path outputPath;

  /**
   * Constructor que parsea los argumentos de línea de comandos.
   *   -h / --help      Muestra la ayuda
   *   -i / --input     Ruta al fichero .orion
   *   -o / --output    Ruta de salida (opcional)
   */
  public PredictorConfig(final String[] args) {
    final Options options = new Options();
    options.addOption(
      Option.builder("h").longOpt("help").desc("Prints help").build());
    final Option inputOption = Option.builder("i").longOpt("input").desc("Path to an Orion script file (.orion)").hasArg().argName("orion_file").required(true).build();
    options.addOption(inputOption);
    final Option outputOption = Option.builder("o").longOpt("output").desc("Path to an output folder").hasArg().argName("output_folder").build();
    options.addOption(outputOption);
    final DefaultParser parser = new DefaultParser();
    final HelpFormatter formatter = new HelpFormatter();
    try {
      final CommandLine cmd = parser.parse(options, args);
      boolean _hasOption = cmd.hasOption("h");
      if (_hasOption) {
        formatter.printHelp("<SpringDataJPA Predictor> ", options);
        System.exit(0);
      }
      boolean _hasOption_1 = cmd.hasOption("i");
      if (_hasOption_1) {
        this.inputScript = Path.of(cmd.getOptionValue("i"));
      }
      boolean _hasOption_2 = cmd.hasOption("o");
      if (_hasOption_2) {
        this.outputPath = Path.of(cmd.getOptionValue("o"));
      }
    } catch (final Throwable _t) {
      if (_t instanceof ParseException) {
        final ParseException e = (ParseException)_t;
        InputOutput.<String>println(e.getMessage());
        formatter.printHelp("<SpringDataJPA Predictor> ", options);
        System.exit(1);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }

  public Path setInputScript(final Path inputScript) {
    return this.inputScript = inputScript;
  }

  public Path getInputScript() {
    return this.inputScript;
  }

  public Path setOutputPath(final Path outputPath) {
    return this.outputPath = outputPath;
  }

  public Path getOutputPath() {
    return this.outputPath;
  }
}
