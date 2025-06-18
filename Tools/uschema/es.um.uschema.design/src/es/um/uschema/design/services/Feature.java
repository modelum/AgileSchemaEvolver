package es.um.uschema.design.services;

import java.util.stream.Collectors;

import es.um.uschema.USchema.Aggregate;
import es.um.uschema.USchema.Attribute;
import es.um.uschema.USchema.DataType;
import es.um.uschema.USchema.EntityType;
import es.um.uschema.USchema.Key;
import es.um.uschema.USchema.Null;
import es.um.uschema.USchema.PList;
import es.um.uschema.USchema.PMap;
import es.um.uschema.USchema.PSet;
import es.um.uschema.USchema.PTuple;
import es.um.uschema.USchema.PrimitiveType;
import es.um.uschema.USchema.Reference;

public class Feature
{
  public String getAttributeLabel(Attribute attr)
  {
    StringBuilder result = new StringBuilder();
    result.append(attr.getName() + ": " + getTypeLabel(attr.getType()));

    return result.toString();
  }

  public String getTypeLabel(DataType type)
  {
    if (type == null)
      return null;

    StringBuilder result = new StringBuilder();

    if (type instanceof PrimitiveType)
      result.append(((PrimitiveType)type).getName());
    else if (type instanceof PList)
      result.append("List<" + getTypeLabel(((PList)type).getElementType()) + ">");
    else if (type instanceof PSet)
      result.append("Set<" + getTypeLabel(((PSet)type).getElementType()) + ">");
    else if (type instanceof PTuple) result.append("Tuple<" + ((PTuple)type).getElements().stream().map(e -> getTypeLabel(e)).collect(Collectors.joining(", ")) + ">");
    else if (type instanceof PMap) result.append("Map<" + getTypeLabel(((PMap)type).getKeyType()) + "," + getTypeLabel(((PMap)type).getValueType()) + ">");
    else if (type instanceof Null) result.append("Null");
    
    return result.toString();
  }

  public String getReferenceLabel(Reference ref)
  {
    //TODO: For the moment only three cases can be given:
    // 1. The reference has a name and no binded attributes (Neo4J)
    // 2. The reference has no name and binded attributes (MongoDB and SQL)
    // 3. The reference has a name and binded attributes (SQL)
    StringBuilder result = new StringBuilder();

    if ((ref.getName() == null || ref.getName().isEmpty()) && ref.getAttributes().isEmpty())
      throw new IllegalArgumentException("Wrong reference: " + ref + " must have a name or binded attributes.");

    if (ref.getName() != null && !ref.getName().isEmpty())
      result.append(ref.getName() + ":");
    if (!ref.getAttributes().isEmpty())
    {
      result.append(ref.getAttributes().stream().map(attr -> attr.getName()).collect(Collectors.joining(", ")) + ":");
      result.append(" " + getTypeLabel(ref.getAttributes().get(0).getType()));
    }

    result.append(" [");
    result.append(ref.getLowerBound() != -1 ? ref.getLowerBound() : "*");
    result.append("..");
    result.append(ref.getUpperBound() != -1 ? ref.getUpperBound() : "*");
    result.append("] " + ((EntityType)ref.getRefsTo()).getName());

    if (ref.getOpposite() != null)
    {
      result.append("(opp: ");
      if (ref.getOpposite().getName() != null && !ref.getOpposite().getName().isEmpty())
        result.append(ref.getOpposite() + ":");
      if (!ref.getOpposite().getAttributes().isEmpty())
      {
        result.append("(" + ref.getOpposite().getAttributes().stream().map(attr -> attr.getName()).collect(Collectors.joining(", ")) + "):");
        result.append(" " + getTypeLabel(ref.getOpposite().getAttributes().get(0).getType()));
      }

      result.append(" [");
      result.append(ref.getOpposite().getLowerBound() != -1 ? ref.getOpposite().getLowerBound() : "*");
      result.append("..");
      result.append(ref.getOpposite().getUpperBound() != -1 ? ref.getOpposite().getUpperBound() : "*");
      result.append("] " + ((EntityType)ref.getOpposite().getRefsTo()).getName() + ")");
    }

    if (!ref.getIsFeaturedBy().isEmpty())
      result.append("(feat:" + ref.getIsFeaturedBy().get(0).getContainer().getName() + "_" + ref.getIsFeaturedBy().get(0).getVariationId() + ")");

    return result.toString();
  }

  public String getKeyLabel(Key key)
  {
    StringBuilder result = new StringBuilder();

    if (key.getName() != null && !key.getName().isEmpty())
      result.append(key.getName() + ":");
    if (!key.getAttributes().isEmpty())
      result.append("(" + key.getAttributes().stream().map(attr -> attr.getName()).collect(Collectors.joining(", ")) + ")");

    return result.toString();
  }

  public String getAggregateLabel(Aggregate aggr)
  {
    StringBuilder result = new StringBuilder();
    result.append(aggr.getName() + ": ");

    result.append(" [");
    result.append(aggr.getLowerBound() != -1 ? aggr.getLowerBound() : "*");
    result.append("..");
    result.append(aggr.getUpperBound() != -1 ? aggr.getUpperBound() : "*");
    result.append("] ");
    result.append(aggr.getAggregates().get(0).getContainer().getName());
    //result.append("(");
    //result.append(aggr.getAggregates().stream().map(theAggr -> theAggr.getVariationId()).sorted().map(id -> Integer.toString(id)).collect(Collectors.joining(", ")));
    //result.append(")");

    return result.toString();
  }
}
