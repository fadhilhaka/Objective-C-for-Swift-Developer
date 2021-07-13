# Preprocessor

## Inside the Preprocessor

Objective-C apps are built across multiple phases, of which the first is the preprocessor.

In some respects, the preprocessor is a bit like a global search and replace for your code: “when you see X, replace it with Y.”

Macros are generally declared in header files so that they can be used in any file where that macro is included. Be careful, though: you might find your macro spreads further than you had intended if one header file includes another that includes another... and so on.

You can declare your macros anywhere you want, including in the middle of a method. It's recommended putting them near the top of header files if they are shared, or near the top of implementation files if they are used only in one place.

>NOTE: Swift has no concept of a preprocessor, which is a conscious decision from the development team. This is because extensive use of macros makes your code hard to debug: if X has been replaced by Y, and Y was 10 lines of code, how can you know which line number caused a problem?

## Defining Object-like Macros

A “macro” is a named code fragment that is replaced by the preprocessor when your code is built.

They appear in two forms, of which the most basic are object-like macros.

Despite their name, they aren’t “objects” in the sense of Objective-C objects. Instead, they are just pieces of text that get replaced before your code is built.

>NOTE: All macros are replaced by the preprocessor before your code builds. This means sometimes you will see Objective-C code that looks unusual or perhaps even invalid, but it might still compile fine once the macros have been replaced. Similarly, you might see Objective-C code that looks fine but doesn’t compile.

To create a new macro, use **#define**, then the name of your macro, then the contents of your macro. This is commonly used to define constant values.

~~~
// example here is the definition of Pi from math.h
#define M_PI 3.14159265358979323846264338327950288
~~~

That means you can use M_PI in your code, and have it automatically replaced with 3.14159265358979323846264338327950288. It’s not a function call, or even a variable – that number literally gets written into your Objective-C code wherever **M_PI** was, so it’s extremely efficient. 

It is convention to write macros in **uppercase**.

You might wonder why this is preferable over defining a constant, and to be honest it usually isn’t. You could define Pi like this:

~~~
static const double kPi = 3.14159265358979323846264338327950288;
~~~

In the same way that it’s conventional to write macros in uppercase, there is a **loose convention** that **constants** should be **prefixed** with a **k** then use **camel case**. Apple uses this in most of its own code, e.g. **kCGBlendModeNormal**, but usage varies elsewhere.

A constant like kPi can be compiled directly into the source code just like the macro, so there ought to be no difference in performance. 

However, constants are part of your Objective-C code and so can be debugged more easily, whereas macros are placed into the code during compilation, so you can’t easily inspect their values.

Object-like macros tend to get confusing when they do more than replace simple values. 

The preprocessor doesn’t care what names you use or what replacements you want, so you can replace whole chunks of code if you want to.

~~~
#define TAYLOR [[Person alloc] initWithName:@"Taylor"];
Person *person1 = TAYLOR
Person *person2 = TAYLOR
Person *person3 = TAYLOR
~~~

As pure Objective-C, that code is syntactically invalid – the lines don’t even end with semi- colons. Worse, it’s semantically confusing: do all three Person objects end up pointing to the same object, or to new objects?

After the preprocessor runs that evaluates to the following:

~~~
Person *person1 = [[Person alloc] initWithName:@"Taylor"];
Person *person2 = [[Person alloc] initWithName:@"Taylor"];
Person *person3 = [[Person alloc] initWithName:@"Taylor"];
~~~

So, by the end it all works, but I’d definitely say this is a case of the end not justifying the means.

If you decide you no longer want a macro you defined, use this to remove it:

~~~
#undef M_PI
~~~

### Conditional compilation

Where macros are genuinely useful is handling conditional compilation. Because the preprocessor adjusts your code before it’s touched by the compiler, it can enable or disable code based on the values of object-like macros.

For example, I once distributed an app that could run either on iPads or on the iOS Simulator. When it ran on the simulator, you got a huge range of editing and debug options to help you create content, but when it ran on devices it just played back some content.

Conditional compilation allowed me to remove all the editing and debug code from the device version: it wasn’t just disabled, it was like it never existed.

This same approach is how assert() works in Objective-C: it’s a macro that only runs its checking code if you build your code in debug mode.

Conditional compilation is controlled by a number of compiler directives, most commonly **#ifdef**, **#if**, **#else**, and **#endif**.

**#ifdef** and **#endif** are the easiest place to start: they include some code in the output only if a macro is defined.

For example, below I create a macro called **PRINT_JAMES**, and only create and print an object if that macro is defined:

~~~
#define PRINT_JAMES
#ifdef PRINT_JAMES
   Person *person = [[Person alloc] initWithName:@"James"];
   [person printGreeting];
#endif
~~~

Note that we aren’t giving **PRINT_JAMES** a value, just saying that it exists.

You can add **#else** blocks too, and only the part of the condition that evaluates to true will be compiled.

~~~
#define PRINT_JAMES
#ifdef PRINT_JAMES
   Person *person = [[Person alloc] initWithName:@"James"];
   [person printGreeting];
#else
   THIS WILL COMPILE JUST FINE
   EVEN THOUGH THERE IS THIS
   TEXT HERE.
#endif
~~~

When that goes through the preprocessor, the part in the **#else** block gets removed because **PRINT_JAMES** is defined.

For advanced preprocessor checks, use **#if** to compare specific values with operators like **==**, **>**, and **>=**. You can even embed one check inside another **if** you want, for example:

~~~
#define DEBUG_MODE 2
#if DEBUG_MODE >= 1
   NSLog(@"Entering debug mode");
#if DEBUG_MODE >= 2
   NSLog(@"Verbose mode enabled");
#endif
#endif
~~~

### Platform macros

There are several useful predefined macros that you’re likely to meet. Let’s start with the hardware ones:

* **TARGET_OS_IPHONE**: Defined when the app is being built for iPhone.
* **TARGET_OS_IOS**: Defined when the app is being compiled for iOS.
* **TARGET_OS_MAC**: Defined when the app is being compiled for macOS.
* **TARGET_OS_WATCH** and **TARGET_OS_TV**: Defined when the app is being compiled for watchOS or tvOS.
* **TARGET_OS_SIMULATOR**: Defined when the app is being compiled for the Simulator app.

Let’s tackle the “OS” ones first, because they aren’t as straightforward as you think. Remember, **iOS is based on macOS**, and **tvOS and watchOS are based on iOS**, so you need to be very careful what values you check for.

Specifically:

* If you’re making a macOS app, **TARGET_OS_MAC** is set to 1 but everything else is set to 0.
* If you’re making an iOS app, **TARGET_OS_MAC** is set to 1, as are **TARGET_OS_IPHONE** and **TARGET_OS_IOS**.
* If you’re making a tvOS app, **TARGET_OS_MAC** is set to 1, as are **TARGET_OS_IPHONE** and **TARGET_OS_TV**.
* If you’re making a watchOS app, **TARGET_OS_MAC** is set to 1, as are **TARGET_OS_IPHONE** and **TARGET_OS_WATCH**.

So, basically **TARGET_OS_MAC** is set to 1 no matter what.

**TARGET_OS_IPHONE** is set to 1 if you’re using **iOS**, **tvOS** or **watchOS**.

**TARGET_OS_TV** is set to 1 on **tvOS**.

**TARGET_OS_WATCH** is set to 1 on **watchOS**.

So, if you want to share code conditionally between macOS and iOS-based systems, you should check for **TARGET_OS_IPHONE**. 

For example, here is how Apple defines **SKColor** from **SpriteKit**:

~~~
#if TARGET_OS_IPHONE
#define SKColor UIColor
#else
#define SKColor NSColor
#endif
~~~

On iOS, **SKColor** gets rewritten to be **UIColor**, but otherwise it uses **NSColor**. This allows developers to use SKColor everywhere in their code and have their games work across both platforms.

The outlier in all this is **TARGET_OS_SIMULATOR**, which is set to 1 or 0 based on whether you’re running on device or on the simulator. I find this useful for loading test files from disk: if you create a directory on your Mac, e.g. “/Simulator”, you can load files straight from there inside the simulator.

### Predefined Macros for Debugging

There are five more predefined macros you’re likely to meet:

* **DEBUG**: Defined when the app is built in debug mode.
* **__DATE__** and **__TIME__**: Inserts the date and time the code was built. 
* **__FILE__**: Inserts the name of the current file.
* **__LINE__**: Inserts the current line number.

When combined, these provide a simple way to inject information into your app for debugging purposes.