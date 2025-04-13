;; https://github.com/tree-sitter/tree-sitter-java/blob/master/src/grammar.json

;; Generated by the following command:
;; > curl https://raw.githubusercontent.com/tree-sitter/tree-sitter-java/master/src/node-types.json | jq '[.[] | select(.type == "statement" or .type == "declaration") | .subtypes[].type]'
[
  (annotation_type_declaration)
  (class_declaration)
  (enum_declaration)
  (import_declaration)
  (interface_declaration)
  (module_declaration)
  (package_declaration)
  (assert_statement)
  (break_statement)
  (continue_statement)
  (declaration)
  (do_statement)
  (enhanced_for_statement)
  (expression_statement)
  (for_statement)
  (if_statement)
  (labeled_statement)
  (local_variable_declaration)
  (return_statement)
  (switch_expression)
  (synchronized_statement)
  (throw_statement)
  (try_statement)
  (try_with_resources_statement)
  (while_statement)
  (yield_statement)

  ;; exceptions
  ;; ";",
  ;; "block",
  (method_declaration)
  (constructor_declaration)
  (field_declaration)
] @statement

[
  (class_declaration)
  (interface_declaration)
  (enum_declaration)
] @type

(class_declaration
  name: (_) @name @className
) @class @_.domain

(program) @class.iteration @className.iteration @name.iteration
(program) @statement.iteration

;;!! class MyClass { }
;;!                 ^
(class_body
  .
  "{" @class.iteration.start.endOf @className.iteration.start.endOf
  "}" @class.iteration.end.startOf @className.iteration.end.startOf
  .
)

(class_body
  .
  "{" @type.iteration.start.endOf @namedFunction.iteration.start.endOf @functionName.iteration.start.endOf
  "}" @type.iteration.end.startOf @namedFunction.iteration.end.startOf @functionName.iteration.end.startOf
  .
)

;;!! for (...) { }
;;!             ^
(_
  body: (_
    .
    "{" @name.iteration.start.endOf @statement.iteration.start.endOf
    "}" @name.iteration.end.startOf @statement.iteration.end.startOf
    .
  )
)

;;!! if (true) { }
;;!             ^
(if_statement
  (block
    .
    "{" @name.iteration.start.endOf @statement.iteration.start.endOf
    "}" @name.iteration.end.startOf @statement.iteration.end.startOf
    .
  )
)

;;!! void myFunk() {}
;;!  ^^^^^^^^^^^^^^^^
(method_declaration
  name: (_) @name @functionName
) @namedFunction @_.domain
(constructor_declaration
  name: (_) @name @functionName
) @namedFunction @_.domain

;;!! ((value) -> true)
;;!   ^^^^^^^^^^^^^^^
(lambda_expression) @anonymousFunction

;;!! if (value) {}
;;!  ^^^^^^^^^^^^^
(
  (if_statement) @ifStatement
  (#not-parent-type? @ifStatement "if_statement")
)

;;!! "string"
;;!  ^^^^^^^^
(
  (string_literal) @string @textFragment
  (#character-range! @textFragment 1 -1)
)

;;!! """string"""
;;!  ^^^^^^^^^^^^
(
  (text_block) @string @textFragment
  (#character-range! @textFragment 3 -3)
)

;;!! // comment
;;!  ^^^^^^^^^^
[
  (line_comment)
  (block_comment)
] @comment @textFragment

;;!! int[] values = {1, 2, 3};
;;!                 ^^^^^^^^^
(array_initializer) @list

;;!! List<String> value = new ArrayList() {{ add("a"); }};
;;!                                       ^^^^^^^^^^^^^^^
(object_creation_expression
  (class_body
    (block) @map
  )
)

;;!! foo(1);
;;!  ^^^^^^
;;!! new Foo(1);
;;!  ^^^^^^^^^^
;;!! super(1);
;;!  ^^^^^^^^
[
  (method_invocation)
  (object_creation_expression)
  (explicit_constructor_invocation)
] @functionCall

;;!! case "0": return "zero";
;;!  ^^^^^^^^^^^^^^^^^^^^^^^^
;;!! case "0" -> "zero";
;;!  ^^^^^^^^^^^^^^^^^^^
[
  (switch_block_statement_group)
  (switch_rule)
] @branch

;;!! case "0": return "zero";
;;!       ^^^
;;!  ------------------------
(switch_block_statement_group
  (switch_label
    (_) @condition
  )
) @condition.domain

;;!! case "0" -> "zero";
;;!       ^^^
;;!  -------------------
(switch_rule
  (switch_label
    (_) @condition
  )
) @condition.domain

(switch_expression
  body: (_
    .
    "{" @branch.iteration.start.endOf @condition.iteration.start.endOf
    "}" @condition.iteration.end.startOf @branch.iteration.end.startOf
    .
  )
) @condition.iteration.domain @branch.iteration.domain

;;!! if () {}
;;!  ^^^^^^^^
(
  (if_statement
    "if" @branch.start @branch.removal.start
    condition: (_) @condition
    consequence: (block) @branch.end @branch.removal.end
    alternative: (if_statement)? @branch.removal.end.startOf
  ) @condition.domain
  (#not-parent-type? @condition.domain "if_statement")
  (#child-range! @condition 0 -1 true true)
)

;;!! else if () {}
;;!  ^^^^^^^^^^^^^
(if_statement
  "else" @branch.start @condition.domain.start
  alternative: (if_statement
    condition: (_) @condition
    consequence: (block) @branch.end @condition.domain.end
    (#child-range! @condition 0 -1 true true)
  )
)

;;!! else {}
;;!  ^^^^^^^
(if_statement
  "else" @branch.start
  alternative: (block) @branch.end
)

(
  (if_statement) @branch.iteration
  (#not-parent-type? @branch.iteration "if_statement")
)

;;!! try {}
;;!  ^^^^^^
(try_statement
  "try" @branch.start
  body: (_) @branch.end
)

;;!! catch (Exception e) {}
;;!  ^^^^^^^^^^^^^^^^^^^^^^
(catch_clause) @branch

;;!! finally {}
;;!  ^^^^^^^^^^
(finally_clause) @branch

(try_statement) @branch.iteration

;;!! for (int i = 0; i < 5; ++i) {}
;;!                  ^^^^^
;;!  ------------------------------
(for_statement
  condition: (_) @condition
) @branch @_.domain

;;!! while (value) {}
;;!         ^^^^^
;;!  ----------------
(while_statement
  condition: (_) @condition
  (#child-range! @condition 0 -1 true true)
) @branch @_.domain

(do_statement
  condition: (_) @condition
  (#child-range! @condition 0 -1 true true)
) @branch @_.domain

;;!! switch (value) {}
;;!          ^^^^^
;;!  -----------------
(switch_expression
  condition: (_) @private.switchStatementSubject
  (#child-range! @private.switchStatementSubject 0 -1 true true)
) @_.domain

;;!! true ? 1 : 2
(ternary_expression
  condition: (_) @condition
  consequence: (_) @branch
) @condition.domain
(ternary_expression
  alternative: (_) @branch
)

;;!! true ? 1 : 2
;;!  ^^^^^^^^^^^^
(ternary_expression) @branch.iteration

;;!! void myFunk(int value) {}
;;!                  ^^^^^
;;!  -------------------------
(formal_parameter
  (identifier) @name
) @_.domain

;;!! void myFunk(int value) {}
;;!              ^^^^^^^^^
(formal_parameters
  .
  "(" @type.iteration.start.endOf @name.iteration.start.endOf
  ")" @type.iteration.end.startOf @name.iteration.end.startOf
  .
) @type.iteration.domain @name.iteration.domain

;;!! Map<String, String>
;;!     ^^^^^^^  ^^^^^^
(type_arguments
  (type_identifier) @type
)

;;!! List<String> list = value;
;;!  ^^^^^^^^^^^^
;;!  --------------------------
(local_variable_declaration
  type: (_) @type
) @_.domain

;;!! name = new ArrayList<String>();
;;!             ^^^^^^^^^^^^^^^^^
;;!         -----------------------
(object_creation_expression
  type: (_) @type
) @_.domain

;;!! name = new int[5];
;;!             ^^^
;;!         ----------
(array_creation_expression
  type: (_) @type
) @_.domain

;;!! void myFunk(int value) {}
;;!              ^^^
;;!              ---------
(formal_parameter
  type: (_) @type
) @_.domain

;;!! int size() {}
;;!  ^^^
;;!  -------------
(method_declaration
  type: (_) @type
) @_.domain

;;!! (int)5
;;!   ^^^
(cast_expression
  "(" @type.removal.start
  type: (_) @type
  ")" @type.removal.end
) @_.domain

;;!! new test();
;;!  ^^^^^^^^
;;!  -----------
(_
  (object_creation_expression
    (argument_list) @functionCallee.end.startOf
  ) @functionCallee.start.startOf @_.domain.start
  ";"? @_.domain.end
)

;;!! new test().bar();
;;!  ^^^^^^^^^^^^^^
;;!  -----------------
(_
  (method_invocation
    (argument_list) @functionCallee.end.startOf
  ) @functionCallee.start.startOf @_.domain.start
  ";"? @_.domain.end
)

;;!! super();
;;!  ^^^^^
;;!  --------
(explicit_constructor_invocation
  (argument_list) @functionCallee.end.startOf
) @functionCallee.start.startOf @_.domain

;;!! for (int value : values) {}
;;!                   ^^^^^^
;;!  ---------------------------
(enhanced_for_statement
  type: (_) @type
  name: (_) @name
  value: (_) @value
) @branch @_.domain

;;!! int value = 1;
;;!              ^
;;!           xxxx
;;!  --------------
(local_variable_declaration
  (variable_declarator
    name: (_) @name @value.leading.endOf
    value: (_)? @value @name.trailing.startOf
  )
) @_.domain

(field_declaration
  (variable_declarator
    name: (_) @name @value.leading.endOf
    value: (_)? @value @name.trailing.startOf
  )
) @_.domain

;;!! int foo, bar;
;;!      ^^^  ^^^
(
  (local_variable_declaration
    type: (_)
    (variable_declarator)? @_.leading.endOf
    .
    (variable_declarator) @collectionItem
    .
    (variable_declarator)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

(
  (field_declaration
    type: (_)
    (variable_declarator)? @_.leading.endOf
    .
    (variable_declarator) @collectionItem
    .
    (variable_declarator)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

;;!! int foo, bar;
;;!      ^^^^^^^^
;;!  -------------
(local_variable_declaration
  type: (_)
  .
  (_) @collectionItem.iteration.start.startOf
  ";"? @collectionItem.iteration.end.startOf
) @collectionItem.iteration.domain

(field_declaration
  type: (_)
  .
  (_) @collectionItem.iteration.start.startOf
  ";"? @collectionItem.iteration.end.startOf
) @collectionItem.iteration.domain

;;!! value = 1;
;;!          ^
;;!       xxxx
;;!  ----------
(_
  (assignment_expression
    left: (_) @name @value.leading.endOf
    right: (_) @value @name.trailing.startOf
  ) @_.domain.start
  ";"? @_.domain.end
)

;;!! return value;
;;!         ^^^^^
;;!  -------------
(
  (return_statement) @value @_.domain
  (#child-range! @value 1 -2)
)

;;!! str -> str.length > 0
;;!         ^^^^^^^^^^^^^^
;;!  ---------------------
(lambda_expression
  body: (_) @value
  (#not-type? @value block)
) @_.domain

;;!! public Map<int, int> foo;
;;!         ^^^^^^^^^^^^^
;;!  -------------------------
(field_declaration
  type: (_) @type
) @_.domain

;;!! public Map<int, int> foo;
;;!             ^^^  ^^^
(type_arguments
  (_) @type
)

;;!! public Map<int, int> foo;
;;!             ^^^^^^^^
(type_arguments
  .
  "<" @type.iteration.start.endOf
  ">" @type.iteration.end.startOf
  .
)
;;!! foo(name: string) {}
;;!      ^^^^^^^^^^^^
(
  (formal_parameters
    (_)? @_.leading.endOf
    .
    (_) @argumentOrParameter
    .
    (_)? @_.trailing.startOf
  ) @_dummy
  (#not-type? @argumentOrParameter "block_comment")
  (#single-or-multi-line-delimiter! @argumentOrParameter @_dummy ", " ",\n")
)

;;!! foo("bar")
;;!      ^^^^^
(
  (argument_list
    (_)? @_.leading.endOf
    .
    (_) @argumentOrParameter
    .
    (_)? @_.trailing.startOf
  ) @_dummy
  (#not-type? @argumentOrParameter "block_comment")
  (#single-or-multi-line-delimiter! @argumentOrParameter @_dummy ", " ",\n")
)

(_
  (formal_parameters
    "(" @argumentOrParameter.iteration.start.endOf
    ")" @argumentOrParameter.iteration.end.startOf
  )
) @argumentOrParameter.iteration.domain

(argument_list
  "(" @argumentOrParameter.iteration.start.endOf
  ")" @argumentOrParameter.iteration.end.startOf
) @argumentOrParameter.iteration.domain

;;!! try (PrintWriter writer = create()) { }
;;!       ^^^^^^^^^^^ ^^^^^    ^^^^^^^^
(try_with_resources_statement
  (resource_specification
    (resource
      type: (_) @type
      name: (_) @name
      value: (_) @value
    )
  )
) @_.domain

operator: [
  "<"
  "<<"
  "<<="
  "<="
  ">"
  ">="
  ">>"
  ">>="
  ">>>"
  ">>>="
] @disqualifyDelimiter
(lambda_expression
  "->" @disqualifyDelimiter
)
(switch_rule
  "->" @disqualifyDelimiter
)
