# Overview

## Concept

Objective-C is a strict superset of C, which means that valid C code is also valid Objective-C code and can be mixed and matched freely.

You can use C++ with Objective-C, which usually has the moniker Objective-C++, but this is less common.

### Header Files

Newly created Objective-C class is made up of Class.h (a **header file**) and Class.m (the **implementation file**). The “m” originally stood for “messages”, but most people today consider it the “iMplementation” file.

The header file describes what the class exposes to the outside world: properties that can be accessed and methods that can be called.

The implementation file is where the actual code for those methods is written.

This split between H and M doesn’t exist in Swift, where an entire class or struct is created inside a single file. But in Objective-C it’s important: when you want to use another class, the compiler only needs to read the H file to understand how the class can be used.

This lets you draw on closed-source components such as Google’s analytics library: they give you the H file that describes how their components work, and a “.a” file that contains their compiled source code.

### C preprocessor

The preprocessor is a compilation phase that takes place before the Objective-C code is built, which allows it to rewrite your source code before it’s compiled.

This doesn’t exist in Swift, and with good reason: the main reasons for using it are header files (which Swift doesn’t have) and creating macros, which are code definitions that get replaced when your source code is built.

For example, rather than writing 3.14159265359 repeatedly, you can create a macro called PI and give it that value.

### Easy differences

Swift is a much more advanced language than Objective-C, and as such has some features that simply do not exist in Objective-C.

Objective-C does not support the following:

* Type inference.
* Operator overloading.
* Protocol extensions.
* String interpolation.
* Namespaces.
* Tuples.
* Optionals.
* Playgrounds.
* guard and defer.
* Closed and half-open ranges.
* Enums with associated values.

Objective-C shares most operators with Swift, although it has retained the ++ and -- operators that were deprecated in Swift 2.2. The nil coalescing operator is written as ?: rather than ??.

### How things are named

Early versions of Swift – 1.0 to 2.2 – used almost identical naming conventions for methods and properties as Objective-C did. In Swift 3.0, Apple introduced the Great Cocoa Renamification, which involved renaming almost every method and property to be “more Swifty”, which caused pretty much every existing project to break until it was upgraded to use the new naming conventions.

If you are using a method that has a completion closure, it’s required in Objective-C even when it’s nil.

Here are some examples in Swift and Objective-C,  notice how Objective-C adds lots of extra words into its method names so they are unmistakably clear:

~~~
// find the index of an item in an array
names.firstIndex(of: "Taylor")
[names indexOfObject: @"Taylor"];

// get the current UIDevice
UIDevice.current
[UIDevice currentDevice];

// replace a string
"Hello, world".replacingOccurrences(of: "Hello", with:
"Goodbye")
[@"Hello, world" stringByReplacingOccurrencesOfString:@"Hello"
withString:@"Goodbye"];

// dismiss a view controller
dismiss(animated: true)
[self dismissViewControllerAnimated:true completion:nil];
~~~

### Namespaces

A namespace is a way to group functionality together in discrete, re-usable chunks. When you namespace your code, it ensures the names you use for your classes don’t overlap the names other people have used because you have additional context.

For example, you could create a class called Person and not have to worry about Apple creating another class called Person, because the two wouldn’t conflict. Swift automatically namespaces your code, so that your classes are automatically wrapped inside your module – something like YourApp.YourClass.

Objective-C has no concept of namespaces, which means it requires that all class names be globally unique. This is easier said than done: if you use five libraries, those library might each use three other libraries, and each library might define lots of class names. It’s possible that library A and library B might both include library C – and potentially even different versions of it.

This creates a lot of problems, and Apple’s solution is simple and pervasive: use two-, three-, or four-letter prefixes to make each class name unique. 

Think about it: UITableView, SKSpriteNode, MKMapView, XCTestCase – you’ve been using this prefix approach all along, perhaps without even realizing it was designed to solve an Objective-C shortcoming.

### No optionals

This caused all sorts of issues when Swift was first announced: all the Objective-C APIs had to be imported into Swift, and that meant trying to decide whether a UIView was actually a UIView? – was the view definitely there, or could it actually be nil?

In Swift this distinction really matters: if you try to use a value that is actually nil, your app crashes. But in Objective-C, working with nil values is perfectly OK: you can send a message to a nil object, and nothing happens.

### Safety

Living without optionals and being able to message nil objects should give you some hints that Objective-C is less safe than Swift.

However, the truth is that this lack of safety goes much deeper: 

* Objective-C lets you force one data type into another.
* It only recently introduced the concept of generics (e.g. arrays that can hold only strings).
* It has none of the advanced string functionality that lets Swift mix ASCII and emoji with ease.
* It lets you read array values that don’t exist.
* The switch blocks don’t need to be exhaustive.
* It makes almost everything a variable rather than a constant.
* And much more...

There is one small thing you can do to help make Objective-C a little bit less dangerous: whenever you create an Objective-C project, go to the Build Settings tab in Xcode and set “Treat Warnings as Errors” to Yes. That one change will stop you from making some terrible mistakes with the language, for example trying to squeeze a number into a string.

## Basic Syntax

The best way to experiment with these is to create a new project in Xcode: go to File > New Project, then choose macOS > Application from the left-hand side, and Command Line Tool.

### Template

When you create a project from this template, you’ll be given only one file: main.m.

~~~
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
    }
    return 0;
}
~~~

The @ symbol means is “this next bit is Objective-C, and definitely not C”. Without the @ sign before “Hello, World!” that message would be interpreted as a C string: an array of characters in ASCII, ending with a 0.

NSLog() is a function akin to print() in Swift, NSLog() expects to receive one of these Objective-C strings, which is why the @ is required.

The @autoreleasepool means “I’m going to be allocating lots of memory; when I’m finished, please free it up.”

Explanation about the C Code:

~~~
int main(int argc, const char * argv[])
~~~

int : This function returns an integer.

main() : The function is named main.

int argc : The first parameter is an integer called argc.

const char * argv[] : The second parameter is an array of strings called argv.

This main() function, with those parameters, is the standard way to create command-line programs, and it will automatically be called when the program is run.

In Objective-C every statement must end with a semi-colon.

### Importing Headers

~~~
#import <Foundation/Foundation.h>
~~~

This line is a preprocessor directive. It means this code gets replaced by the preprocessor even before your code gets built. Any line of code that begins with # is a preprocessor directive.

This particular directive means “find the header file for Foundation (Apple’s fundamental Objective-C framework), and paste it here.” The preprocessor literally takes the contents of Foundation.h – a header file that itself imports many other headers – and copies it in place of that #import line.

When you #import a system library, you place the library’s name in angle brackets. For example, #import <UIKit/UIKit.h>. 

However, when you import your own header files, you use double quotes, like this: #import "MyClass.h". This distinction is important: using angle brackets means “search for this header in the system libraries,” and using double quotes means “search for this header in the system libraries, but also in my project.”

### Creating Variables

Objective-C does not support type inference, and, unlike Swift, almost everything is created as a variable.

~~~
int i = 10
~~~

That creates a new integer and assigns it the value 10. Notice there’s no let or var in there – these things are variable by default.

If you want to make it a constant, you should use this instead:

~~~
const int i = 10
~~~

To create a string, you need to use the NSString class. Yes, it’s a class rather than a struct; yes, the “NS” is another namespace prefix; and yes, you need to use the @ symbol just like before.

~~~
NSString str = @"Reject common sense to make the impossible possible!";
~~~

But this code will trigger an error, specifically: **Interface type cannot be statically allocated**, which means that any kind of object, like NSString, must be allocated using a special approach called pointers.

Pointer is a reference to a location in memory where some specific data lives. 

If you imagine a photo that took up 30MB of RAM, you wouldn’t want to copy all that data around each time you used the photo. Instead, you can pass around a pointer that specifies where in RAM the 30MB is, and that’s good enough.

In Objective-C, all objects must be pointers, and NSStrings are objects. So, we need to write this instead:

~~~
NSString *str = @"Reject common sense to make the impossible possible!";
~~~

Note the asterisk, which is what marks the pointer. So, str isn’t an NSString, it’s just a pointer to where an NSString exists in RAM.

Let’s briefly look at one more data type: arrays. These are called NSArray in Objective-C, and you need @ to start the array.

~~~
NSArray *array = @[@"Hello", @"World"];
~~~

### Conditions

Conditional statements mostly work the same as in Swift, although you must always type parentheses around your conditions. 

These parentheses, like the line-terminating semi-colons, are often accidentally missed off when you’re coming from Swift, but Xcode will refuse to compile until you fix it.

If the content of your conditional statement is just one statement, you can omit the braces. For example, these two pieces of code do exactly the same thing:

~~~
if (i == 10) {
    NSLog(@"Hello, World!");
} else {
   NSLog(@"Goodbye!");
}

if (i == 10)
   NSLog(@"Hello, World!");
else
   NSLog(@"Goodbye!");
~~~

If you desperately wish to avoid braces, at least write your if statement on a single line, like this:

~~~
if (i == 10) NSLog(@"Hello, World!");
~~~

### Switch/case

Case statements have implicit fallthrough.

This is the opposite of Swift, and means you nearly always want to write **break;** at the end of case blocks to avoid fallthrough.

~~~
int i = 20;
switch (i) {
   case 20:
      NSLog(@"It's 20!");
      break;
   case 40:
      NSLog(@"It's 40!");
      break;
   case 60:
      NSLog(@"It's 60!");
      break;
   default:
      NSLog(@"It's something else.");
}
~~~

If you run the code, “It’s 20!” will be printed.

But without **break;** it will caused an implicit fallthrough. Now the code will print: “It’s 20!” then “It’s 40!”, “It’s 60!” and “It’s something else.”

In Objective-C, not having **break;** is equivalent to adding fallthrough in Swift.

Objective-C does have support for pattern matching, but it’s limited to range: you write one number, then ... with a space on either side, then another number, like this:

~~~
switch (i) {
   case 1 ... 30:
      NSLog(@"It's between 1 and 30!");
      break;
   default:
      NSLog(@"It's something else.");
}
~~~

There’s a corner case in using switch/case: you can’t use the first line of a case block to declare a new variable unless you wrap the case block in braces.

~~~
switch (i) {
    case 10:
        int foo = 1;
        NSLog(@"It's something else.");
}
~~~

Objective-C doesn’t require that switch blocks be exhaustive, meaning that we don’t need a default case – that code would be perfectly valid, if it were not for the fact that a new variable is declared straight after the case.

There are two ways to fix this problem: either place braces around the contents of the case block, or simply make the NSLog() line come first.

~~~
switch (i) {
    case 10:
        {
            int foo = 1;
            NSLog(@"It's something else.");                
        }
    }
~~~

~~~
switch (i) {
    case 10:
        NSLog(@"It's something else.");
        int foo = 1;
}
~~~

### Loops

Objective-C has the full set of loop options, including the C-style for loop that was deprecated in Swift 2.2.

**Fast enumeration**

~~~
NSArray *names = @[@"Laura", @"Janet", @"Kim"];
for (NSString *name in names) {
   NSLog(@"Hello, %@", name);
}
~~~

NSLog() is a variadic function, and combines the string in its first parameter with the values of the second and subsequent parameters.

The **%@** part is called a format specifier, and means “insert the contents of an object here” – which in this case is the name variable.

**C-style for loops**

~~~
for (int i = 1; i <= 5; ++i) {
   NSLog(@"%d * %d is %d", i, i, i * i);
}
~~~

**%d** is another format specifier, and means “int”.

The first %d matches the first i, the second %d matches the second i, and the third %d matches the i * i.

You can use while just like in Swift, and do/while is identical to Swift’s repeat/while construct.

### Calling Methods

Consider the following Swift:

~~~
let myObject = new MyObject()
~~~

In Objective-C, several things change. First, new is a message you send to the MyObject class, like this:

~~~
MyObject *myObject = [MyObject new];
~~~

As you can see, you write an opening bracket, your object name, a space, then your message name, then a closing bracket.

>Note: although this is technically called “sending a message”, I’ll be referring to it as “calling a method” from now on because that’s what everyone except Apple calls it.

Where things get tricksy is when you want to call two methods at once. In Swift you might write something like this:

~~~
myObject.method1().method2()
~~~

In Objective-C, you need to balance the brackets on the outermost left-hand side, like this:

~~~
[[myObject method1] method2]
~~~

One particular place when you are likely to use two method calls on a single line is when creating objects. 

You’ve already seen the new method, which allocates memory for an object and initializes it with some default information. However, you can also run those two parts individually: allocate some memory with one method, then initialize a value with a second, like this:

~~~
MyObject *myObject = [[MyObject alloc] init];
~~~

The alloc is run first to set aside enough RAM to store the object, then init is run to place a default value into the object.

Objective-C method calls look similar to Swift’s, although brackets are used rather than parentheses, and you don’t use commas between parameters. The lack of commas means that it is stylistically preferred not to place a space after the colon for named parameters.

~~~
 myObject.executeMethod(hello, param2: world)
[myObject executeMethod:hello param2:world];
~~~

### Nil Coalescing

As with Swift, one useful way of ensuring a value exists is to use nil coalescing. Objective-C doesn’t have a dedicated ?? operator for this, but instead allows you to hijack the ternary operator, ?:.

For example, this will print a name or “Anonymous” depending on whether the name variable has a value:

~~~
NSString *name = nil;
NSLog(@"Hello, %@!", name ?: @"Anonymous");
~~~

## Pointers

A regular variable contains a value, for example a house object. A pointer contains a pointer to the location of the house, like a signpost – it’s much smaller than the real thing, and all it does it say “it’s over there.” 

Pointers allow objects to be passed around efficiently, because if you send the house object into a function all you’re doing is sending a number in, which is the location of the house in RAM.

To continue the house metaphor, imagine a white house that had three signposts pointing to it. If you repaint the house so it’s red, all three signposts are now pointing to the red house. You don’t have a situation where one is pointing to a new red house and the other two are pointing to the old one. 

The same is true with pointers: if you have three pointers that point to the same object in memory, and you change that object, that change happens to all the pointers.

All Objective-C objects must be pointers.

### Constant Pointers

Adding **const** to a variable will make it a constant.

~~~
const i = 10;
~~~

Yet this code works just fine:

~~~
const NSString *first = @"Hello";
first = @"World";

// or like this
NSString const *first = @"Hello";
first = @"World";
~~~

The reason for this is subtle but important: both of those lines mean “I want to ensure the string doesn’t change, but I don’t mind if the pointer does.” 

Remember, all objects are pointers, so this is equivalent to saying, “I don’t mind if you move your signpost to point somewhere else, as long as you don’t change my house.”

**NSString** is an immutable class, which means its value cannot be changed once it has been created. When you think you’re changing its value, what’s actually happening is that the old string is destroyed, a new one is created, and the pointer is updated to reflect the change.

We can demonstrate this by using the **%p** format specifier for NSLog(), which means “print the pointer of this object.” 

This is useful for debugging purposes, because it allows you to track the specific value of an object in memory. In our case, we can see the pointer address change as a new object is produced.

~~~
NSString *first = @"Hello";
NSLog(@"%p", first);
first = @"World";
NSLog(@"%p", first);
~~~

If we want to create a string that can’t be changed, what we need is a constant pointer.

The NSString itself is effectively already const because it’s immutable, so we now just need to make sure no one moves our signpost. To do this, you need to move the const keyword after the pointer’s asterisk, like this:

~~~
NSString * const first = @"Hello";
~~~

## The Size of Integers

On a 32-bit CPU, numbers were stored in binary using 32 1s and 0s and on a a 64-bit CPU numbers are stored in binary using 64 1s and 0s.

Apple’s solution for this problem is **NSInteger**: on 32-bit systems this holds a 32-bit number, and on 64-bit systems it holds a 64-bit number.

NSInteger is used extensively across iOS, macOS, tvOS and watchOS, which means you need to use it to avoid causing problems.

Consider, for example, if you saved an array of integers to iCloud, and a user accesses it from their 64-bit iPhone and also from their 32-bit iPad. If the iPhone wrote 64-bit integers, the iPad wouldn’t be able to read them correctly.

In this situation – where you need to work with both 64-bit and 32-bit devices – using NSInteger is the wrong choice. Instead, you should specify the exact size you need using int32_t or int64_t. That way, the integer size is preserved regardless of what CPU you’re running on.

This same problem (and the same solution) applies to floating-point numbers: like Swift, Objective-C has float and double types for holding single-precision and double-precision floating-point numbers, and CGFloat is designed to map to either float or double depending on the current CPU.

So, the short and simple version: you should be using NSInteger and CGFloat almost all the time, with exceptions being when you need to store data across platforms or when you have to work with an API that requires a specific size.

## BOOL

For historical reasons, Objective-C’s integers are written as int and its booleans are written as BOOL. Most primitive data types (integers, floats, etc) are written using all lowercase letters, but BOOL is an exception and used to be one of the quirky edges of the languages.

Objective-C’s quirkiness comes in two forms: first, you’ll find there are two data types for booleans, bool and BOOL; second, you’ll find that people usually write YES and NO in place of true and false, although both work.

Traditionally, C didn’t have a dedicated boolean data type, it just used the data type “signed char” instead, then called that BOOL.

A dedicated bool was introduced in a C language updated called C99, and as of 64-bit iOS the BOOL pseudo-type is just an alias for the bool data type.

You will find both in use. For example, Apple’s C frameworks like Core Graphics usually use bool, whereas its Objective-C frameworks like UIKit usually use BOOL.

The most important thing is to following whatever coding convention you find when you open someone else’s project. If you’re starting a project fresh and don’t have existing code to examine, go with BOOL, YES, and NO until you find a reason not to.

## Format Specifiers

You’ve already seen **%@** to mean “contents of object”, **%d** to mean “int”, and **%p** to print the pointer of an object, but there are others.

The most important remaining two are **%f** to print floating-point numbers and **%ld** to print long integers.

~~~
NSLog(@"%.2f", M_PI);
~~~

**%.2f** on above code means “print a floating-point number up to two decimal places.”

M_PI is a constant defined for you as a macro:

~~~
#define M_PI 3.14159265358979323846264338327950288
~~~

When the preprocessor sees M_PI it automatically replaces it with that long number.

Finally, **%ld** to print the value of long integers. I already explained that NSInteger varies in size depending on the CPU, which causes a problem: **%d** is for int, which will cause problems for 64-bit CPUs. The easiest solution is to use the **%ld** format specifier, then add a typecast to force the parameter to be a long integer, like this:

~~~
NSInteger i = 10;
NSLog(@"%ld", (long)i);
~~~