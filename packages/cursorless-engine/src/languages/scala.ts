import type { SimpleScopeTypeType } from "@cursorless/common";
import type { NodeMatcherAlternative } from "../typings/Types";
import { patternFinder } from "../util/nodeFinders";
import {
  argumentMatcher,
  createPatternMatchers,
  leadingMatcher,
  matcher,
} from "../util/nodeMatchers";
import { childRangeSelector } from "../util/nodeSelectors";

const nodeMatchers: Partial<
  Record<SimpleScopeTypeType, NodeMatcherAlternative>
> = {
  argumentOrParameter: argumentMatcher(
    "arguments",
    "parameters",
    "class_parameters",
    "bindings",
  ),
  branch: matcher(
    patternFinder("case_clause"),
    childRangeSelector([], [], {
      includeUnnamedChildren: true,
    }),
  ),

  // *[type] does not work here because while we want most of these we don't want "compound" types,
  // eg `generic_type[type]`, because that will grab just the inner generic (the String of List[String])
  // and as a rule we want to grab entire type definitions.
  type: leadingMatcher(
    [
      "upper_bound[type]",
      "lower_bound[type]",
      "view_bound[type]",
      "context_bound[type]",
      "val_definition[type]",
      "val_declaration[type]",
      "var_definition[type]",
      "var_declaration[type]",
      "type_definition",
      "extends_clause[type]",
      "class_parameter[type]",
      "parameter[type]",
      "function_definition[return_type]",
      "typed_pattern[type]",
      "binding[type]",
    ],
    [":"],
  ),
  value: leadingMatcher(
    ["*[value]", "*[default_value]", "type_definition[type]"],
    ["="],
  ),

  // Scala features unsupported in Cursorless terminology
  //  - Pattern matching

  // Cursorless terminology not yet supported in this Scala implementation
  /*
    lists and maps basic definition are just function calls to constructors, eg List(1,2,3,4)
    These types are also basically arbitrary, so we can't really hard-code them
    There is also fancy list style: val foo = 1 :: (2 :: (3 :: Nil)) // List(1,2,3)
  */
  // list: 'call_expression',
  // map: 'call_expression',

  /* infix_expression, key on left, item on right, operator = "->"
  // collectionItem: "???"
  // collectionKey: "???",

  /* "foo".r <-, value of type field_expression, value of type string, field of type identifier = "r",
  // regularExpression: "???",

  /*
    none of this stuff is defined well in the tree sitter (it's all just infix expressions etc),
    and native XML/HTML is deprecated in Scala 3
  */
  // attribute: "???",
  // xmlElement: "???",
  // xmlStartTag: "???",
  // xmlEndTag: "???",
  // xmlBothTags: "???",
};

export default createPatternMatchers(nodeMatchers);
