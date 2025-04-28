# Dialang

Dialang aims to become a fast, friendly, reliable, safe, maintainable, multilingual, purely functional programming language that runs anywhere, treats functions as values and has first class meta-programming. We build it in order to fulfill [Dialogue's programming language requirements][1].

## Design Principles

### Minimal Concept Count

### Single Source of Truth

### Locality of Behavior

See these [htmx](https://htmx.org/essays/locality-of-behaviour/) and [dev](https://dev.to/ralphcone/new-hot-trend-locality-of-behavior-1g9k) articles.

### Simple Mental Model

Object oriented programming, while it has its issues, brought a clear mental model that connects functions to
Help with having a clear mental model of the codebase and handle complexity. This is achieved by enforcing ways of organizing and naming symbols.

## Features

### Methods

Attaching methods to data improves the mental model by encouraging programmers to write their functions close to the data types they affect.

### Managed Effects

### Code Permissions

The permissions system is designed to ensure that code can only access resources and data it is authorized to. This includes access to files, network resources, and other system resources. This feature is essential to be able to sandbox pieces of code like packages or extensions and ensure security.

### Variable Reading and Writing Transparency

### Complete Static Type Inference

### Structural Typing

### Complete Memory and Type Safety

Buffer Overflows, Null Pointer Dereferencing, Dangling Pointers, Memory Leaks. All of these are impossible to do in Dialang.

### Meta Programming

Static access to ast and run code at static time (ex: ast visitor/modifier).

### Translatable

### Functions as Values

Comparable functions, etc.

### Code Hot Swapping

### Error Messages as an Assistant




## Legacy


As dialang aims to be simple and maintainable we want to ensure data locality.

Pointers removes the locality of data and can lead to complex and hard-to-debug issues.


Functional languages reduce complexity by making our code behave less like distributed systems.

Dialang is built around its rich syntax tree (RST). The rest of the language, from its concrete syntax to its compilation target, is modular and can be adapted to each user's needs and preferences. This is done by having interchangeable compiler pieces: Parse (converts code to its RST), Print (turns the RST back to code), Walk (traverse the RST, gather data about it, enforce rules and make automated modifications), Target (turns the RST into a compilation target like C code or ASM).

[1]: https://github.com/dialogue-host/requirements/?tab=readme-ov-file#programming-language
