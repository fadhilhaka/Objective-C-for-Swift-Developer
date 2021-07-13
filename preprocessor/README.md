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

### Mimicking Swift

Here are two macros you might want to consider adding to your Objective-C projects:

~~~
#define let __auto_type const
#define var __auto_type
~~~

They define two new keywords, **let** and **var**, that work very similarly to Swift’s – they create constants and variables, and they use type inference to figure out the type of your objects. This makes your Objective-C code significantly more Swifty!

## Metadata Macros

There are three compiler directives that you might find useful outside of the usual flow of building code.

They are **#warning**, **#error**, and **#pragma**, although if you’ve enabled **“Treat warnings as errors”** then this is the one time it’s actually unhelpful.

Both **#warning** and **#error** work identically to their counterparts in Swift, but **#pragma** has no Swift counterpart.

The **#warning** directive automatically emits a compiler warning of your choosing.

~~~
#warning We should probably fix this.
~~~

When the code gets built, there will now be a warning on this line saying “We should probably fix this.”

This allows you to mark code as needing further work without needing an external bug tracker – everyone will see this warning until it’s finally removed. Sadly, this becomes useless when **“Treat warnings as errors”** is enabled, because what was a small notice in your code now stops everything from building.

If you really do want your code to stop building, regardless of **“Treat warnings as errors”**, you can use **#error** to always generate a compiler error.

~~~
#error You need to change the value below then remove this line.
~~~

Seeing a line of code like that is common if you’re using someone else’s code, because it stops people trying to run some code without filling in required values.

Finally, there’s **#pragma**, which has two main purposes: placing markers in your code and adjusting compiler settings mid-flight.

~~~
#pragma mark - UITableView delegate
~~~

That “UITableView delegate” text now appears in the Xcode jump bar in bold, allowing you to group methods together more easily in a long file.

The second use of **#pragma** is to adjust your build settings for part of a file. 

This is most commonly used when someone has written some “clever” code that Xcode does not think is quite so clever, so it’s issuing warnings.

For example, if you’re performing a selector that Xcode isn’t sure about, you’ll get a warning that it might leak. In this case, you might see **#pragma** used to block that warning.

~~~
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
// CODE THAT NORMALLY GENERATES WARNINGS HERE
#pragma clang diagnostic pop
~~~

Using this approach hides that particular warning for a small block of code.

## Defining Function-like Macros

Function-like macros are where macros either show their true power, or show their true potential for mayhem depending on your point of view.

They are built in the same way as object-like macros, but you can give them a parameter list and use those parameters in the expanded code.

>NOTE: When you write a function-like macro you must put your opening parenthesis immediately after the name of the macro, with no space.

~~~
#define MINVAL(x, y) x < y ? x : y
~~~

That creates a new function-like macro that accepts two parameters. You can refer to these parameters inside the macro function, so that one returns the least of two numbers. It’s used like this:

~~~
NSInteger minimum = MINVAL(1, 2);
NSLog(@"The lower number is %ld", (long)minimum);
~~~

When the preprocessor runs, that code gets expanded into this:

~~~
NSInteger minimum = 1 < 2 ? 1 : 2
NSLog(@"The lower number is %ld", (long)minimum);
~~~

Now, that code has a problem: if you use it in a non-trivial statement it won’t work as expected. For example, this will set minimum to be 1:

~~~
NSInteger minimum = 1 + MINVAL(1, 5);
~~~

That expands into the following:

~~~
NSInteger minimum = 1 + 1 < 5 ? 1 : 5
~~~

Fortunately, you’re not stuck with **MINVAL()**: Objective-C has its own **MIN()** macro built in that is far more robust.

Here’s Apple’s version of function-like macros:

~~~
#define __NSX_PASTE__(A,B) A##B
#if !defined(MIN)
#define __NSMIN_IMPL__(A,B,L) ({ 
    __typeof__(A) __NSX_PASTE__(__a,L) = (A); 
    __typeof__(B) __NSX_PASTE__(__b,L) = (B); 
    (__NSX_PASTE__(__a,L) < __NSX_PASTE__(__b,L)) ? __NSX_PASTE__(__a,L) : __NSX_PASTE__(__b,L); 
})
#define MIN(A,B) __NSMIN_IMPL__(A,B,__COUNTER__)
#endif
~~~

The advantage to function-like macros is that their code becomes inlined into your own, which means there’s no performance hit for making a function call. To be honest, function calls are so fast you’d either have to be making an intensive game or working on a media-editing app to find that they are a problem, so please don’t try to “optimize” your code until you’re sure where the bottleneck is.

Two common function-like macros you may come across are **DEG2RAD()** and **RAD2DEG()**, which inline the math for converting degrees to radians and back:

~~~
#define DEG2RAD(x) ((x) * M_PI / 180.0f)
#define RAD2DEG(x) ((x) * 180.0f / M_PI)
~~~

Notice how **x** is placed in parentheses? That’s to stop it interfering with the rest of the code when it’s expanded, for example if someone use **DEG2RAD(5 + 5)**.