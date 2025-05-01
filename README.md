# Dialang

Dialang is a fast, friendly, reliable, safe, maintainable, multilingual, purely functional programming language that runs anywhere, treats functions as values and has first class meta-programming. It aims to fulfill [Dialogue's programming language requirements][1].

## Design Principles

Some general design principles guiding Dialang.

### Minimal Concept and Programming Techniques Count

We want to keep track of our concept and programming techniques count to make Dialang easily learnable, avoid confusion and reduce complexity. We want to combine overlapping concepts into single ones whenever possible and avoid the multiplication of ways to code the same behavior.

### Maximize Expressiveness

We want to encourage users to write code that is self descriptive, easy to understand and organized in a manner that is consistent with any other Dialang codebase. The aim here is not to be overly restrictive to the programmer but nudge their style towards more expressive code.

A concrete example of this principle is the restricted set of binary operators: Some operators - such as `+`, `*`, `==`, `>=`, `|>`, etc. - are essential and make code much cleaner than using their corresponding function calls. Those that have clear behavior are handled by default, but we do not let programmers implement their own binops as they could implement things like `|.` or `|*` for which the expected behavior is much less obvious.

### Minimize Potential for Errors

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

Static access to ast and run code at static time (ex: ast visitor/modifier, inline rule calls and codegen).

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
