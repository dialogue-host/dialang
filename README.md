# ⛵️ Dialang

Dialang is a opinionated language for the masses to write malleable and reliable software.

✿ **No runtime error** : Type check your code statically and ensure you don't miss any edge case. (Statically type safe)
✿ **No broken state** : Constrain your datatypes to guarantee that they can't hold invalid or impossible data. (Refinement/liquid types)
✿ **The language is the framework** : The language makes every codebase follow the best practices making code browsable, testable and consistent. (locality of behavior, single source of truth, The Elm Architecture, ...)
✿ **Fearless refactoring** : Fast and friendly compiler messages guides you through your changes. (Elm quality error messaging and compiler optimization)
✿ **Run with holes** : Run incomplete programs and incrementally build your software by filling the blanks. (Hazel holes)
✿ **Controllable effects** : Have full visibility and control over the side effects produced by your programs and packages. (Unison's algebraic effects)
✿ **Automated multithreading** : Write single threaded code that gets parallelized at compile time. (Interaction calculus target)
✿ **Code hot loading** : Safely swap pieces of code at runtime and maintain version compatibility. (Lamdera's evergreen and Elixir)
✿ **First class metaprogramming** : Enforce good practices with custom static checkers and context specific codegen.
✿ **Platform's abstraction** : Run your programs on every platform that can handle the proper side effects. (Roc's platform abstraction)
✿ **Code internationalization** : Edit and translate your codebase and packages in different spoken languages while guaranteeing syntactic validity and consistency. (Unison's structural naming + code and documentation translation tables)
✿ **The State is the Database** : Stores the state in a manner that complies with database standards. (Lamdera)
✿ **Programmable documentation** : markdown, math notation, run code inline, interactive, referenced values
✿ **Observable** : run code remotely,
✿ **Modable development environment**

Dialang is built in order to fulfill [Dialogue's programming language requirements][1].

ease of learning :
- international
- conseptually minimal
- single language codebasse (no external db or escape hatch)
- fuse code, documentation and learning resource
- run with holes
maintainable :
- legible and explicit code (no magic nor implicit side effects)
- reliably catch errors as early as possible (three layer type checking)
- simple code is fast (automated multithreading)
- time machine
portable


## Todo

- [ ] Grammar EBNF
- [ ] Tree walk interpreter
  - [ ] Lexer
  - [ ] Parser
  - [ ] Basic Types Checker
  - [ ] Tree Walk Interpreter
  - [ ] Refinement Types Checker (SMT integration)
  - [ ] Nice Error Messaging
- [ ] Self Hosted Compiler
  - [ ] Multilingual Lexer and Parser Interface
  - [ ] Structural Naming and Translation Tables
  - [ ] Basic Types Checker
  - [ ] Refinement Types Checker (SMT integration)
  - [ ] Multilingual Pretty Printer
  - [ ] Nice Multilingual Error Messaging
  - [ ] Static AST Access
  - [ ] Versioning and Collaboration
  - [ ] Interaction Calculus Code Gen
  - [ ] Repl
- [ ] Interaction Calculus Target
  - [ ] Secure Extension Hot Swapping

---

# Design

There are three main design goals for Dialang:

✿ To be **easy to learn** by non technical people
✿ To put **collaboration and maintainability** front and center
✿ To **handle Dialogue's technical needs**

## Easy to Learn

### Code Internationalization

The first barier to learning programming is the spoken language barier. Most programming languages are built around english but neglect non english speakers. Children have to first learn english before they can write their first line of code. This is a huge barier to entry.

Two technical blocks are needed for this to happen:
✿ The syntax and its keywords have to be adaptable to suit different spoken languages.
✿ Libraries, their code and documentation have to be manually and/or automatically translatable.

### Three Layered Type and Property Checking

### State as Database

## Collaboration and Maintainability

### Function Capabilities

## Handle Dialogue's Technical Needs

### Structural Naming

### Platform's Abstraction

### Placeholder

In Elm you can pipe a value into a function which becomes impossible or weird as the arguments are parenthesized. Another issue is that the piped argument is always the last one which sometimes does not work out. The placeholder solves both these issues with a fairly clean notation.


### Mutations

A common issue I find with Elm is that to update a value you have to unpack its data, operate on it, and finally repack it. The advanced pattern matching helps a lot with the unpacking part but mutations can combine unpacking and repacking into a single compact expression.

```
update_name
  = { data ->
        ~data.name =|> do_something
        data
    }
```
instead of
```
update_name
  = { data ->
        new_name = do_something(data.name)
        (.name=new_name, ..data\_)
    }
```

At the same time this notation increases dramatically the variety of ways a given library can be design even though we would prefer to go with code consistency.


# Legacy Text

## Design Principles

Some general design principles guiding Dialang.

"make it easy to do the right things and annoying if not impossible to do the wrong things"

### Minimal Concept and Programming Techniques Count

We want to keep track of our concept and programming techniques count to make Dialang easily learnable, avoid confusion and reduce complexity. We want to combine overlapping concepts into single ones whenever possible and avoid the multiplication of ways to code the same behavior.

### Maximize Expressiveness

We want to encourage users to write code that is self descriptive, easy to understand and organized in a manner that is consistent with any other Dialang codebase. The aim here is not to be overly restrictive to the programmer but nudge their style towards more expressive code.

A concrete example of this principle is the restricted set of binary operators: Some operators - such as `+`, `*`, `==`, `>=`, `|>`, etc. - are essential and make code much cleaner than using their corresponding function calls. Those that have clear behavior are handled by default, but we do not let programmers implement their own binops as they could implement things like `|.` or `|*` for which the expected behavior is much less obvious.

### Minimize Footguns

### Minimize Implicits

### Single Source of Truth

### Locality of Behavior

See these [htmx](https://htmx.org/essays/locality-of-behaviour/) and [dev](https://dev.to/ralphcone/new-hot-trend-locality-of-behavior-1g9k) articles.

### Simplify the Mental Model

Methods and Circular Imports.
Object oriented programming, while it has its issues, brought a clear mental model that connects functions to
Help with having a clear mental model of the codebase and handle complexity. This is achieved by enforcing ways of organizing and naming symbols.

## Features

### Methods

Attaching methods to data improves the mental model by encouraging programmers to write their functions close to the data types they affect.

### Managed Effects

The permissions system is designed to ensure that code can only access resources and data it is authorized to. This includes access to files, network resources, and other system resources. This feature is essential to be able to sandbox pieces of code like packages or extensions and ensure security.

### Platform Abstraction

### Variable Reading and Writing Transparency

### Complete Static Type Inference

### Structural Typing

### Complete Memory and Type Safety

Buffer Overflows, Null Pointer Dereferencing, Dangling Pointers, Memory Leaks. All of these are impossible to do in Dialang.

### Meta Programming

Static access to AST and run code at static time (ex: AST visitor/modifier, inline rule calls and codegen).

### Self Hosted Compiler and Modular Lexer/Parser

### Multilingual

The AST is the codebase single source of truth and the code itself is the stringified version of the AST. Code translation can be achieved by having different parsing and stringify functions.

### Functions as Values

Comparable functions, etc.

### Code Hot Swapping

### Error Messages as an Assistant

### Evergreen Versioning

### Rich Pattern Matching

### Extensible Unions, Records and Tuples Types

### Error Passing

Languages usually handle errors in two ways: Either they consider them as any other type (`Result` in Elm or Roc) or they throw errors and use `try ... catch` blocks to handle them. The first approach has the benefits keeping the possible errors explicit through the type system. Where as the second approach

### Space Invariant

Languages that make use of the indentation in their grammar usually cause issues with copy pasted code that has to be properly aligned

### Packages fused with IDE Extensions

## Legacy

As dialang aims to be simple and maintainable we want to ensure data locality.

Pointers removes the locality of data and can lead to complex and hard-to-debug issues.

Functional languages reduce complexity by making our code behave less like distributed systems.

Dialang is built around its rich syntax tree (RST). The rest of the language, from its concrete syntax to its compilation target, is modular and can be adapted to each user's needs and preferences. This is done by having interchangeable compiler pieces: Parse (converts code to its RST), Print (turns the RST back to code), Walk (traverse the RST, gather data about it, enforce rules and make automated modifications), Target (turns the RST into a compilation target like C code or ASM).

[1]: https://github.com/dialogue-host/requirements/?tab=readme-ov-file#programming-language
