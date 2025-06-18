package es.um.uschema.utils.custom.compare;

import java.util.Map;
import java.util.Collections;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import es.um.uschema.USchema.PrimitiveType;

public class ComparePrimitiveType extends Comparator<PrimitiveType>
{
	
  private static final Map<String,String> TYPES_MAP = Collections.unmodifiableMap(Stream.of(new String[][] {
	  {"String".toLowerCase(), 	"string"},
	  {"Long".toLowerCase(), 	"number"},
	  {"Integer".toLowerCase(), 	"number"},
	  {"Number".toLowerCase(), 	"number"},
	  {"Boolean".toLowerCase(), 	"boolean"},
	  {"Double".toLowerCase(), 	"double"},
	  {"Float".toLowerCase(), 	"double"}
  	}).collect(Collectors.toMap(s->s[0],s->s[1])));

  private static final Function<String,String> mapType = (t -> TYPES_MAP.containsKey(t.toLowerCase()) ? TYPES_MAP.get(t.toLowerCase()) : t);
	  
  @Override
  public boolean compare(PrimitiveType p1, PrimitiveType p2)
  {
    if (super.checkNulls(p1, p2))
      return false;

    if (super.checkEquals(p1, p2))
      return true;

    if (p1.getName() == null ^ p2.getName() == null)
      return false; 
    
    return (p1.getName() == null && p2.getName() == null)
        || (mapType.apply(p1.getName()).equals(mapType.apply(p2.getName())));
  }

}
