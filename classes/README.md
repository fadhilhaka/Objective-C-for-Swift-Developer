# Classes

When we create new file subclass of **NSObject**, for example **Person**, this will create two files **Person.h** and **Person.m**.

You’ll see **@interface Person : NSObject** in **Person.h**, which is where the external interface for the class is defined.

The **Person.m** file contains **@implementation Person**, which is where you’ll put the implementation of your interface, i.e. the source code to perform the methods you create.

So, in theory you define your methods and properties in the header file, then you implement the methods in the implementation file.

>Note: Press **Ctrl+Cmd+Up** to toggle between the header and implementation files for a class.

**Inheritance**

Objective-C supports inheritance identically to Swift, although the syntax is predictably different. In your Person.h file you will see this line:

~~~
@interface Person : NSObject
~~~

That creates a new class called Person, and marks it as inheriting from the NSObject universal base class.

## Methods

Let’s start with something simple: creating a **printGreeting** method. This will accept no parameters and return nothing.

~~~
- (void)printGreeting {
   NSLog(@"Hello!");
}
~~~

There are some important things to note there:

1. The **-** marks the start of a normal method. If we had used **+** instead it would be a **static method**, i.e. one that belongs to the class rather than instances.
2. The return type is placed in parentheses before the method name. void means “nothing is returned.”
3. Conventionally, a space is placed after the - but not before the method name. So, don’t place a space after the closing parenthesis of (void).

If we want to use this method in main.m, we need to do a couple of things first. Open main.m now and replace your existing main() function with this:

~~~
int main(int argc, const char * argv[]) {
   @autoreleasepool {
      Person *person = [Person new];
      [person printGreeting];
   }
return 0; 
}
~~~

That creates a new **Person** object, then calls **printGreeting** on it. But it won’t compile: you’ll get an error along the lines of “Use of undeclared identifier ‘person’.

In Swift, any file you create in your project is automatically built into your app’s namespace, which means a class you declare in file A is automatically available in file B.

Not so in Objective-C: we need to **#import** the header file for **Person.h** to be able to use it in **main.m**.

~~~
#import "Person.h"
~~~

If you try compiling again, you’ll see it still doesn’t work. This time the error should be “No visible @interface for ‘Person’ declares the selector ‘printGreeting’.”

This error occurs because we have effectively made **printGreeting** private: it’s created inside the implementation file, but not exposed in the header.

To fix this problem, we need to add a function declaration for **printGreeting** into **Person.h**. Place this between the **@interface** and **@end** lines:

~~~
- (void)printGreeting;
~~~

>Note: **main.m** imports only the header file, so as far as it’s concerned the **Person** class supports only the properties and methods listed there. Regardless of whether the method is listed in **Person.h** or not, having it in **Person.m** means it’s available to other methods inside **Person.m** – this is why it was effectively private until we added it to **Person.h**.

Objective-C doesn’t really have any understanding of private methods. Sure, we can avoid declaring a method in the header file, but anyone can still call it if they know how. For example, this code works after removing **printGreeting** from **Person.h**:

~~~
Person *person = [Person new];
[person performSelector:@selector(printGreeting)];
~~~

Now, if you’re a sensible person and using “Treat warnings as errors,” that code will produce an error and you’re probably feeling very smug. But I have some bad news, and it’s a result of the distinction between selectors and methods. 

Most of the time the difference between a selector and a method doesn’t really matter, but here it does: a method is an actual implementation of some code in a class, but a selector is just the name of a method, e.g. “printGreeting”.

This distinction is not just academic, but you might need to read the following a few times in order for it to make sense.

Imagine we had another class, **Dog**, that had a **printGreeting** method too, that looked just like the **printGreeting** method from **Person**: no parameters or return value.

Even though the method itself is very different – one is on **Dog** and the other is on **Person**, and presumably one prints out “Woof!” – **the selector is identical**.

Right now your **performSelector** code is printing the error “Undeclared selector ‘printGreeting’” because you took out the declaration in **Person.h**. But if you were to add in a **#import** for our hypothetical **Dog** class, that error would go away: Xcode doesn’t care that **printGreeting** isn’t declared in **Person.h**, as long it’s declared somewhere.

What this means is that you can send messages to objects even if they aren’t specified in their interface, and Xcode will not warn you if the same selector is declared in a different header file.

Worse, the object you’re sending it to might not even support that selector, in which case your app will crash.

If you want to be sure that a selector is supported by an object, make sure you use the **respondsToSelector** method before making your call.

**Naming Parameters**

You can add parameters to methods using a combination of parentheses, colons and spaces.

~~~
- (void)printGreeting:(NSString*)greeting {
   NSLog(@"%@", greeting);
}
~~~

You will need to modify **Person.h** to this:

~~~
- (void)printGreeting:(NSString*)greeting;
~~~

To call that new method, modify **main.m** to this:

~~~
Person *person = [Person new];
[person printGreeting:@"Welcome!"];
~~~

The coding convention in Objective-C is that the **first** parameter is part of the method name.

For example, if we wanted a new method that greets a person by name, we would write something like this:

~~~
- (void)printGreetingTo:(NSString*)name {
   NSLog(@"Hello, %@", name);
}
~~~

The goal is to create code that can be read aloud and sound relatively normal. This frequently means that second and subsequent parameters start with “and”, “with”, “at”, or similar, for example:

~~~
- (void)printGreetingTo:(NSString*)name atTimeOfDay:(NSString*)time {
   if ([time isEqualToString:@"morning"]) {
      NSLog(@"Good morning, %@", name);
   } else {
      NSLog(@"Good evening, %@", name);
   } 
}
~~~

To call that method, put this in **main.m**:

~~~
[person printGreetingTo:@"Taylor!" atTimeOfDay:@"evening"];
~~~

The second parameter starts with the external label **atTimeOfDay**, which is what people see when calling it and there is the internal name for the parameter, **time**, which is what is used inside the method. 

That is a named parameter. It is different from the first parameter because that should be named as part of the method. These named parameters form part of the selector, and matter – sometimes the only difference between two methods is the label given to a parameter.

**Multiple return values**

Without tuples, Objective-C has no pleasant way to return multiple values from a method call.

One approach is to use pointer pointers, as with the **stringWithContentsOfFile** method.

~~~
+ (instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError **)error;
~~~

Note the **+** at the beginning: this is a class method, meaning that it’s called on **NSString** directly.

The pointer pointer approach is equivalent to using **inout** in Swift.

A second approach, and one I think is slightly more attractive because it results in cleaner code, is to return a **dictionary** with values filled in.

~~~
- (NSDictionary*)fetchGreetingTo:(NSString*)name atTimeOfDay:(NSString*)time {
    if ([time isEqualToString:@"morning"]) {
        return @{
            @"English": [NSString stringWithFormat:@"Good morning, %@", name],
            @"French": [NSString stringWithFormat:@"Bonjour, %@", name]
        };
    } else {
        return @{
            @"English": [NSString stringWithFormat:@"Good evening, %@", name], 
            @"French": [NSString stringWithFormat:@"Bonsoir, %@", name]
        };
    } 
}
~~~

**Calling selectors with parameters**

~~~
[person performSelector:@selector(printGreeting)];
~~~

That effectively means “find the method named **printGreeting** and run it."

To call that method with named parameter you need to use this code:

~~~
[person performSelector:@selector(printGreeting:) withObject:@"Taylor"];
~~~

That adds a colon after **printGreeting** to signify that we’re looking for a selector that accepts a parameter, then adds a **withObject** parameter.

To call **printGreetingTo:atTimeOfDay:** method we need to write the following:

~~~
[person performSelector:@selector(printGreetingTo:atTimeOfDay:) withObject:@"Taylor" withObject:@"morning"];
~~~

**Class Methods**

~~~
+ (void)genericGreeting {
   NSLog(@"Greetings, earthlings.");
}
~~~

As you’ve seen with strings and arrays, attaching class methods is commonly used for convenience initializers.

Rather than using **[[Person alloc] initWithName:@"Taylor"]** you could add a class method **[Person personWithName:@"Taylor"]**.

~~~
+ (instancetype)personWithName:(NSString*)name {
   return [[self alloc] initWithName:name];
}
~~~

**Availability Checking**

If you’re working on a modern Objective-C codebase, it’s possible you may meet Objective-C availability checking.

Objective-C introduced this in 2017 with very similar syntax and results with Swift.

~~~
if (@available(iOS 9, *)) {
   UIStackView *stackView = [UIStackView new];
   // do stuff
}
~~~

Just like in Swift, this will check your code against your deployment target and automatically point out places where they don’t match.

You can mark your own methods and properties using the **API_AVAILABLE** macro, like this:

~~~
- (void)printAddress API_AVAILABLE(macos(10.13));
~~~

## Properties

Objective-C has an uneasy relationship with properties, largely because they were only introduced as a concept after the language had already existed for about 20 years.

**Instance Variables**

Instance variables (commonly called **ivars**) look like Swift properties, but in Objective-C they are much simpler things and aren’t really used by themselves any more.

We’re going to modify the **Person** class so that it has a **name** instance variable. Here’s the new **Person.h** file:

~~~
@interface Person : NSObject {
   @public
   NSString *name;
}
- (void)printGreeting;
@end
~~~

To create ivars inside a class, you need to open a brace directly after the **@interface** line.

You then list each ivar you want, with its data type and name, a bit like Swift’s properties. Note ther is a **@public** before the ivar: without that, the value is not accessible outside the class.

Inside Person.m, the **printGreeting** method can read the **name** ivar just like in Swift:

~~~
@implementation Person
- (void)printGreeting {
   NSLog(@"Hello, %@!", name);
}
@end
~~~

When setting the ivar in **main.m**, you need to use the indirect member access operator **->**, like this:

~~~
Person *person = [Person new];
person->name = @"Taylor";
[person printGreeting];
~~~

**Pure Properties**

In Objective-C, a property is a method that gets and sets the value of an **ivar**.

In older versions of the compiler, you needed to create the ivar, declare the property, then tell the compiler to connect the two. As of Xcode 4.4 this was simplified, and the result is that you no longer need to worry about ivars: properties can do everything for you.

There are lots of ways to write properties. The simplest is just to write **@property** before what would have been your **ivar** previously, although you need to place this outside the braces where you had your **ivars** previously.

As pure properties don’t need **ivars** at all, it’s common to remove the braces entirely.

For example, Person.h would look like this:

~~~
@interface Person : NSObject
@property NSString *name;
- (void)printGreeting;
@end
~~~

When you want to access a property on your class, there are three ways to do so, but for now let’s use the most important way: writing **self**. then your property name.

Here’s how the printGreeting method should look in Person.m:

~~~
- (void)printGreeting {
   NSLog(@"Hello, %@!", self.name);
}
~~~

Finally, here’s **main.m** updated to include the new property:

~~~
Person *person = [Person new];
person.name = @"Taylor";
[person printGreeting];
~~~

Note that I’ve using **.** rather than **->** to access the property. This is called dot notation.

The second way to access a property is using a method call, like this:

~~~
- (void)printGreeting {
   NSLog(@"Hello, %@!", [self name]);
}
~~~

This is where properties can get a bit confusing, when you write **self.name** to **read** a property, behind the scenes it’s just syntactic sugar for writing **[self name]**.

When you use **self.name** to **write** a property, it’s just syntactic sugar for writing **[self setName:@“...”]**.

We could have written this in **main.m**:

~~~
[person setName:@"Taylor"];
~~~

Whenever you create a property, **these accessor methods are generated automatically**, and when you use dot notation to read or write properties, these methods get called.

So, if you create a property called **age** there will be an **age** method to return the value and a **setAge** method to set it. 

This is true for all classes. For example, **arrays** have a **count** method, which is true, but only because it has a **count** property that gets converted into a **count** accessor method.

**Mixing Properties and Ivars**

When you use **@property** to declare a **name** property, Xcode does more than just create **name** and **setName** methods. It also creates an **ivar** called **_name**, and connects that to the two methods it generates.

This is called synthesizing an ivar, and it’s the preferred approach – you create the property, and let Xcode do the rest.

We've done two ways to access properties: dot syntax and accessor methods. There’s a third way, which is to bypass the property entirely and access the synthesized ivar.

~~~
- (void)printGreeting {
   NSLog(@"Hello, %@!", _name);
}
~~~

Apple’s own documentation makes it clear this is really not a smart idea, and yet you’ll see this code all over the place.

There are legitimate reasons for needing to access an ivar directly, but sadly the most common reason is “it’s faster.” This is true, but by such a microscopically irrelevant amount that it might as well not be.

The name of **_name** is decided automatically by Xcode: it’s just the name of your property with a leading underscore.

You can, however, ask for your own ivar name if you have something special in mind. To do this, add an **@synthesize** line inside your **@implementation**, like this:

~~~
@implementation Person
@synthesize name = userName;
- (void)printGreeting {
   NSLog(@"Hello, %@!", userName);
}
@end
~~~

That synthesizes the **name** property as the **userName** ivar, which is then accessed directly in the **printGreeting** method. 

While that approach is possible, you are more likely to find code like one of the below:

~~~
@synthesize name;
@synthesize name = _name;
~~~

The first means “synthesize the name property as the name ivar,” which is – broadly speaking – a Really Bad Idea, because it confuses two very different things.

The second means “synthesize the **name** property as the **_name** ivar,” which is identical to what Xcode gives you if you miss off the line entirely. This sort of code is what you’ll usually see when someone has written a custom getter and setter.

**Custom Getters and Setters**

Accessing an ivar directly is only recommended in two situations, one of which is if you want to implement a custom getter or setter.

By default, the accessor methods generated by properties read and write the ivar as you would expect, but you can write your own methods if you wish, for example if you wanted to write some data to a file when a property was changed.

Writing your own getter and setter is also a helpful way to understand what’s going on with the synthesized ivars, and helps demonstrate one of the most common pitfalls with Objective-C’s properties.

Here’s the new code for **Person.m**:

~~~
@implementation Person
@synthesize name = _name;
- (void)printGreeting {
   NSLog(@"Hello, %@!", self.name);
}
- (NSString*)name {
   NSLog(@"Reading name!");
   return _name;
}
- (void)setName:(NSString *)newName {
   NSLog(@"Writing name!");
   _name = newName;
}
~~~

The first thing that code does is synthesize the property to the _name ivar. This is what Xcode does for us by default, but as soon as you override the accessor methods you need to synthesize the ivar yourself. 

The two accessor methods must be named exactly as shown, receiving and returning the same data type as the property uses, but you’ll find that Xcode’s code completion will help you write them if you’re not sure.

The **name** method returns the value of **_name**, and the **setName** method sets the value of **_name** directly. 

If we had written **self.name** inside the **setName** method, then it would call **setName** to set the name, which would call **setName** to set the name, and so on – the setter would call itself a few thousand times until your app eventually crashed.

Now try changing the printGreeting method to this:

~~~
- (void)printGreeting {
   NSLog(@"Hello, %@!", _name);
}
~~~

That accesses the **ivar** directly rather than using the property, so the code now prints “Writing name!” then “Hello Taylor!” – it doesn’t print “Reading name!” any more.

Lots of people think using ivars like this is OK, presumably because they “know” when it’s safe and when it’s not. However, they are wrong: Apple recommends against it for good reason, and if you take my advice you will always use **self.** so that properties are accessed through their getter and setter methods. 

The only exceptions are when using custom getters and setters, as discussed here, and when working with object creation.

**Private Properties**

Objective-C doesn’t really have any concept of private methods: even if you don’t declare a method in your header, it can still be called using **performSelector**.

As properties are just methods with a **synthesized ivar**, this means you can’t make truly private properties either.

However, you can at least follow the same approach of removing the property from the header file so that it isn’t openly exposed to the world.

Creating these pseudo-private properties takes a little more work than pseudo-private methods, because we still need to declare the property somewhere.

The solution is to use a technique called class extensions, which lets us create a second interface for the Person class: the first interface is the one in **Person.h** that declares the **printGreeting** method, but we can write a second interface in **Person.m** that creates the **name** property.

First, here’s how Person.h should look:

~~~
@interface Person : NSObject
- (void)printGreeting;
@end
~~~

No mention of **name** in there anywhere. Instead, we move the property to a class extension in **Person.m**, which is a way of adding more functionality to an existing class.

Here’s the new Person.m file:

~~~
@interface Person ()
@property NSString *name;
@end
@implementation Person
- (void)printGreeting {
   NSLog(@"Hello, %@!", self.name);
}
@end
~~~

Remember, only **Person.h** gets imported into **main.m**, so as far as the **main()** function is called there is no **name** property on the **Person** class.

Notice that the syntax for the second **@interface** is different: this is a class extension rather than a new class, so you write the name of the existing class followed by an empty pair of parentheses.

You can only create class extensions if you have the source code to the class.