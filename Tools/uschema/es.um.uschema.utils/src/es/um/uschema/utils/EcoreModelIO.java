package es.um.uschema.utils;

import java.io.BufferedOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.BasicExtendedMetaData;
import org.eclipse.emf.ecore.util.ExtendedMetaData;
import org.eclipse.emf.ecore.xmi.XMIResource;
import org.eclipse.emf.ecore.xmi.XMLResource;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;

import es.um.uschema.USchema.USchemaPackage;

public class EcoreModelIO
{
  private ResourceSet resourceSet;
  private static Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
  private HashMap<Object, Object> writeOptions;

  static
  {
    Map<String, Object> map = reg.getExtensionToFactoryMap();
    map.put("xmi", new XMIResourceFactoryImpl());
    map.put("uschema", new XMIResourceFactoryImpl());
  }

  public EcoreModelIO()
  {
    resourceSet = new ResourceSetImpl();
    final ExtendedMetaData extendedMetaData = new BasicExtendedMetaData(resourceSet.getPackageRegistry());
    resourceSet.getLoadOptions().put(XMLResource.OPTION_EXTENDED_META_DATA, extendedMetaData);
    resourceSet.getLoadOptions().put(XMLResource.OPTION_DEFER_IDREF_RESOLUTION, Boolean.TRUE);

    registerPackages(USchemaPackage.eINSTANCE);

    writeOptions = new HashMap<Object, Object>();
    writeOptions.put(XMIResource.OPTION_SCHEMA_LOCATION, Boolean.TRUE);
    writeOptions.put(XMIResource.OPTION_ENCODING, "UTF-8");
    writeOptions.put(XMIResource.OPTION_DEFER_IDREF_RESOLUTION, Boolean.TRUE);
  }

  public EcoreModelIO(EPackage thePackage)
  {
    this();
    registerPackages(thePackage);
  }

  public EcoreModelIO forPackages(EPackage... packages)
  {
    registerPackages(packages);
    return this;
  }

  public EcoreModelIO withExtension(String extension, Object rf)
  {
    registerExtension(extension,rf);
    return this;
  }

  public void registerExtension(String extension, Object resourceFactory)
  {
    reg.getExtensionToFactoryMap().put(extension, resourceFactory);
  }

  public void registerPackages(EPackage... packages)
  {
    for (EPackage p : packages)
      resourceSet.getPackageRegistry().put(p.getNsURI(), p);
  }

  @SuppressWarnings("unchecked")
  public <T> T load(Class<T> c, Path inputPath)
  {
    Resource r = resourceSet.getResource(URI.createFileURI(inputPath.toString()), true);
    return (T)r.getContents().get(0);
  }

  /**
   * Opens a Model file whose package was previously registered.
   * @deprecated
   * Please use load(Path inputPath, Class<T> c) instead
   * <p> Use {@link #load(Class<T>, Path)} instead.
   * @return An opened model file casted to T
   */
  @Deprecated
  public <T> T load(Class<T> c, String inputPath)
  {
    return load(c, Path.of(inputPath));
  }

  public ResourceSet getResourceSet()
  {
    return resourceSet;
  }

  public void write(EObject eObject, Path outputPath)
  {
    Resource outputRes = resourceSet.createResource(URI.createFileURI(outputPath.toString()));
    outputRes.getContents().add(eObject);

    try
    {
      outputRes.save(new BufferedOutputStream(Files.newOutputStream(outputPath)), writeOptions);
    } catch (IOException e)
    {
      e.printStackTrace();
    }
  }
}
