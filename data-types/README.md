# Data Types

## Strings

### Creating Strings

~~~
NSInteger number = 42;
NSString *output = [NSString stringWithFormat:@"You picked %ld", (long)number];
NSLog(@"%@", output);
~~~

There’s an alternative way to do exactly the same thing by using alloc/init.

~~~
NSString *output = [[NSString alloc] initWithFormat:@"You picked %ld", (long)number];
~~~

You can load a string from the contents of a file like this:

~~~
NSString *output = [[NSString alloc]
initWithContentsOfFile:@"hello.txt" usedEncoding:nil error:nil];
~~~

It’s a useful skill to be able to mentally convert Swift code to Objective-C, in just the way Apple’s own converter works. When you see “initWith”, you should mentally remove it. When you see error you should remove it and consider the call as throwing an error. 

So, in this case of **initWithContentsOfFile:usedEncoding:error** it becomes **contentsOfFile:usedEncoding:** and can throw an **error**.

### Manipulating and Evaluating Strings

NSString has a huge collection of methods for manipulating strings, such as:

* stringByReplacingOccurrencesofString: replaces one substring with another.
* stringByAppendingString: adds a new string to the existing one, making a new string. * stringByAppendingFormat: add a new string with formatting specifiers to the existing one, making a new string.
* substringFromIndex: create a new string using part of the existing one.
* componentsSeparatedByString: create an array by splitting a string.
* integerValue: convert a string into an integer, or 0 if it’s an invalid integer. (Also, doubleValue, floatValue.)
* boolValue: convert a string to a boolean. Returns true if the string starts with Y, y, T, t, or the digits 1 to 9.

There are also some methods for comparing strings: **containsString** returns true if string A contains string B, and **isEqualToString** is used to compare two strings.

>Note: you need to compare strings using the **isEqualToString** method, and not **==**.

### Mutable Strings

NSString is always immutable but it is not constant by default. 

Unlike Swift, Objective-C doesn’t have a language construct to differentiate between mutable and immutable objects. Instead, mutability is controlled by the class name you want to use: NSString is immutable, whereas NSMutableString is mutable.

~~~
NSMutableString *mutable = @"Hello";
~~~

That will produce an error if you’re sensible, or a warning if you like living on the wild side and didn’t enable warnings as errors.

What this means is “create a variable that can hold a mutable string, then place an immutable string in there.” Remember, @"..." creates an NSString, so you’re trying to place an immutable object inside a mutable container.

If you want to create a mutable string, you can either create a mutable copy of an existing string, or use one of the NSMutableString initializers. To create a mutable copy of a string, just use the mutableCopy method like this:

~~~
NSMutableString *hello = [@"Hello" mutableCopy];

NSMutableString *hello = [NSMutableString stringWithFormat:@"..."];
~~~

There is one bonus initializer: **stringWithCapacity** lets you tell the system how big you expect the string to grow, which allows the system to avoid reallocating RAM if your string grows larger. For example, this tells the system we want to store up to 4096 characters:

~~~
NSMutableString *longString = [NSMutableString stringWithCapacity:4096];
~~~

Once you have a mutable string, you can modify its contents by using **setString** to modify its contents entirely, or use mutable versions of some of the methods from earlier.

For example, **stringByReplacingOccurrencesofString** becomes **replaceOccurrencesOfString**, and **stringByAppendingString** becomes just **appendString**, because they operate in place – i.e., modify the existing mutable string and leave the pointer alone, rather than creating a new one and updating the pointer.

For example, this creates a mutable string, modifies it, then prints out the new value:

~~~
NSMutableString *first = [@"My string" mutableCopy];
[first setString:@"Something else"];
NSLog(@"%@", first);
~~~

Assigning an NSMutableString to a regular NSString was a terrible idea. This code will prints out “Something else” – even though we thought we had a non-mutable string that had the value “My string”, we actually didn’t, and it got changed under our feet.

~~~
NSMutableString *first = [@"My string" mutableCopy];
NSString *second = first;
[first setString:@"Something else"];
NSLog(@"%@", second);
~~~

The solution most people use is to take copies of values during assignment, like this:

~~~
NSString *second = [first copy];
~~~

That way second won’t change its value when first does, which makes your code much easier to reason about.

### Useful Functions

There are several global functions that create an NSString from various types of input data. This is mainly useful when using NSLog(), because it lets you neatly print out structures like CGRect.

The most useful functions are these:

* NSStringFromClass(): Give it a class name, e.g. [myObject class], and it will return “MyObject”.
* NSStringFromRect(): Give it a CGRect and get back the origin and size in one string.
* NSStringFromSize(): Give it a CGSize and get back the width and height values.
* NSStringFromPoint(): Give it a CGPoint and get back the X and Y coordinates.

## Numbers

**int** is a series of 1s and 0s that represent 32-bit numbers. 

**NSInteger** is a series of 1s and 0s that can be either a 32-bit integer or a 64-bit integer depending on the CPU.

There are also specific data types like **int64_t** for integers that are always 64-bit, **NSUInteger** for unsigned 32- and 64-bit integers, and so on.

All of those types are called primitive types: they are raw numbers that can be manipulated directly by the CPU.

There’s a whole other data type for storing numbers. It’s called **NSNumber**. And it’s completely different with **NSInteger**. The difference is this: all those integer types are primitive, but NSNumber is an object.

**NSInteger** holds only integers, whereas **NSNumber** can hold int, NSInteger, floats, doubles, and even booleans.

This means you can create it from an integer, and read it back as a double, or create it as a boolean and read it back as a float.

It is obviously supremely inefficient to use objects for basic mathematics, so you might be wondering why NSNumber is even needed. Well, it turns out that you can’t even do mathematics using NSNumbers – even if you created two of them called first and second, this kind of code wouldn’t work:

~~~
NSNumber *third = first + second;
~~~

Instead, NSNumber is designed to be a storage device, because Objective-C has one dramatic shortcoming that may well shock you: arrays and dictionaries can only hold objects. This means you can’t place integers into arrays, nor floats, doubles, or booleans.

You can create **NSNumber** instances using one of its many initializers, for example **numberWithInteger** accepts an **NSInteger** and returns an **NSNumber** instance that wraps it. You can then read back the number in the same or different data type, using methods like **floatValue**, **intValue**, and **integerValue**.

~~~
NSNumber *ten = [NSNumber numberWithInteger:10];
float floatTen = [ten floatValue];
~~~

However, it’s more common to see more **@** symbol abuse to declare **NSNumber** literals. Using this technique, you can just write **@** followed by an integer, a float, a double, or a boolean, and the compiler will produce an **NSNumber** instance.

~~~
NSNumber *integerTen = @10;
NSNumber *booleanTrue = @YES;
NSNumber *doublePi = @M_PI;
~~~

## Arrays

Code written before array literals (@[...]) were introduced had to create arrays using one of the various initializers that are available. The most common of these is arrayWithObjects, which is almost identical to the array literal syntax:

~~~
NSArray *villains = [NSArray arrayWithObjects:@"Weeping Angels", @"Cybermen", @"Daleks", @"Vashta Nerada", nil];
~~~

>Note, there is a nil at the end. If you fail to add that Xcode will give you a warning, “Missing sentinel in method dispatch” – Xcodespeak for “you missed off the nil, dummy.” This warning wasn’t there a few years ago, and missing off the final nil can cause weird and wonderful problems because NSArray needs it to know where your list of items ends.

You can loop in reverse using the reverseObjectEnumerator method.

~~~
for (NSString *villain in [villains reverseObjectEnumerator]) {
    NSLog(@"Can the Doctor defeat the %@? Yes he can!",  villain); 
}
~~~

You can index into an array just like in Swift, counting from 0.

~~~
NSLog(@"The %@ are my favorite villains.", villains[2]);
~~~

Older code written before subscripting was introduced (anything not rewritten since 2012 or earlier) will use the objectAtIndex method instead.

~~~
NSLog(@"The %@ are my favorite villains.", [villains objectAtIndex:2]);
~~~

### Basic Array Usage

Code completion is valuable for discovery: type the name of an array then press **Ctrl+space** to bring up the autocomplete options.

~~~
NSLog(@"The Doctor faced %ld villains in that episode.", (long)[villains count]);
NSLog(@"Daleks are villain number %ld.", (long)[villains indexOfObject:@"Daleks"]);
NSLog(@"The second villain was the %@.", [villains objectAtIndex:1]);
NSLog(@"The Doctor conquered these villains: %@.", [villains componentsJoinedByString:@", "]);
~~~

If you call **indexOfObject** using an object that doesn’t exist in the array, you get back a special value: **NSNotFound**. This is defined as a very large integer (9,223,372,036,854,775,807 on 64-bit systems, to be precise), which is just a magic number. Remember, Objective-C doesn’t have the concept of optional integers, so Apple have basically said “if the method must returns the number 9,223,372,036,854,775,807 it means the object wasn’t found.”

### Mutable Arrays

You create mutable arrays either using initializers from the **NSMutableArray** class or by calling **mutableCopy** on an existing **NSArray**.

~~~
NSMutableArray *villains = [@[@"Weeping Angels", @"Cybermen", @"Daleks", @"Vashta Nerada"] mutableCopy];
~~~

Once you have a mutable array, you can add individual objects using **addObject**, add multiple objects by using **addObjectsFromArray**, and insert objects using **insertObject:atIndex**. For removing, you can choose between **removeObject**, which removes all instances of an object in an array; **removeObjectAtIndex**, which removes the object at a precise index; and **removeAllObjects**, which leaves the array empty.

~~~
[villains insertObject:@"The Silence" atIndex:1];
[villains removeObjectAtIndex:3];
[villains removeAllObjects];
~~~

For all array methods that use an index, using an index that’s outside the array will cause a crash.

### Sorting

Our villains array contains several strings, so in Swift you would be given a **sort()** method to call to provide that same array in alphabetical order. Unlike Swift, Objective-C doesn’t provide built-in sorting for any data types, but it does provide some hooks where you can write your own – more or less equivalent to using **sort()** with a closure in Swift.

**NSString** has a built-in method called **compare**, which compares one string against another and returns whether string A comes before or after string B, or should be sorted the same. Again, this is almost the same as the closure you use with Swift’s **sort()**.

We can use **compare** to sort an array by using it with the **sortedArrayUsingSelector** method. You provide this with the name of a method to call (in our case, that’s compare), and it will use the result of that method to sort the array.

~~~
NSArray *sorted = [villains sortedArrayUsingSelector:@selector(compare:)];
~~~

**@selector** is almost identical to Swift’s **#selector** syntax, but it’s less forgiving: if you call a method that accepts a parameter you always need to include the colon, i.e. **compare:** rather than **compare**.

This approach to sorting is particularly useful when you create your own classes, because you can call any selector you want.

### Functional techniques

Swift does a good job of blending functional and imperative approaches to programming. In comparison, Objective-C is a bit thin on the ground, but you can sort of come close with three useful methods: **makeObjectsPerformSelector**, **enumerateObjectsUsingBlock**, and **filteredArrayUsingPredicate**.

**makeObjectsPerformSelector** is designed to run a method on every item in an array. It doesn’t return anything, but it’s commonly used for things like removing all child views from a parent.

~~~
[[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
~~~

The **enumerateObjectsUsingBlock** method is where blocks come in, which are a bit like proto-closures from Swift. That is, they are similar in design and purpose, and are cross- compatible so you can use them interchangeably, but Objective-C’s blocks don’t have the neat capture list syntax of Swift, and Objective-C’s captured values are mutable by default whereas Swift’s are copied.

Using enumerateObjectsUsingBlock we can rewrite the fast enumeration loop.

~~~
[villains enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
   NSLog(@"Can the Doctor defeat the %@? Yes he can!", obj);
}];
~~~

Objective-C’s block syntax is quite different from Swift’s: there’s a caret symbol (**^**) followed by a list of parameters in parentheses, then the contents of the block itself. In the code above, that means the contents of the block is just the **NSLog()** line, and it will receive three parameters: **obj**, **idx**, and **stop**.

The first one, **obj**, has the data type id, which is Objective-C’s version of Swift’s **AnyObject**.

The second one, **idx**, is the position of the current item in the array – it’s short for “index”.

The last parameter is a pointer to a boolean, which might seem bizarre at first: surely you can just refer to a boolean directly? Well, yes, but this parameter is used to bail out of the enumeration loop part way through. If it were a regular boolean, you could change its value in the block but that wouldn’t be visible outside the block. By passing a pointer to a boolean, you can modify its contents (“please stop looping now”) and that change will be visible outside the block.

To demonstrate the **stop** parameter, this example loops through several villains, but stops when it reaches the "Weeping Angels":

~~~
[villains enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
BOOL *stop) {
   if ([obj isEqualToString:@"Weeping Angels"]) {
      NSLog(@"Can the Doctor defeat the %@? Oh, apparently
not.", obj);
      *stop = true;
   } else {
      NSLog(@"Can the Doctor defeat the %@? Yes he can!", obj);
} }];
~~~

>Note the syntax: ***stop** means “change the value that **stop** is pointing to. Note also that even though **obj** is of type **id** – **AnyObject** – we can still call **isEqualToString** on it. If you try using code completion, you’ll see that Xcode offers you every possible code completion for every class, because it has no idea what **id** might actually be. Lovely.


>If you find block syntax difficult to remember, you should take comfort in knowing that http:// goshdarnblocksyntax.com/ exists.

That just leaves the **filteredArrayUsingPredicate** method. If you’ve used Core Data or CloudKit before, you’ll be familiar with the concept of **NSPredicate**: a class designed to store how data should be fetched or filtered. This can be used to emulate Swift’s **filter()** method, for example we could write a predicate that returns only villains that have names made up of two words.

~~~
NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bindings) {
   return [[obj componentsSeparatedByString:@" "] count] == 2;
}];

NSArray *twoWordVillains = [villains filteredArrayUsingPredicate:predicate];
~~~

### Key Paths

Key paths exist in Swift and are used for key-value observing. For example, you can monitor the progress of a **WKWebView** loading a web page by observing its **estimatedProgress** key path. In Objective-C, arrays have a method called **valueForKeyPath** where you can use collection operators to calculate information about your array. For example, you can use **@sum.self** on an integer array to have the sum of all items returned as an **NSNumber**.

~~~
NSArray *numbers = [NSArray arrayWithObjects:@1, @2, @3, @4, @5, nil];
NSNumber *sum = [numbers valueForKeyPath:@"@sum.self"];
NSNumber *avg = [numbers valueForKeyPath:@"@avg.self"];
NSNumber *min = [numbers valueForKeyPath:@"@min.self"];
NSNumber *max = [numbers valueForKeyPath:@"@max.self"];
NSLog(@"Total: %ld", (long)[sum integerValue]);
NSLog(@"Avg: %ld", (long)[avg integerValue]);
NSLog(@"Min: %ld", (long)[min integerValue]);
NSLog(@"Max: %ld", (long)[max integerValue]);
~~~

## Dictionaries

Dictionaries are provided by **NSDictionary**. As with Swift’s dictionaries, **NSDictionary** is unordered.

~~~
// dictionaries with literal syntax
NSDictionary *ships = @{
   @"Serenity": @"Firefly",
   @"Enterprise": @"Star Trek",
   @"Executor": @"Star Wars"
};
~~~

Before dictionary literals were introduced, dictionaries are created using dictionaryWithObjectsAndKeys, which accepts its parameters in the opposite order to Swift. Meaning you specify the value first, then the key.

To add to the confusion, you use commas to separate key/value pairs and each key and value. You also need to add the same “nil” at the end that you used when creating arrays.

~~~
NSDictionary *ships = [NSDictionary dictionaryWithObjectsAndKeys:@"Firefly", @"Serenity", @"Star Trek", @"Enterprise", @"Star Wars", @"Executor", nil];
~~~

This is definitely a place where spacing things out helps, because it’s visually easy to lose track of what’s a key and what’s a value. So, sensible developers usually write this instead:

~~~
NSDictionary *ships = [NSDictionary
dictionaryWithObjectsAndKeys:
   @"Firefly", @"Serenity",
   @"Star Trek", @"Enterprise",
   @"Star Wars", @"Executor",
   nil
];
~~~

Old and new syntax is also available when reading values back from arrays. To demonstrate this, here are two ways to print out the values in an array, new first then old:

~~~
for (NSString *key in ships) {
   NSLog(@"The ship %@ features in %@", key, ships[key]);
}

for (NSString *key in ships) {
   NSLog(@"The ship %@ features in %@", key, [ships objectForKey:key]);
}
~~~

As with arrays and strings, there’s an NSMutableDictionary class if you want to change the contents of a dictionary after creation. Again, you can create them using dedicated initializers, or using the mutableCopy method on a regular dictionary.

### Useful methods

Dictionaries have a **count** method that returns how many items are in there, as well as **allKeys** and **allValues** methods that return an array of all the keys and the values respectively.

You’ll also find an **enumerateKeysAndObjectsUsingBlock** method, which works identically to the **enumerateObjectsUsingBlock** method of **NSArray**, except you get the keys and values.

## Sets

Objective-C has two ways of creating sets: **NSSet** and **NSCountedSet**. Cunningly, **NSSet** has a mutable counterpart in **NSMutableSet**, but **NSCountedSet** is automatically mutable.

~~~
NSSet *odd = [NSSet setWithObjects:@1, @3, @5, @7, @9, nil];
NSSet *even = [NSSet setWithObjects:@2, @4, @6, @8, @10, nil];
NSSet *combined = [odd setByAddingObjectsFromSet:even];
NSMutableSet *mutable = [combined mutableCopy];
[mutable addObject:@0];
[mutable removeAllObjects];
~~~

You can create sets using **setWithObjects** like above, or use **setWithArray** to create a set from an existing **NSArray**.

Sets are faster than arrays for determining whether they contain an object:
1. because they are unordered, so objects are accessed using a hash, and 
2. because objects must appear only once.

**NSCountedSet** bends the rule a little: objects can only appear once inside it, but each time you add or remove an item it keeps track of how many times it would have appeared. This makes it an extremely fast way to count the number of times objects appear in a collection.

To give you a working example, the code below creates a counted set of several numbers, then prints out how often each number appears using the countForObject method.

~~~
NSCountedSet *numbers = [NSCountedSet setWithObjects: @1, @3, @2, @8, @3, @6, @8, @8, @5, @1, @6, @3, nil];
for (NSString *value in [numbers allObjects]) {
   NSLog(@"%@ appears %ld times", value, [numbers countForObject:value]);
}
~~~

## Generics

~~~
NSArray *names = @[@"Sophie", @"Alexandra", @"Charlotte", @"Isabella"];
for (NSString *name in names) {
   NSLog(@"%@ is %ld letters.", name, [name length]);
}

NSArray *numbers = @[@42, @556, @69, @3.141];
for (NSString *number in numbers) {
   NSLog(@"%@ is %ld letters.", number, [number length]);
}
~~~

The numbers array was created using NSNumber literal syntax, not NSString - that code should fail. And yet it compiles without warnings or errors.

That code will build with no hiccups, but crash at runtime because it's trying to make strings out of numbers.

Swift solved this problem by introducing generics: specialized forms of arrays, dictionaries, and sets that can accept only one type of data. This wasn’t available in Objective-C when Swift was introduced, which meant a lot of Apple’s APIs were less than stellar in Swift.

The good news is that generics were introduced to Objective-C the following year, but the bad news is that they aren’t very good – certainly nothing like Swift’s generics.

They use a technique called type erasure, which is a fancy way of saying that they are implemented as syntactic sugar: the compiler sees them and can sometimes warn you if you use them incorrectly, but when the code is built the generics are effectively discarded.

This means they are really beneficial for Swift developers because it means Apple’s APIs have been updated to return strongly typed arrays, dictionaries, and sets, but less beneficial for Objective-C developers where they are a bit limp.

If you create an array designed to hold a specific type, Xcode will warn you if you try to add a different type.

~~~
NSMutableArray<NSString *> *names = [NSMutableArray arrayWithCapacity:4];
[names addObject:@"Sophie"];
[names addObject:@42];
~~~

Notice that the type is specified inside angle brackets **<NSString *>**. 

If you try to read a value from an array and store it in a different type, it will warn you.

~~~
NSNumber *number = names[0];

NSArray<NSNumber *> *numbers = @[@42, @556, @69, @3.141];
for (NSString *number in numbers) {
   NSLog(@"%@ is %ld letters.", number, [number length]);
}
~~~

That code still compiles just fine, even though we’ve now specifically given the array the **NSNumber** type.

Alongside generic arrays, you can also make generic dictionaries and generic sets, and they all work in the same way. With dictionaries you need to specify a type for the key and another for the value.

~~~
NSDictionary<NSString *, NSNumber *> *villains = @{ @"Daleks": @100, @"Cybermen": @80 };
~~~

So: generics exist in Objective-C, but 
1. they aren’t anywhere like as beneficial as they are in Swift, and 
2. they are so new that most projects don’t use them.