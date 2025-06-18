package es.um.uschema.xtext.orion.ide.highlighting

import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator
import es.um.uschema.xtext.orion.services.OrionGrammarAccess
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor
import es.um.uschema.xtext.orion.orion.OrionOperations
import es.um.uschema.xtext.orion.orion.SchemaTypeAddSpec
import es.um.uschema.xtext.orion.orion.OrionPackage
import org.eclipse.xtext.ide.editor.syntaxcoloring.HighlightingStyles
import es.um.uschema.xtext.orion.orion.SchemaTypeRenameSpec
import es.um.uschema.xtext.orion.orion.SimpleDataFeature
import es.um.uschema.xtext.orion.orion.AggregateMorphSpec
import es.um.uschema.xtext.orion.orion.ReferenceMorphSpec
import es.um.uschema.xtext.orion.orion.ReferenceAddSpec
import es.um.uschema.xtext.orion.orion.SchemaTypeMergeSpec
import es.um.uschema.xtext.orion.orion.SchemaTypeExtractSpec
import es.um.uschema.xtext.orion.orion.SchemaTypeSplitSpec
import es.um.uschema.xtext.orion.orion.SchemaTypeDeleteSpec
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.util.CancelIndicator
import com.google.inject.Inject
import es.um.uschema.xtext.orion.orion.FeatureSelector

class OrionSemanticHighlightingCalculator extends DefaultSemanticHighlightingCalculator
{
  @Inject package OrionGrammarAccess grammar

  override protected boolean highlightElement(EObject object, IHighlightedPositionAcceptor acceptor, CancelIndicator cancelIndicator)
  {
    switch (object)
    {
      OrionOperations:       { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.orionOperations_Name, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeAddSpec:     { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeAddSpec_Name, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeDeleteSpec:  { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeDeleteSpec_Ref, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeRenameSpec:  { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeRenameSpec_Name, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeRenameSpec_Ref, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeSplitSpec:   { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeSplitSpec_Ref, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeSplitSpec_Name1, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeSplitSpec_Name2, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeExtractSpec: { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeExtractSpec_Ref, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeExtractSpec_Name, HighlightingStyles.DEFAULT_ID) }
      SchemaTypeMergeSpec:   { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeMergeSpec_Name, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeMergeSpec_Ref1, HighlightingStyles.DEFAULT_ID)
                               highlightFeature(acceptor, object, OrionPackage.eINSTANCE.schemaTypeMergeSpec_Ref2, HighlightingStyles.DEFAULT_ID) }
      ReferenceAddSpec:      { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.referenceAddSpec_Ref, HighlightingStyles.DEFAULT_ID) }
      ReferenceMorphSpec:    { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.referenceMorphSpec_Name, HighlightingStyles.DEFAULT_ID) }
      AggregateMorphSpec:    { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.aggregateMorphSpec_Name, HighlightingStyles.DEFAULT_ID) }
      FeatureSelector:       { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.featureSelector_Ref, HighlightingStyles.DEFAULT_ID) }
      SimpleDataFeature:     { highlightFeature(acceptor, object, OrionPackage.eINSTANCE.simpleDataFeature_Name, HighlightingStyles.DEFAULT_ID) }
    }

    super.highlightElement(object, acceptor, cancelIndicator)
  }
}
