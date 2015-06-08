/*:

# Intro to Swift for App Development

Swift is a full featured language with lots of nice capabilities, but it's not necessary to know everything about it to start writing some basic apps for the Mac Desktop.

The goal of this document is to walk through the basics of the language and showcase the things that you'll need to know to start writing apps.

## Output

As is traditional, we start by writing to STDOUT.  In GUI apps this is useful for light debugging.

*/

println("Hello World!")


/*:

## Data

There are two ways to store it: constants and variables.  Constants can be set once and are immutable (you can't change them).  Variables can be changed as much as you want.  Use constants whenever possible, as the compiler can optimize them more.

*/

let answer = 42
var donuts = "Yes"

/*:

## Types

Swift is a staticly typed language, meaning you need to declare a type for your data.  However most of the time Swift can infer the type based on what you assign to the variable.

In the examples above, the type of the first object is an Int and the second is a String.

In some situations you need to explicitly set the type, for example if you are not providing an initial value.  That is done with the following syntax.

*/

var x:Int
var y:String

/*:

## Collections

Printing the values of a constant or variable is easy.  No need to concat strings together.

*/

println("Answer to the Ultimate Question of Life, the Universe, and Everything is ... \(answer)")
println("Would you like donuts?  \(donuts), please")

/*:

Lists can be used to store collection of the same type of items.  You can bend this rule a bit by using Any or AnyObject, but you should only do that when you need to.  It's better to be specific.  [See docs for more](https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/TypeCasting.html).

*/

var myList = [1,2,3,4,5,6,7,8]
var myMixedList:[Any] = ["1", 2, ["a", "b", "c"], 3]

/*:

A dictionary or map can be used to store key/value pairs.  It has the same restriction as lists, the types must be the same unless you make use of Any / AnyObject.

*/

var myDict = ["name": "Frank", "age": "43", "weight": "106"]
var myMixedDict:[String:Any] = ["name": "Frank", "age": 43, "weight": 106]

/*:

Printing values from a list works like you'd expect.  Printing values from a dictionary requires an intermediate variable.

*/

println("Some value = \(myList[2])")

var age = myDict["age"]
println("Some value = \(age)")

/*:

## Control Flow

Swift offers several looping and conditional statements that allow you to easily control the flow of your code.  Not going to cover all of them here.  This doc just aims to show how you'd accomplish some common tasks.  For a complete reference, [see the docs](https://developer.apple.com/library/mac/documentation/Swift/Conceptual/Swift_Programming_Language/ControlFlow.html#//apple_ref/doc/uid/TP40014097-CH9-ID120).

### Loops

There's two options for looping through the elements of a list.  The first option is `for..in` and the second is the traditional C style for loop.

*/

for v in myList {
    println(v)
}

for (i, v) in enumerate(myList) {
    println("\(i).) \(v)")
}

for var i = 1; i <= myList.count; ++i {
    println("\(i).) \(myList[i-1])")
}

/*:

Looping through a dictionary can be done easily with a `for..in` loop.  While possible with a traditional C style loop, it's not nearly as elegant.

*/

for (k, v) in myDict {
    println("\(k) == \(v)")
}

/*:

Iterating over some code a certain number of times is also straightforward.  You can do it with a C style loop or with `for..in` and a sequence.

*/

for var i = 0; i < 10; i++ {
    print("\(i) ")
}

for i in 0...9 {
    print("\(i) ")
}

for i in 0..<10 {
    print("\(i) ")
}

/*:

### Conditionals

Conditionals are similar to other languages.  Swift also supports a switch statement, if that's something you'd like to use.

*/

if answer != 42 {
    println("WRONG!!")
} else {
    println("RIGHT!!")
}

/*:

The conditional in an if statement must be a boolean.  You cannot do `if found { ... }`.  There's no implicit comparison to 0 or nil.  It's just an error.  This leads us to optionals.

### Optionals

Defining an optional.  The ? after means it may have a value or may be nil.  Check out what happens when you change `maybeAValue` to nil.

*/

let maybeAValue:String? = "George Washington"


/*:

Some common things to do with an optional:

  - check if it's nil
  - print it
  - get the value (done with the trailing `!`)

*/

println("is nil? \(maybeAValue == nil)")
println("contents of value: \(maybeAValue)")
println("get the value: \(maybeAValue!)")

/*:

You can also use the `if..let` syntax to make working with them easier.  The example below roughly reads "if maybeAValue has a value then set name to its value and run this block of code".  If it's nil, just skip the whole block.

*/

if let name = maybeAValue {
    println("Yay! We have a name: \(name)")
}

/*:

It's roughly the same as checking it against nil and using the exclamation mark to unwrap the actual value.

*/

if maybeAValue != nil {
    println("Yay! We have a name: \(maybeAValue!)")
}

/*:

## Functions & Closures

We also need to know how to define functions and the similar closure.  These will be useful as we build apps because we can use them to define and attach behaviors to our GUI.  i.e. make it do stuff.

### Functions

This is how you define a function.  Each function has a name, which is how you refer to it later.  It can be given zero or more parameters and it can return zero or more values.  This is not all, there's lots more you can do with functions like named parameters, default values, etc..  [See the docs](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html#//apple_ref/doc/uid/TP40014097-CH10-ID158) for more on that.

*/

func greet(name: String, greeting: String) -> String {
    return "\(greeting) \(name)"
}

/*:

Calling functions works like you'd expect if you programmed in other languages.  You call the name and pass in the arguments.

*/

greet("Dan", "Hello")

/*:

You can also pass functions around as objects.  This includes assigning them to variables and constants, passing them into functions and returning them from functions.  When passing into or out of a function, any functions that match the signature can be intermixed freely.

*/

var greet_other: (String, String) -> String = greet
greet_other("Dan", "Bye")

func reverse_greeting(name: String, greeting: String) -> String {
    return "\(name) \(greeting)"
}

reverse_greeting("Dan", "Hello")

greet_other = reverse_greeting
greet_other("Dan", "Bye")

/*:

### Closures

Closures are similar to functions, but don't have a name and offer some syntax simplifications when passing them into functions.

Here we do a comparison of a factorial function and closure.  Both do the same thing, there is no difference other than the minor change in syntax.

*/

func fact(i:Int) -> Int {
    return (i == 0) ? 1 : (i * fact(i - 1))
}
fact(5)
fact(8)

let factorial: (Int) -> Int
factorial = { i -> Int in
    return (i == 0) ? 1 : (i * factorial(i - 1))
}
factorial(5)
factorial(8)

/*:

Where closures are helpful is when passing them into functions.  The examples below show the difference between passing a function or a closure.

**Function**

*/

func double(i:Int) -> Int {
    return i * i
}
[1,2,3,4,5,6].map(double)

//: **Closure**

[1,2,3,4,5,6].map { i -> Int in
    i * i
}

/*:

That's about it.  At this point, you should have a good handle on the basics that are necessary to start writing apps in Swift.

Feel free to play around with the demos here more or try out [Apple's Swift Tour Playground](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/GuidedTour.html#//apple_ref/doc/uid/TP40014097-CH2-ID1).
*/
