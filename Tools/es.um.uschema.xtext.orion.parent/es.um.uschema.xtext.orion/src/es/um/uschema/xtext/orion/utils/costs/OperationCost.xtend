package es.um.uschema.xtext.orion.utils.costs

enum OperationCost
{
  NOT_IMPLEMENTED_OP,    // Operation is not implemented
  CONSTANT_TIME_OP,      // O(1)
  SINGLE_TRAVERSAL_OP,   // O(n)
  MULTIPLE_TRAVERSAL_OP, // O(n^2)
  HIGH_COST_OP,          // >>>> O(n^2)
  VERY_HIGH_COST_OP      // I/O Stuff
}
