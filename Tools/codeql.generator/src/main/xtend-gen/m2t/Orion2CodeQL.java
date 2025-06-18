package m2t;

import codeql.option.SeverityEnum;
import codeql.template.Library;
import codeql.template.Metadata;
import codeql.template.Query;
import es.um.uschema.xtext.orion.orion.AttributeCastOp;
import es.um.uschema.xtext.orion.orion.AttributePromoteOp;
import es.um.uschema.xtext.orion.orion.BasicOperation;
import es.um.uschema.xtext.orion.orion.EntityDeleteOp;
import es.um.uschema.xtext.orion.orion.EntityRenameOp;
import es.um.uschema.xtext.orion.orion.EntitySplitOp;
import es.um.uschema.xtext.orion.orion.EvolBlock;
import es.um.uschema.xtext.orion.orion.FeatureDeleteOp;
import es.um.uschema.xtext.orion.orion.FeatureMoveOp;
import es.um.uschema.xtext.orion.orion.FeatureRenameOp;
import es.um.uschema.xtext.orion.orion.MultipleFeatureSelector;
import es.um.uschema.xtext.orion.orion.OrionOperations;
import es.um.uschema.xtext.orion.orion.RelationshipDeleteOp;
import es.um.uschema.xtext.orion.orion.RelationshipRenameOp;
import es.um.uschema.xtext.orion.orion.SingleFeatureSelector;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.eclipse.emf.common.util.EList;
import org.eclipse.xtend2.lib.StringConcatenation;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import orion.Mapper;

@SuppressWarnings("all")
public class Orion2CodeQL {
  private Map<String, String> results;

  private int contOp = 0;

  public Orion2CodeQL() {
    HashMap<String, String> _hashMap = new HashMap<String, String>();
    this.results = _hashMap;
  }

  public Map<String, String> m2t(final OrionOperations orion) {
    Map<String, String> _xblockexpression = null;
    {
      int _size = orion.getOperations().size();
      String _plus = ("» m2t() arrancó. bloques=" + Integer.valueOf(_size));
      String _plus_1 = (_plus + " ops, ");
      int _size_1 = orion.getEvolBlocks().size();
      String _plus_2 = (_plus_1 + Integer.valueOf(_size_1));
      String _plus_3 = (_plus_2 + " eBlocks");
      System.out.println(_plus_3);
      if (((!orion.getOperations().isEmpty()) || (!orion.getEvolBlocks().isEmpty()))) {
        this.results.put("utils.qll", Library.generateUtils().toString());
      }
      InputOutput.<String>println("Vale se genero utils");
      boolean _isEmpty = orion.getOperations().isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        this.generateOperations(orion.getOperations());
      } else {
        EList<EvolBlock> _evolBlocks = orion.getEvolBlocks();
        for (final EvolBlock eBlock : _evolBlocks) {
          {
            this.generateOperations(eBlock.getOperations());
            this.contOp = 0;
          }
        }
      }
      _xblockexpression = this.results;
    }
    return _xblockexpression;
  }

  public void generateOperations(final List<BasicOperation> operations) {
    for (final BasicOperation op : operations) {
      {
        this.generateOperation(op);
        this.contOp++;
      }
    }
  }

  protected Object _generateOperation(final BasicOperation op) {
    return Integer.valueOf(this.contOp--);
  }

  protected Object _generateOperation(final EntityDeleteOp op) {
    String _plus = (Integer.valueOf(this.contOp) + "-EntityDeleteOp.ql");
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generateHeader = Metadata.generateHeader("Deleted Entity", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/entity-deleted/" + Integer.valueOf(this.contOp)));
    _builder.append(_generateHeader);
    CharSequence _generateEntityDeleteOp = Query.generateEntityDeleteOp(op.getSpec().getRef());
    _builder.append(_generateEntityDeleteOp);
    return this.results.put(_plus, _builder.toString());
  }

  protected Object _generateOperation(final EntityRenameOp op) {
    String _plus = (Integer.valueOf(this.contOp) + "-EntityRenameOp.ql");
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generateHeader = Metadata.generateHeader("Renamed Entity", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/entity-renamed/" + Integer.valueOf(this.contOp)));
    _builder.append(_generateHeader);
    CharSequence _generateEntityRenameOp = Query.generateEntityRenameOp(op.getSpec().getRef(), op.getSpec().getName());
    _builder.append(_generateEntityRenameOp);
    return this.results.put(_plus, _builder.toString());
  }

  protected Object _generateOperation(final FeatureRenameOp op) {
    String _xblockexpression = null;
    {
      SingleFeatureSelector selector = op.getSpec().getSelector();
      String _plus = (Integer.valueOf(this.contOp) + "-FeatureRenameOp.ql");
      StringConcatenation _builder = new StringConcatenation();
      CharSequence _generateHeader = Metadata.generateHeader("Feature Renamed", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/feature-renamed/" + Integer.valueOf(this.contOp)));
      _builder.append(_generateHeader);
      CharSequence _generateFeatureRenameOp = Query.generateFeatureRenameOp(selector.getRef(), selector.getTarget(), op.getSpec().getName());
      _builder.append(_generateFeatureRenameOp);
      _xblockexpression = this.results.put(_plus, _builder.toString());
    }
    return _xblockexpression;
  }

  protected Object _generateOperation(final FeatureDeleteOp op) {
    MultipleFeatureSelector selector = op.getSpec().getSelector();
    int targetCount = 0;
    EList<String> _targets = selector.getTargets();
    for (final String target : _targets) {
      {
        String _plus = (Integer.valueOf(this.contOp) + "-");
        String _plus_1 = (_plus + Integer.valueOf(targetCount));
        String _plus_2 = (_plus_1 + "-FeatureDeleteOp.ql");
        StringConcatenation _builder = new StringConcatenation();
        CharSequence _generateHeader = Metadata.generateHeader("Feature Deleted", "alert", SeverityEnum.WARNING.getValue(), ((("java/orion/feature-deleted/" + Integer.valueOf(this.contOp)) + "/") + Integer.valueOf(targetCount)));
        _builder.append(_generateHeader);
        CharSequence _generateFeatureDeleteOp = Query.generateFeatureDeleteOp(selector.getRef(), target);
        _builder.append(_generateFeatureDeleteOp);
        this.results.put(_plus_2, _builder.toString());
        targetCount++;
      }
    }
    return null;
  }

  protected Object _generateOperation(final AttributeCastOp op) {
    int _xblockexpression = (int) 0;
    {
      MultipleFeatureSelector selector = op.getSpec().getSelector();
      String type = Mapper.OrionType2Java(op.getSpec().getType().getTypename());
      int targetCount = 0;
      int _xifexpression = (int) 0;
      boolean _isEmpty = type.isEmpty();
      boolean _not = (!_isEmpty);
      if (_not) {
        EList<String> _targets = selector.getTargets();
        for (final String target : _targets) {
          {
            String _plus = (Integer.valueOf(this.contOp) + "-");
            String _plus_1 = (_plus + Integer.valueOf(targetCount));
            String _plus_2 = (_plus_1 + "-AttributeCastOp.ql");
            StringConcatenation _builder = new StringConcatenation();
            CharSequence _generateHeader = Metadata.generateHeader("Attribute Casted", "alert", SeverityEnum.WARNING.getValue(), ((("java/orion/attribute-casted/" + Integer.valueOf(this.contOp)) + "/") + Integer.valueOf(targetCount)));
            _builder.append(_generateHeader);
            CharSequence _generateAttributeCastOp = Query.generateAttributeCastOp(selector.getRef(), target, type);
            _builder.append(_generateAttributeCastOp);
            this.results.put(_plus_2, _builder.toString());
            targetCount++;
          }
        }
      } else {
        _xifexpression = this.contOp--;
      }
      _xblockexpression = _xifexpression;
    }
    return Integer.valueOf(_xblockexpression);
  }

  protected Object _generateOperation(final AttributePromoteOp op) {
    String _xblockexpression = null;
    {
      MultipleFeatureSelector selector = op.getSpec().getSelector();
      String fields = IterableExtensions.join(selector.getTargets(), ",");
      String _plus = (Integer.valueOf(this.contOp) + "-AttributePromoteOp.ql");
      StringConcatenation _builder = new StringConcatenation();
      CharSequence _generateHeader = Metadata.generateHeader("Attribute Promoted", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/attribute-promoted/" + Integer.valueOf(this.contOp)));
      _builder.append(_generateHeader);
      CharSequence _generateAttributePromoteOp = Query.generateAttributePromoteOp(selector.getRef(), fields);
      _builder.append(_generateAttributePromoteOp);
      _xblockexpression = this.results.put(_plus, _builder.toString());
    }
    return _xblockexpression;
  }

  protected Object _generateOperation(final RelationshipDeleteOp op) {
    String _plus = (Integer.valueOf(this.contOp) + "-RelationshipDeleteOp.ql");
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generateHeader = Metadata.generateHeader("Relationship Deleted", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/relationship-deleted/" + Integer.valueOf(this.contOp)));
    _builder.append(_generateHeader);
    CharSequence _generateRelationshipDeleteOp = Query.generateRelationshipDeleteOp(op.getSpec().getRef());
    _builder.append(_generateRelationshipDeleteOp);
    return this.results.put(_plus, _builder.toString());
  }

  protected Object _generateOperation(final RelationshipRenameOp op) {
    String _plus = (Integer.valueOf(this.contOp) + "-RelationshipRenameOp.ql");
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generateHeader = Metadata.generateHeader("Relationship Renamed", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/relationship-renamed/" + Integer.valueOf(this.contOp)));
    _builder.append(_generateHeader);
    CharSequence _generateRelationshipRenameOp = Query.generateRelationshipRenameOp(op.getSpec().getRef(), op.getSpec().getName());
    _builder.append(_generateRelationshipRenameOp);
    return this.results.put(_plus, _builder.toString());
  }

  protected Object _generateOperation(final EntitySplitOp op) {
    String _plus = (Integer.valueOf(this.contOp) + "-EntitySplitOp.ql");
    StringConcatenation _builder = new StringConcatenation();
    CharSequence _generateHeader = Metadata.generateHeader("Split Entity", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/entity-splited/" + Integer.valueOf(this.contOp)));
    _builder.append(_generateHeader);
    CharSequence _generateEntityDeleteOp = Query.generateEntityDeleteOp(op.getSpec().getRef());
    _builder.append(_generateEntityDeleteOp);
    return this.results.put(_plus, _builder.toString());
  }

  protected Object _generateOperation(final FeatureMoveOp op) {
    String _xblockexpression = null;
    {
      SingleFeatureSelector selector = op.getSpec().getSourceSelector();
      String _plus = (Integer.valueOf(this.contOp) + "-FeatureMoveOp.ql");
      StringConcatenation _builder = new StringConcatenation();
      CharSequence _generateHeader = Metadata.generateHeader("Feature Moved", "alert", SeverityEnum.WARNING.getValue(), ("java/orion/feature-moved/" + Integer.valueOf(this.contOp)));
      _builder.append(_generateHeader);
      CharSequence _generateFeatureDeleteOp = Query.generateFeatureDeleteOp(selector.getRef(), selector.getTarget());
      _builder.append(_generateFeatureDeleteOp);
      _xblockexpression = this.results.put(_plus, _builder.toString());
    }
    return _xblockexpression;
  }

  public Object generateOperation(final BasicOperation op) {
    if (op instanceof EntityDeleteOp) {
      return _generateOperation((EntityDeleteOp)op);
    } else if (op instanceof EntityRenameOp) {
      return _generateOperation((EntityRenameOp)op);
    } else if (op instanceof EntitySplitOp) {
      return _generateOperation((EntitySplitOp)op);
    } else if (op instanceof RelationshipDeleteOp) {
      return _generateOperation((RelationshipDeleteOp)op);
    } else if (op instanceof RelationshipRenameOp) {
      return _generateOperation((RelationshipRenameOp)op);
    } else if (op instanceof AttributeCastOp) {
      return _generateOperation((AttributeCastOp)op);
    } else if (op instanceof AttributePromoteOp) {
      return _generateOperation((AttributePromoteOp)op);
    } else if (op instanceof FeatureDeleteOp) {
      return _generateOperation((FeatureDeleteOp)op);
    } else if (op instanceof FeatureMoveOp) {
      return _generateOperation((FeatureMoveOp)op);
    } else if (op instanceof FeatureRenameOp) {
      return _generateOperation((FeatureRenameOp)op);
    } else if (op != null) {
      return _generateOperation(op);
    } else {
      throw new IllegalArgumentException("Unhandled parameter types: " +
        Arrays.<Object>asList(op).toString());
    }
  }
}
