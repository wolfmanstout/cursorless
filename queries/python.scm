;; import python.fieldAccess.scm

;; https://github.com/tree-sitter/tree-sitter-python/blob/master/src/grammar.json

;; Generated by the following command:
;; > curl https://raw.githubusercontent.com/tree-sitter/tree-sitter-python/d6210ceab11e8d812d4ab59c07c81458ec6e5184/src/node-types.json \
;;   | jq '[.[] | select(.type == "_simple_statement" or .type == "_compound_statement") | .subtypes[].type]'
[
  (assert_statement)
  (break_statement)
  (class_definition)
  (continue_statement)
  (decorated_definition)
  (delete_statement)
  (exec_statement)
  (expression_statement)
  (for_statement)
  (function_definition)
  (future_import_statement)
  (global_statement)
  (if_statement)
  (import_from_statement)
  (import_statement)
  (match_statement)
  (nonlocal_statement)
  (pass_statement)
  (print_statement)
  (raise_statement)
  (return_statement)
  (try_statement)
  (while_statement)
  (with_statement)
] @statement

;;!! a = 25
;;!      ^^
;;!   xxxxx
;;!  ------
(assignment
  (_) @_.leading.endOf
  .
  right: (_) @value
) @_.domain

;; value:
;;!! a /= 25
;;!       ^^
;;!   xxxxxx
;;!  -------
;; name:
;;!! a /= 25
;;!  ^
;;!  xxxxx
;;!  -------
(augmented_assignment
  left: (_) @name @value.leading.endOf
  right: (_) @value @name.trailing.startOf
) @_.domain

;;!! a = 25
;;!  ^
;;!  xxxx
;;!  ------
;;!! a: int = 25
;;!  ^
;;!  xxxxxxxxx
;;!  -----------
(assignment
  left: (_) @name
  right: (_)? @_.trailing.startOf
) @_.domain

(_
  name: (_) @name
) @_.domain

;;!! def aaa(bbb):
;;!          ^^^
(parameters
  (identifier) @name
)

;;!! def aaa(bbb: str):
;;!          ^^^
;;!          --------
(typed_parameter
  .
  (_) @name
) @_.domain

;; Matches any node at field `type` of its parent, with leading delimiter until
;; previous named node. For example:
;;!! aaa: str = "bbb";
;;!       ^^^
;;!  -----------------
;;!     xxxxx
(_
  (_) @_.leading.endOf
  .
  type: (_) @type
) @_.domain

;;!!  def aaa() -> str:
;;!                ^^^
;;!            xxxxxxx
;;!  [-----------------
;;!!      pass
;;!   --------]
(function_definition
  (_) @_.leading.endOf
  .
  return_type: (_) @type
) @_.domain

;;!! d = {"a": 1234}
;;!            ^^^^
;;!          xxxxxx
;;!       ---------
;;!! {value: key for (key, value) in d1.items()}
;;!          ^^^
;;!        xxxxx
;;!   ----------
;;!! def func(value: str = ""):
;;!                        ^^
;;!                     xxxxx
;;!           ---------------
(
  (_
    (_) @_.leading.endOf
    .
    value: (_) @value
  ) @_.domain
  (#not-type? @_.domain subscript)
)

;;!! return 1
;;!         ^
;;!        xx
;;!  --------
;;
;; NOTE: in tree-sitter, both "return" and the "1" are children of `return_statement`
;; but "return" is anonymous whereas "1" is named node, so no need to exclude explicitly
(return_statement
  (_) @value
) @_.domain

;;!! yield 1
;;!        ^
;;!       xx
;;!  -------
;;
;; NOTE: in tree-sitter, both "yield" and the "1" are children of `yield` but
;; "yield" is anonymous whereas "1" is named node, so no need to exclude
;; explicitly
(yield
  (_) @value
) @_.domain

;;!! with aaa:
;;!       ^^^
;;!  --------
(
  (with_statement
    (with_clause
      (with_item)? @_.leading.endOf
      .
      (with_item
        value: (_) @value @name
      )
      .
      (with_item)? @_.trailing.startOf
    )
  ) @_.domain
  (#not-type? @value "as_pattern")
  (#allow-multiple! @value)
  (#allow-multiple! @name)
)

;;!! with aaa:
;;!       ^^^
;;!  --------
(
  (with_statement
    (with_clause
      (with_item)? @_.leading.endOf
      .
      (with_item
        value: (_) @value @name
      )
      .
      (with_item)? @_.trailing.startOf
    ) @_with_clause
  )
  (#not-type? @value "as_pattern")
  (#has-multiple-children-of-type? @_with_clause "with_item")
  (#allow-multiple! @value)
  (#allow-multiple! @name)
)

;;!! with aaa as bbb:
;;!       ^^^        <~~ value
;;!              ^^^ <~~ name
;;!  ----------------
(
  (with_statement
    (with_clause
      (with_item
        value: (as_pattern
          (_) @value @name.leading.endOf
          alias: (_) @name @value.trailing.startOf
        )
      )
    )
  ) @_.domain
  (#allow-multiple! @value)
  (#allow-multiple! @name)
)

;;!! with aaa as ccc, bbb:
;;!       ^^^         ^^^
;;!       ----------  ---
(
  (with_statement
    (with_clause
      (with_item
        value: (as_pattern
          (_) @value @name.leading.endOf
          alias: (_) @name @value.trailing.startOf
        )
      ) @_.domain
    ) @_with_clause
  )
  (#has-multiple-children-of-type? @_with_clause "with_item")
  (#allow-multiple! @value)
  (#allow-multiple! @name)
)

(
  (with_statement
    (with_clause) @value.iteration @name.iteration
  ) @value.iteration.domain @name.iteration.domain
)

;;!! lambda str: len(str) > 0
;;!              ^^^^^^^^^^^^
;;!  ------------------------
(lambda
  body: (_) @value
) @_.domain

;; value:
;;!! for aaa in bbb:
;;!             ^^^
;;!  ---------------
;; name:
;;!! for aaa in bbb:
;;!      ^^^
;;!  ---------------
(for_statement
  left: (_) @name
  right: (_) @value
) @_.domain

(comment) @comment @textFragment

(string
  (string_start) @textFragment.start.endOf
  (string_end) @textFragment.end.startOf
) @string

[
  (dictionary)
  (dictionary_comprehension)
] @map

[
  (list)
  (list_comprehension)
  (set)
] @list

(
  (function_definition
    name: (_) @functionName
    body: (_) @namedFunction.interior
  ) @namedFunction @functionName.domain
  (#not-parent-type? @namedFunction decorated_definition)
)
(decorated_definition
  (function_definition
    name: (_) @functionName
    body: (_) @namedFunction.interior
  )
) @namedFunction @functionName.domain

(
  (class_definition
    name: (_) @className
    body: (_) @class.interior
  ) @class @className.domain
  (#not-parent-type? @class decorated_definition)
)
(decorated_definition
  (class_definition
    name: (_) @className
    body: (_) @class.interior
  )
) @class @className.domain

(module) @className.iteration @class.iteration
(module) @statement.iteration

;; This is a hack to handle the case where the entire document is a `with` statement
(
  (module
    (_) @_statement
  ) @value.iteration @name.iteration
  (#not-type? @_statement "with_statement")
)

(module) @namedFunction.iteration @functionName.iteration
(class_definition) @namedFunction.iteration @functionName.iteration

;;!! def foo():
;;!!     a = 0
;;!     <*****
;;!!     b = 1
;;!      *****
;;!!     c = 2
;;!      *****>
(block) @statement.iteration @value.iteration @name.iteration
(block) @type.iteration

;;!! {"a": 1, "b": 2, "c": 3}
;;!   **********************
(dictionary
  "{" @value.iteration.start.endOf
  "}" @value.iteration.end.startOf
)

;;!! def func(a=0, b=1):
;;!           ********
(parameters
  "(" @value.iteration.start.endOf @name.iteration.start.endOf @type.iteration.start.endOf
  ")" @value.iteration.end.startOf @name.iteration.end.startOf @type.iteration.end.startOf
)

;;!! if true: pass
;;!  ^^^^^^^^^^^^^
(if_statement) @ifStatement

;;!! foo()
;;!  ^^^^^
(call) @functionCall

;;!! foo()
;;!  ^^^^^
(call
  function: (_) @functionCallee
) @_.domain

;;!! lambda _: pass
;;!  ^^^^^^^^^^^^^^
(lambda
  body: (_) @anonymousFunction.interior
) @anonymousFunction

;;!! match value:
;;!        ^^^^^
(match_statement
  subject: (_) @private.switchStatementSubject
) @_.domain

;;!! { "value": 0 }
;;!    ^^^^^^^
;;!    xxxxxxxxx
(pair
  key: (_) @collectionKey
  value: (_) @_.trailing.startOf
) @_.domain

;;!! if True:
;;!     ^^^^
;;!! elif True:
;;!       ^^^^
;;!! while True:
;;!        ^^^^
(_
  condition: (_) @condition
) @_.domain

;;!! case value:
;;!        ^^^^^
(case_clause
  (case_pattern) @condition.start
  guard: (_)? @condition.end
) @_.domain

;;!! case 0: pass
;;!  ^^^^^^^^^^^^
(case_clause) @branch

(match_statement) @branch.iteration @condition.iteration

;;!! 1 if True else 0
;;!       ^^^^
;;!  ----------------
(
  (conditional_expression
    "if"
    .
    (_) @condition
  ) @_.domain
)

;;!! 1 if True else 0
;;!  ^
(
  (conditional_expression
    (_) @branch
    .
    "if"
  )
)

;;!! 1 if True else 0
;;!                 ^
(
  (conditional_expression
    "else"
    .
    (_) @branch
  )
)

(conditional_expression) @branch.iteration

;;!! [aaa for aaa in bbb if ccc]
;;!! (aaa for aaa in bbb if ccc)
;;!! {aaa for aaa in bbb if ccc}
;;!                         ^^^
;;!                      xxxxxx
;;!  ---------------------------
;;!! {aaa: aaa for aaa in bbb if ccc}
;;!                              ^^^
;;!                           xxxxxx
;;!  --------------------------------
(_
  (if_clause
    "if"
    (_) @condition
  ) @_.removal
  (#not-parent-type? @_.removal case_clause)
) @_.domain

;;!! if True: pass
;;!  ^^^^^^^^^^^^^
(if_statement
  "if" @branch.start
  consequence: (_) @branch.end
)

;;!! elif True: pass
;;!  ^^^^^^^^^^^^^^^
(elif_clause) @branch

;;!! else: pass
;;!  ^^^^^^^^^^
(else_clause) @branch

(if_statement) @branch.iteration

;;!! try: pass
;;!  ^^^^^^^^^
(try_statement
  "try" @branch.start
  body: (_) @branch.end
)

;;!! except: pass
;;!  ^^^^^^^^^^^^
[
  (except_clause)
  (except_group_clause)
] @branch

;;!! finally: pass
;;!  ^^^^^^^^^^^^^
(finally_clause) @branch

(try_statement) @branch.iteration

;;!! while True: pass
;;!  ^^^^^^^^^^^^^^^^
(while_statement
  "while" @branch.start
  body: (_) @branch.end
)

(while_statement) @branch.iteration

;;!! for aaa in bbb: pass
;;!  ^^^^^^^^^^^^^^^^^^^^
(for_statement
  "for" @branch.start
  body: (_) @branch.end
)

(for_statement) @branch.iteration

;;!! import foo, bar
;;!         ^^^  ^^^
(
  (import_statement
    name: (_)? @_.leading.endOf
    .
    name: (_) @collectionItem
    .
    name: (_)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

;;!! from foo import bar, baz
;;!                  ^^^  ^^^
(
  (import_from_statement
    [
      name: (_)? @_.leading.endOf
      "import" @_.leading.endOf
    ]
    .
    name: (_) @collectionItem
    .
    name: (_)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

;;!! global foo, bar
;;!         ^^^  ^^^
(
  (global_statement
    (identifier)? @_.leading.endOf
    .
    (identifier) @collectionItem
    .
    (identifier)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

;;!! for key, value in map.items():
;;!      ^^^  ^^^^^
(
  (pattern_list
    (identifier)? @_.leading.endOf
    .
    (identifier) @collectionItem
    .
    (identifier)? @_.trailing.startOf
  )
  (#insertion-delimiter! @collectionItem ", ")
)

(import_statement
  .
  (_) @collectionItem.iteration.start.startOf
) @collectionItem.iteration.end.endOf @collectionItem.iteration.domain

(import_from_statement
  "import"
  .
  (_) @collectionItem.iteration.start.startOf
) @collectionItem.iteration.end.endOf @collectionItem.iteration.domain

(global_statement
  .
  (_) @collectionItem.iteration.start.startOf
) @collectionItem.iteration.end.endOf @collectionItem.iteration.domain

(pattern_list) @collectionItem.iteration

;;!! def foo(name) {}
;;!          ^^^^
(
  (parameters
    (_)? @_.leading.endOf
    .
    (_) @argumentOrParameter
    .
    (_)? @_.trailing.startOf
  ) @_dummy
  (#not-type? @argumentOrParameter "comment")
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
  (#not-type? @argumentOrParameter "comment")
  (#single-or-multi-line-delimiter! @argumentOrParameter @_dummy ", " ",\n")
)

;;!! " ".join(word for word in word_list)
;;!!          ^^^^^^^^^^^^^^^^^^^^^^^^^^
(call
  (generator_expression
    "(" @argumentOrParameter.start.endOf
    ")" @argumentOrParameter.end.startOf
  )
)

(_
  (parameters
    "(" @argumentOrParameter.iteration.start.endOf
    ")" @argumentOrParameter.iteration.end.startOf
  )
) @argumentOrParameter.iteration.domain

(argument_list
  "(" @argumentOrParameter.iteration.start.endOf @name.iteration.start.endOf @value.iteration.start.endOf
  ")" @argumentOrParameter.iteration.end.startOf @name.iteration.end.startOf @value.iteration.end.startOf
) @argumentOrParameter.iteration.domain @name.iteration.domain @value.iteration.domain

(call
  (generator_expression
    "(" @argumentOrParameter.iteration.start.endOf
    ")" @argumentOrParameter.iteration.end.startOf
  )
) @argumentOrParameter.iteration.domain

operators: [
  "<"
  "<="
  ">"
  ">="
] @disqualifyDelimiter
operator: [
  "<<"
  "<<="
  ">>"
  ">>="
] @disqualifyDelimiter
(function_definition
  "->" @disqualifyDelimiter
)

(
  (string_start) @pairDelimiter
  (#match? @pairDelimiter "^[a-zA-Z]+")
)
