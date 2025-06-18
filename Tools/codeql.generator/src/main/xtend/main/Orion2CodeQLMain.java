package main;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collections;
import java.util.Map;

import com.google.inject.Injector;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.resource.XtextResourceFactory;

import config.Orion2CodeQLConfig;
import es.um.uschema.xtext.orion.OrionStandaloneSetup;
import es.um.uschema.xtext.orion.orion.OrionPackage;
import m2t.Orion2CodeQL;
import util.FileWriterUtil;

public class Orion2CodeQLMain {

    public static void main(String[] args) {
        Injector injector = createInjector();
        registerFactory(injector);
        registerPackage();

        Orion2CodeQLConfig config = new Orion2CodeQLConfig(args);
        runAnalyzer(config, injector);
    }
    
    /**
     * Creates the injector for dependency injection.
     * @return
     */
    private static Injector createInjector() {
        return new OrionStandaloneSetup()
            .createInjectorAndDoEMFRegistration();
    }
    
    /**
	 * Registers the Xtext resource factory for the ".orion" file extension.
	 */
    private static void registerFactory(Injector injector) {
        XtextResourceFactory factory = injector.getInstance(XtextResourceFactory.class);
        org.eclipse.emf.ecore.resource.Resource.Factory.Registry.INSTANCE
            .getExtensionToFactoryMap()
            .put("orion", factory);
    }
    
    /**
     * Registers the Orion package to ensure that the EMF model is loaded correctly.
     */
    private static void registerPackage() {
        EPackage.Registry.INSTANCE
            .put(OrionPackage.eNS_URI, OrionPackage.eINSTANCE);
    }
    
    /**
	 * Runs the predictor with the given configuration and injector.
	 *
	 * @param config  The configuration for the predictor.
	 * @param injector The injector for dependency injection.
	 */
    private static void runAnalyzer(Orion2CodeQLConfig config, Injector injector) {
        try {
            var orionOps = loadAst(config, injector);
            Map<String, String> results = new Orion2CodeQL().m2t(orionOps);
            writeResults(config, results);
            System.out.println("<SpringDataJPA CodeQL Generator> Transformation completed successfully!");
        } catch (Exception e) {
            System.err.println("<SpringDataJPA CodeQL Generator> ERROR: " + e.getMessage());
            System.exit(1);
        }
    }
    
    /**
	 * Loads the AST from the input script using the provided injector.
	 *
	 * @param config  The configuration for the predictor.
	 * @param injector The injector for dependency injection.
	 * @return The loaded AST.
	 * @throws Exception If an error occurs while loading the AST.
	 */
    private static es.um.uschema.xtext.orion.orion.OrionOperations loadAst(Orion2CodeQLConfig config, Injector injector) throws Exception {
        ResourceSet resourceSet = injector.getInstance(ResourceSet.class);
        URI uri = URI.createFileURI(config.getInputScript().toAbsolutePath().toString());
        XtextResource resource = (XtextResource) resourceSet.createResource(uri);
        resource.load(Collections.emptyMap());
        Object root = resource.getContents().isEmpty() ? null : resource.getContents().get(0);
        if (root == null) {
            throw new IllegalStateException("AST vacío");
        }
        return (es.um.uschema.xtext.orion.orion.OrionOperations) root;
    }
    
    /**
     * 	* Writes the results to the output files specified in the configuration.
     * @param config
     * @param results
     * @throws Exception
     */
    private static void writeResults(Orion2CodeQLConfig config, Map<String, String> results) throws Exception {
        for (var entry : results.entrySet()) {
            Path outPath = config.getOutputPath().resolve(entry.getKey());
            if (outPath.getParent() != null) {
                Files.createDirectories(outPath.getParent());
            }
            FileWriterUtil.writeToFile(outPath.toString(), entry.getValue());
        }
    }
}
