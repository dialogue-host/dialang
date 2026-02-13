# ⛵️ Dialang

Dialang is a opinionated language for the masses to write malleable and reliable software.

Dialang is built in order to fulfill [Dialogue's programming language requirements](https://github.com/dialogue-host/requirements/?tab=readme-ov-file#programming-language-dialang).


## Dialang's promesses

✿ **No runtime error** : Type check your code statically and ensure you don't miss any edge case. (Statically type safe)
✿ **No broken state** : Constrain your datatypes to guarantee that they can't hold invalid or impossible data. (Refinement/liquid types)
✿ **The language is the framework** : The language makes every codebase follow the best practices making code browsable, testable and consistent. (locality of behavior, single source of truth, The Elm Architecture, ...)
✿ **Fearless refactoring** : Fast and friendly compiler messages guides you through your changes. (Elm quality error messaging and compiler optimization)
✿ **Run with holes** : Run incomplete programs and incrementally build your software by filling the blanks. (Hazel holes)
✿ **Controllable effects** : Have full visibility and control over the side effects produced by your programs and packages. (Unison's algebraic effects or Roc's managed effects)
✿ **Automated multithreading** : Write single threaded code that gets parallelized at compile time. (Interaction calculus target)
✿ **Code hot loading** : Safely swap pieces of code at runtime and maintain version compatibility. (Lamdera's evergreen, Elixir and Unison)
✿ **First class metaprogramming** : Enforce good practices with custom static checkers and context specific codegen.
✿ **Platform's abstraction** : Run your programs on every platform that can handle the proper side effects. (Roc's platform abstraction)
✿ **Code internationalization** : Edit and translate your codebase and packages in different spoken languages while guaranteeing syntactic validity and consistency. (Unison's structural naming + translation tables for code and documentation)
✿ **The State is the Database** : Stores the state in a manner that complies with database standards. (Lamdera)
✿ **Programmable documentation** : markdown, math notation, run code inline, interactive, referenced values
✿ **Observable** : run code remotely, time machine
✿ **Modable development environment**


# Design


### Code internationalization

**Why?**
- Remove linguistic barier to programming

**What?**
- Modular parser to handle structuraly different languages (LTR languages, and more)
- `Text` and `Greme` (standing for 'grapheme') core types handle UTF encoding by default and `Text` comes with an integrated translation library
- Translation table with possible automated translation for namings and documentation

**How?**
- Content addressed code that gets mapped to rows of the translation table
- Self hosted swappable parser function
- Integration of a translation tool

**See**
- [code in Arabic](https://youtu.be/Da1a7WYEaHE?si=5v0YDZN54o-DTbY5)


### Content addressed code

**Why?**
- Implement large scale distributed systems
- Have versioning over a distributed codebase
- Reference functions independently of the naming/terminology/spoken language used for internationalization purpose

**What?**
- Enable to share and reference the same code across devices
- Split terms from implementation to

**How?**
- Referencing types and functions by their hash combined with their name unique key

**See**
- [Unison's big idea](https://www.unison-lang.org/docs/the-big-idea/)


### Type as API Specification

**Why?**
- API specification and type serve the same purpose to describe valid input and output data, its structure but sometimes also its constraints (maximum 'String' length in a JSON)
- for the user
  - It provides context and guides the user
  - It can describe functions side effects (network access, file system, etc.) which gives guarantees to the user
- for the implementer
  - It ensures that the incoming data is valid and won't cause bugs or security issues
  - It describes outgoing data which can serve to check the validity of the implementation
  - As the update function's signature defines the state, it makes impossible states impossible

**What?**
- The syntax that describes our types has to be concise enough to be read by users and written by implementers
- It has to properly constrain the data (`String` could be a JSON, some markdown text, a piece of code, ... who knows?)
- It has to describe side effects the function can produce

**How?**
- [Algebraic datatypes](https://en.wikipedia.org/wiki/Algebraic_data_type) which enable us to compose data : *structures* group pieces of data (`Pos := (.x:Int, .y:Int)`) and *unions* provide different alternatives (`Side := [ #left | #right ]`)
- The `where` statement which constrains the data itself with a boolean check (`Percent := p:Float where 0 <= p <= 1`, `abs : Float -> out:Float where out >= 0`)
- Three approaches battle here : [managed effects](https://www.roc-lang.org/functional#managed-effects), [algebraic effects](https://antelang.org/blog/why_effects/) and give the effectful functions as update function's arguments which purity can be checked in the `where` statement (`f:{ a -> b } -> out where is_pure(f)`).

**See**
- [types without borders](https://www.youtube.com/watch?v=memIRXFSNkU)
- [communicating in types](https://www.youtube.com/watch?v=SOz66dcsuT8)
- [json is a terrible standard](https://youtu.be/HVl1GWhyx3E?si=fuBcjy2Yc2eWJXzm)


### Four layers static checking

**Why?**
- Accelerate feedback loop by catching issues as early as possible
- Compiler as an assistant that guides learning, regactoring and debugging
- The absence of runtime errors gives confidence on your own and other's code as soon as it compiles

**What?**
- Helpful error messages that explain the issue and guide/hints toward solutions and avoid overwhelming the user
- Static type checking (type and `where` pre conditions)
- Static property checking and testing (`expect`, `unreachable` and `where` post conditions)

**How?**
- Hilney-Milner type checker for base types
- SMT checker for automatically proving as many properties and .refinement types as possible
- Fuzz tester for properties and refinement types that can't be automatically proven
- Optional manual proofs to replace fuzz testing on critical systems
- Faster checks get run first to catch common issues faster (Hilney-Milner) and goes toward increasingly fine checks that might take more time (SMT and Fuzz). Those could get disabled temporarily while working on the code

**See**
- [Elm compiler as assistant](https://elm-lang.org/news/compilers-as-assistants)
- [introdiction to liquid types](https://youtu.be/C5PuBeiWaSA?si=ieeGG1uWPoqTZaD2)
- [liquidhaskell](https://liquid.kosmikus.org/)


## Legacy

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

### Capabilities and Commands

They are multiple reasons why side effects have to be controllable and explicit :

- They open vulnerabilities that can be exploited by libraries
- They make the transport of functions through network impractical

Capabilities are given to functions as the reserved `.cap` argument.

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


## Goals

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

- [ ] Document design
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
