package config.defaults;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;

@SuppressWarnings("all")
public class DefaultConfig {
  private static final String PROPERTIES_FILE_NAME = "config.properties";

  private static final Properties properties = new Function0<Properties>() {
    @Override
    public Properties apply() {
      Properties _xblockexpression = null;
      {
        final Properties result = new Properties();
        final InputStream inputStream = DefaultConfig.class.getClassLoader().getResourceAsStream(DefaultConfig.PROPERTIES_FILE_NAME);
        try {
          result.load(inputStream);
        } catch (final Throwable _t) {
          if (_t instanceof IOException) {
            final IOException e = (IOException)_t;
            e.printStackTrace();
          } else {
            throw Exceptions.sneakyThrow(_t);
          }
        }
        _xblockexpression = result;
      }
      return _xblockexpression;
    }
  }.apply();

  public static Properties getDefaultConfig() {
    return DefaultConfig.properties;
  }
}
