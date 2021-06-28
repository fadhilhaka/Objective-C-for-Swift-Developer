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

**Property Attributes**

Where properties start to get more complicated is when they have attributes attached to them. These are compiler instructions that affect the auto-generated accessor methods, and come in a variety of forms.

We aren’t using any explicit attributes right now, but we are using implicit attributes: there are defaults being assigned to our **name** property that affect the way it works.

There are **11 property attributes** in total, but they can be combined in a range ways so there are lots of possible combinations.

* **strong**: This is the default for objects, and means “hold onto the memory.” This is the default for properties in Swift.
* **weak**: This creates a weak reference for objects, just like weak properties in Swift. This is useful for breaking strong reference cycles.
* **copy**: This takes a copy of whatever object is assigned to the property.
* **assign**: This is the default for primitive types, and just assigns the value to the ivar.
* **nonatomic**: An atomic property is one that will include extra code to ensure reading a
value at the same time as it’s being written on another thread won’t produce garbage data. A non-atomic property is the opposite: that extra code isn’t added, so you need to make sure you don’t read and write the property simultaneously.
* **retain**: An old form of strong. If you see this, it’s a sure signal you’re working with old code.
* **readonly**: Do not generate a setter for this property.
* **readwrite**: Generate a getter and setter for this property. This is the default for properties of all types.
* **atomic**: See nonatomic above. Creating an atomic property has a small performance
impact, but it keeps your code safe. This is the default for properties of all types.
* **getter=**: This lets you change the name of a synthesized getter method.
* **setter=**: This lets you change the name of synthesized setter method.

Some of those come in groups, where you can specify only one item from each group.

For example, you may only choose one from **strong**, **weak**, **copy**, **assign**, and **retain**; one from **readonly** and **readwrite**; and one from **atomic** and **nonatomic**.

Some of the attributes bear more explanation. For example, why use **copy** rather than **strong**?

If you create an **NSMutableString** and assign it to a strong property of two different objects, both properties point to the same mutable string. So, if one changes, they both change. This might be what you want in some instances – for example arrays – but if you want each object to have its own unique properties that can’t be changed by surprise, you should use **copy** instead.

The **getter=** and **setter=** attributes allow you to change the names of the synthesized getter and setter accessor methods. This doesn’t affect you if you use dot syntax. Apple commonly uses these attributes to prefix boolean properties with “is”, for example **self.view.userInteractionEnabled** becomes [s**elf.view isUserInteractionEnabled**] because they specified a custom getter.

In our code right now, the name property is defined like this:

~~~
@property NSString *name;
~~~

With no attributes attached, the defaults are used. If we wanted to be explicit, we could write the following instead:

~~~
@property (strong, atomic, readwrite) NSString *name;
~~~

I’ve already demonstrated that it’s possible for someone to send an NSMutableString in place of an NSString, so the above opens us to a possible problem if someone changed our string under our feet. So, when you want your data to be fixed you should use **copy** instead of strong, like this:

~~~
@property (copy, atomic, readwrite) NSString *name;

// or simpler

@property (copy) NSString *name;
~~~

**Atomic vs Non-atomic**

Some people look at “atomic” and confuse it with “thread-safe” which is not true. 

An atomic property ensures that if two different threads try to write a value at the same time, a third thread trying to read a value will get something sensible back. The write is atomic: it either doesn’t happen or it fully happens, it doesn’t “half happen.”

Thread safety is something else entirely, and means that some code can be executed safely: if you move house from San Francisco to Paris you’ll change your street address, city, and country.

If I try to read your address while you’re part-way through changing your address, I might get your street address as the Champs-Élysées (updated), but your city and country as San Francisco and United States (not updated).

When you create IBOutlets, you’ll find that Xcode declares them as nonatomic properties because they ought never to be accessed from anywhere other than the main thread.

**Modifying Properties in Place**

If you want to move a button down 10 pixels, you might write something like this in Swift:

~~~
button.frame.origin.x += 10
~~~

Even though that’s only a semi-colon short of being syntactically valid Objective-C, it won’t compile.

Now that you know how properties work, you might even be able to guess why: this line of code tries to read a property (“get the existing origin X”) and write it (“add 10 to it”) in a single line of code.

This isn’t possible with Objective-C properties, so you will often see code like this:

~~~
CGRect frame = button.frame;
button.frame = CGRectOffset(frame, 0, 50);
~~~

**Class Properties**

Very modern Objective-C codebases may contain class properties. These are trivial in Swift, but in Objective-C take a little more work because they are never synthesized, which means you must create their ivar by hand and also create their methods.

To demonstrate this here’s the name property recreated as a class property:

~~~
@interface MyClass: NSObject
@property (class) NSString *name;
@end

@implementation MyClass
static NSString *_name = nil;
+ (NSString*)name {
   return _name;
}
+ (void)setName:(NSString*)str {
   _name = str;
}
@end
~~~

We need to explicitly create the _name backing storage for the property, then create the name and setName methods for reading and writing to that backing storage.

## Creating Objects

Object initialization is one area where Objective-C and Swift part ways quite dramatically:

1. You don’t need to provide default values for any properties: Objective-C will set objects to nil and numbers to 0 by default.
2. You always call the super class’s init method before initializing your own properties – the opposite of Swift.
3. You can call other methods in your initializer before you have finished initializing your own properties.
4. All initializers are automatically failable; they can return nil. You need to check for this before continuing.
5. You need to return self.

Creating objects is the second place where accessing ivars directly is a good idea, with the other place being custom getters and setters. The reason for this is because when accessing properties it’s possible for unintended side effects to occur that might leave your app in a fragile or outright broken state., usually as a result of KVO.

Consider a Person class with name and age properties. There’s another class, Office, which tracks Person objects. We might configure the Office object to observe the age property of each of its staff, so that everyone gets a cake on their birthday. 

If the Person initializer set the age before the birthday, it’s possible the Office object might try to read the name property and find that it’s not set yet.

The syntax for initializers in Objective-C is a little strange at first, putting it mildly. It starts by calling [**super init**], assigning the result to **self**, then putting all that inside an **if** statement.

What it means is “try to make me an instance of my super class, and if that succeeds then I’ll initialize my own properties.”

If the call to [**super init**] fails, then **self = nil** will return false, and no further work is done.

If you have a chain of inheritance, using [**super init**] may in turn call another parent class, which might call another parent class, and so on. Each child class then adds its own little bit of initialization into the mix, before finally you add your own.

>Note: You can write as many **init**... methods as you want, but you never write a custom **alloc** method. This is handled for you by **NSObject**.

## Categories and Class Extensions

Objective-C’s categories are analogous to Swift’s extensions, but there are subtle variations you need to be aware of, the fact that Objective-C’s categories only operate on classes.

An Objective-C category is a named set of extensions for any class. The names don’t do anything useful, which is probably why they were removed in Swift, but it does at least help you organize your categories.

It’s common to use a category’s name in its filename like this: **ClassName+CategoryName**. For example, if you add a category to **UIColor** that generates random shades of your favorite color, you might call the category **UIColor(RandomShades)** and name the files **UIColor+RandomShades.h** and **UIColor+RandomShades.m**.

Apple uses categories extensively to help segregate macOS and iOS functionality.

For example, both platforms use **NSString** for their strings, but one has a **NSString(NSStringDrawing)** category that adds macOS-specific drawing code, and the other has a **NSString(UIStringDrawing)** category that adds iOS-specific code.

Because categories can work on any class – including Apple’s own classes – you need to be extra careful when naming any methods you add.

For example, if you add a trim method to NSString, what happens if a new version of iOS comes out that has a built-in trim method? “Bad things”, that’s what. Instead, **you should prefix your methods with the initials of your name or company**, for example, ts_trim would work fine if you were Taylor Swift.

**Class Extensions vs Categories**

Categories can add new methods to any class, even ones you didn’t write. In fact, this is their most common purpose: add some functionality to built-in classes like **UILabel**, **NSArray**, and **SKProduct** to make common tasks easier.

Class extensions are a specialized variety of categories, and in fact look just like anonymous categories because they don’t have a name. They aren’t quite as flexible because they don’t allow you to work on classes that aren’t part of your source code, which means you can’t extend **NSString** or any other Apple class.

However, within that limitation they are substantially more powerful because they let you add properties and ivars to a class, as well as methods. This is possible because the class extension is compiled into the original class’s source code at build time, rather than bolted on separately as with a regular category. This makes them work like partial classes in C#.

The most common way this class extension technique is used is with **readonly** properties.

When you create a read-only property, the compiler won’t synthesize a setter and so you can read from a property without being able to change it. That works well for API you expose, but often you want to be able to **read** and **write** the property inside the class, which is where class extensions come in: declare the property as **readonly** in the header and then redeclare it as **readwrite** in the implementation.

>Note: **readwrite** is actually the default, so any redefinition will automatically make the property **readwrite**.

## Protocols

Protocols in Objective-C are almost identical to Swift, particularly when you use the @objc attribute in Swift.

Unsurprisingly, adding that attribute in Swift effectively brings it up to par with Objective-C: you can have required methods as well as optional requirements, both of which are available out of the box in Objective-C.

To mark a class as conforming to a protocol, you need to add a comma-separated list of protocols in angle brackets after your class name.

For example, our basic **Person** class looks like this:

~~~
@interface Person : NSObject
~~~

If we wanted to mark it as conforming to some protocols, we would write this:

~~~
@interface Person : NSObject <NSCopying, NSCoding>
~~~

You can then query the object at runtime, like this:

~~~
if ([myPerson class] conformsToProtocol:@protocol(MyProtocol)]) { }
~~~

Or you can query a whole class like this:

~~~
[MyClass conformsToProtocol:@protocol(MyProtocol)];
~~~

## Nullability

Objective-C has always been fairly free and easy with its usage of nil values, but the introduction of nullability syntax allows you to explicitly mark which things may or may not be nil.

That might sound close to Swift’s optionals, and with good reason: using Objective-C’s nullable syntax makes optionality much more pleasant for Swift users, while also potentially catching some Objective-C bugs too.

Nullability affects the language much more extensively than generic collections, which inevitably means take-up is slower. 

To use it properly, you need to audit each one of your files and make sure you attach nullability constraints to each of your properties and methods. You can also make a blanket promise, “assume everything isn’t null,” but that’s potentially risky unless you still go through and audit your code.

Nullability in Objective-C is similar to generics, in that both are lightweight features designed to make the transition from Objective-C to Swift smoother. They are both limited in what they offer, and in the case of nullability the protection it offers is not even in the same league as Swift’s optionals.

**Nullable Properties and Methods**

There are several different ways of adding nullability annotations to properties and methods depending on what you’re trying to do, but in practice you will nearly always use just two keywords: **nullable** and **nonnull**.

As soon as you add one of these to any of your properties or methods in your header file, Xcode will ask that you mark everything, so be prepared to do quite a bit of work.

You can generated Swift code from Objective-C with Xcode Assistant Editor, from menu Editor - Assistant -> in counterpart tab choose Swift.

As soon as you mark one thing with nullability annotations you need to mark everything with one.

**Audited Regions**

Xcode has a special macro that effectively flips around nullability auditing: rather than opting in to nullability, you tell Xcode to assume that everything is non-null, then opt out of the parts that might be null.

This is accomplished using the **NS_ASSUME_NONNULL_BEGIN** and **NS_ASSUME_NONNULL_END** macros, which should always be used in pairs.

You can have more than one pair if you need to mark multiple individual blocks, but it’s more common to place **NS_ASSUME_NONNULL_BEGIN** at the start and **NS_ASSUME_NONNULL_END** at the end so that everything is implicitly considered **nonnull**.

If you’re using these macros, then you no longer need all the nonnull keywords everywhere – that becomes the default.

~~~
NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property NSString *name;
- (instancetype)initWithName:(NSString*)name;
- (NSString*)fetchGreetingForTime:(NSString*)time;

@end

NS_ASSUME_NONNULL_END
~~~

I think you’ll agree it looks much cleaner, and it also means that any nullability annotations that remain are more likely to catch your eye while reading.

For example, we might decide that our initializer might return nil sometimes, so we’d just modify that one line to be **nullable**, like this:

~~~
- (nullable instancetype)initWithName:(NSString*)name;
~~~

**Where things fall down**

Now that we have nullability annotations in place and our generated Swift interface looks good. Let’s take a look at how Xcode uses this information to provide protection against accidental mistakes.

Try modifying the fetchGreetingForTime method to this:

~~~
- (NSString*)fetchGreetingForTime:(NSString*)time {
   self.name = nil;
   return [NSString stringWithFormat:@"Good %@, %@!", time,
self.name];
}
~~~

Clearly that’s the kind of mistake you won’t make in real life, but that’s not the point: this is simulating us making a mistake by putting nil into a nonnull property.

As you enabled “Treat warnings as errors”, Xcode should refuse to compile, saying “Null passed to a callee that requires a non-null argument.” This is an immediate win for nullability, because it’s refusing to let us call the **setName** method with a nil value. 

Because Apple has audited all their own APIs, this means things like sending nil to **addObject** on an **NSArray** will also refuse to build, which will definitely help to eliminate some bugs.

Now try modifying fetchGreetingAtTime to this:

~~~
- (NSString*)fetchGreetingForTime:(NSString*)time {
   NSString *str = nil;
   self.name = str;
   return [NSString stringWithFormat:@"Good %@, %@!", time, self.name];
}
~~~

That assigns nil to a temporary string, and puts that string into the property, and this time it compiles cleanly because the compiler isn’t able to trace the nil value from one line to the next.

This is where a separate tool steps in: the static analyzer. This goes over your code in more detail than the compiler, looking for logic errors, API errors, and memory management problems. It literally follows the flow of your code, and in this case it will be able to follow **nil** being assigned to **str**, then **str** being assigned to **self.name**.

Go to the Product menu and choose Analyze. You’ll see a new blue warning appear, which is the color used to highlight static analyzer warnings. It ought to say, “Null passed to a callee that requires a non-null 1st parameter,” which is exactly what’s happening.

The static analyzer will also catch you trying to return nil from the method if you try it, which again the regular compiler would not. Even better, it will even stop you from trying to bypass the property by assigning nil directly to an nonnull **ivar** – it really is very clever, and gets better with every release.

Nullability is a guarantee for your interfaces, but it’s less useful for internal code unless you compulsively run the static analyzer.

This means you need to go through your methods closely to ensure that you keep the nullability promises you make, so that Swift users who rely on your interface get what they expect.

**The null_resettable Annotation**

There’s another nullable annotation that you might come across called **null_resettable**.

Some properties have a meaningful default value that can be restored by setting the property to **nil**.

The best example of this is the **tintColor** for controls in iOS: you can set it to red to make a button have a red tint, then you can set it to nil. But when you set it to nil, it doesn’t mean “no tint color.” Instead, it sets it back to the default value: iOS’s standard sky blue shade.

This means reading from **tintColor** will always return a value, but you can write a **nullable** value to it.

In Objective-C, this is accomplished by the **null_resettable** annotation.

When you apply it to a property – which is the only place it can be applied – it does two things. First, it makes the property an implicitly unwrapped optional in your Swift interface, because the property ought never to be nil when read. Second, it breaks compilation, because Xcode doesn’t know what default value to assign.

To use this type annotation you need to create custom accessor methods for your type. The setter can work as normal, but the getter needs to ensure a default value is provided if the current **ivar** is **nil**.

~~~
- (NSString *)name {
   if (_name == nil) {
      return @"Anonymous";
   } else {
      return _name;
   } 
}
~~~

**Transitioning to Nullability**

If you work on a project that is part way through migrating to nullability, there’s one further annotation you might find: **null_unspecified**.

This means “we haven’t audited this yet”, and returns the code to using implicitly unwrapped optionals. This is a helpful annotation when you want to opt in to nullability, but you’re not sure what a particular property or method should use.

This might be because it’s complicated, or because you haven’t gotten around to it yet, but either the way this annotation is definitely temporary: you should move away from it once your audit is complete.

Ultimately, your goal is to be able to use **NS_ASSUME_NONNULL_BEGIN** and **NS_ASSUME_NONNULL_END** for all your interfaces, meaning that you have audited all your methods and properties to ensure they are safe.

You benefit from some compiler protection and some static analyzer protection too, but you’ll also make life easier when working with Swift code now and in the future.