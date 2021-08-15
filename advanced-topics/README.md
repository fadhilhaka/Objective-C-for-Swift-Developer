# Advanced Topics

## Automatic Reference Counting

Memory management is something that few Swift developers need to worry about. This isn’t an accident: important lessons were learned over the lifetime of Objective-C that helped shape Swift’s approach to memory, and really what Swift developers use is the culmination of many years of Objective-C evolution.

Both Swift and Objective-C use a system called Automatic Reference Counting, or ARC for short.

Objective-C has always used reference counting for its memory management. When you create an object it has 1 reference pointing to it; when you store it somewhere else, there are 2 references; when you free it in the first place, there’s now only one reference; and when you free it in the second place the last reference goes – the object gets destroyed.

For many years, Objective-C required developers to use special method calls to manage memory: **retain** meant “add a reference,” **release** meant “remove a reference,” and **autorelease** meant “remove a reference at some point in the future.”

If you retained something without releasing it, that memory got leaked. If you released something when the retain count was lower than you thought, it got destroyed prematurely.

What **autorelease** means is “I want to create this object, but I don’t want to own it, so please free it for me later on.” This is usually when the current run loop ends, but it can be sooner.

It’s useful when passing objects around: if you write a method that must create an object and pass it to someone else, usually you would autorelease that object so that the caller would be responsible for its memory.

Now, why does all this matter? Well, it turns out that this paradigm – create, autorelease, return – is so useful that it’s built into all sorts of Foundation calls. You’ve already seen method calls like this:

~~~
NSArray *array1 = [[NSArray alloc] initWithObjects:@1, @2, @3,
nil];
NSArray *array2 = [NSArray arrayWithObjects:@1, @2, @3, nil];
~~~

And now you can understand the difference between those two calls: pre-ARC, **array1** would have a reference count of 1, whereas **array2** would have a reference count of 1 but would have a **release** call queued up because it has an implicit **autorelease** – so it effectively has a retain count of 0.

How do you know that **arrayWithObjects** has an implicit **autorelease** attached? Well, it turns out that Apple has a set of naming conventions that are extremely precise: any time you call a method that starts with **alloc**, **new**, **copy**, or **mutableCopy**, you are explicitly creating an object and accepting that it will be **retained**.

Any time you create objects using other methods – **stringWithFormat** and so on – you are saying you don’t want to own the object, so it will be **autoreleased**.

Where things got confusing was when you introduced properties, because when you declared a **property** as **retain** (the equivalent of **strong** in modern code) it would automatically increment the reference count by 1.

So, if you used **[[NSArray alloc] init...]** you would get a reference count of 1, then assigning to a **retain** property would up the reference count to 2 – you might have accidentally created a leak.

Seeing code like this became commonplace:

~~~
self.someProperty = [[[SomeClass alloc] init] autorelease];
~~~

Worse, the **retain** part of a property only happened if you used the property. If you accessed the **ivar** directly, the object wouldn’t be retained, and often you’d end up with a zombie – an object that is dead, but you think it’s still alive.

If you did this, you would end up releasing an object too soon, and sending messages to who knows what in the future.

>NOTE: Zombie is the actual name for this – there’s still a checkbox in Xcode for “Enable Zombie Objects”.

### How ARC Works

ARC works by automatically adding calls to retain, release, and autorelease during compilation.

Swift also uses ARC, although it’s less obvious because the distinction between **initWith...** and **arrayWith...** is gone. However, one area where the two languages are similar is our old friend the strong reference cycle: ARC is unable to resolve **strong** reference cycles automatically, so you need to use **weak** references to break them.

Both Objective-C and Swift use **strong** by default for all objects, but both also allow you to use the **weak** keyword for properties that should not add to the reference count of the value being stored. This has identical meaning: if the value is not stored somewhere else, it will be destroyed.

~~~
@property (weak) SomeDataType *delegate;
~~~

Prior to ARC, Objective-C developers used the **assign** property attribute for both primitive types and weakly held objects, but there’s a subtle difference between **assign** and **weak**: when a **weak property** is finally destroyed the variable gets set to **nil**, but when an **assign property** is destroyed it does not.

This creates a dangling pointer: the property points to some place in RAM where the object used to be, but that could now be something else entirely.

Remember, sending a message to nil is OK in Objective-C, but sending a message to an unknown chunk of memory is manifestly a Really Bad Move.

You should also use **weak** to break strong reference cycles in blocks, although the syntax used to declare weak variables is **__weak**.

### Side Effects of ARC

ARC operates at such a fundamental level in Objective-C that it’s easy to create compile errors if you use it wrongly, or inefficient code even if you think you’re using it correctly.

To give you an example, imagine you wanted to create a class to help people move house. This class has two properties, an old address and a new address.

~~~
@property NSString *oldAddress;
@property NSString *newAddress;
~~~

Sadly, that won’t compile. Remember, properties get synthesized into accessor methods, so those two properties will generate the four methods **oldAddress**, **setOldAddress**, **newAddress**, and **setNewAddress**.

Those four are what ARC sees, and remember: ARC is built upon Apple’s strict naming conventions. So, when it sees a method named **newAddress**, it expects that to create a new retained object, which it doesn’t. This is against the rules in ARC, hence the compile error.

The solution is to specify a custom getter for the property to work around the naming rules.

~~~
@property (getter=getNewAddress) NSString *newAddress;
~~~

Learning to think like ARC – bizarre as that might sound – is the key to writing efficient code. You see, the compiler has to figure out where to insert **retain**, **release**, and **autorelease** calls, and it plays it safe because if it over-retains or over-releases then ARC causes serious problems.

The best example of this is with **NSError**.

~~~
NSError *error;
NSString *str = [NSString stringWithContentsOfFile:@"somefile.txt" usedEncoding:nil error:&error];
~~~

That code is very common, and I normally encourage people to write it that way when they are learning Objective-C because it’s easier to understand. But once you advance a bit further, you might spot that it contains an inconsistency: ARC uses **strong** for objects by default, whereas the **stringWithContentsOfFile** method wants an **autoreleasing NSError** – a subtly different error type.

Rather than force you to fix these problems, ARC picks up the slack on your behalf. First, it explicitly makes the error strong, like this:

~~~
NSError * __strong error;
~~~

Then it introduces a new temporary NSError object that is autoreleasing, and copies in whatever value error already has:

~~~
NSError * __autoreleasing temp = error;
~~~

This temp error is the correct data type for stringWithContentsOfFile, so it will be called next:

~~~
NSString *str = [NSString stringWithContentsOfFile:@"somefile.txt" usedEncoding:nil error:&temp];
~~~

Finally, it will assign temp back to error so that the rest of our code carries on working as before:

~~~
error = temp;
~~~

If you want to avoid this extra work being done, the correct approach is to declare your errors using **__autoreleasing**, like this:

~~~
NSError * __autoreleasing error;
~~~

One other side effect of using ARC is that some third-party libraries have not been updated to use it. As each year goes by this list shrinks and shrinks, but if you join an Objective-C project that is clinging onto libCrustyButEssential for dear life, expect to see the compiler flag **-fno-objc-arc** used for some files under the **Build Phases** tab.

**Technically Correct Way to Write**

You will often see people use ARC qualifiers before the class name, like this:

~~~
__weak NSString *name = @"Bilbo Baggins";
~~~

In our code so far, we’ve been using “**ClassName * Qualifier Identifier**”, like this:

~~~
NSString * __weak name = @"Bilbo Baggins";
~~~

Both do the same thing, but only the latter is officially considered the right way. As Apple puts it, “other variants are technically incorrect but are forgiven by the compiler.”

This starts to matter when you see more complicated usages like this:

~~~
NSError * _Nullable __autoreleasing * _Nullable
~~~

The pointer can be nil, the pointer pointer can be nil, and there’s some autoreleasing thrown in for good luck. That’s actually the formal definition of the NSError parameter to stringWithContentsOfFile, so it’s not exactly unusual code!

### Dealing with Core Foundation

One area where Swift’s ARC implementation is significantly better than Objective-C’s is when you have to handle Core Foundation objects. ARC is smart enough to know that Core Foundation types that follow the naming conventions are unowned, but it will still force you to cast them to **id** like this:

~~~
NSArray *colors = [NSArray arrayWithObject:(id)[[UIColor whiteColor] CGColor]];
~~~

When it comes to more complex Core Foundation usage, you need to manage them yourself. **ARC will not automatically free Core Foundation objects you create**.

You need to use **CFRelease()** or the domain-specific release function that matches how you created the object.

For example, creating and destroying a **CGPDFDocumentRef** looks like this:

~~~
CGPDFDocumentRef documentRef = CreatePDFDocumentRef(pdfURL);
CGPDFDocumentRelease(documentRef);
~~~

[Transitioning to ARC Release Notes](https://developer.apple.com/library/mac/releasenotes/ObjectiveC/RN- TransitioningToARC/Introduction/Introduction.html)

## Autorelease Pools

When you create objects that aren’t retained, they will be autoreleased by ARC at some later date. That “later date” is usually the end of the current run loop, which means “when all your code has finished executing, and a new set of events come in.”

Sometimes this can cause problems: if you create an array of objects, or create objects that use lots of RAM, you might want to be sure they are definitely destroyed now rather than waiting until all code has finished.

~~~
for (NSInteger i = 0; i < 100; ++i) {
   ComplexObject *obj = [ComplexObject new];
   [obj doLotsOfWork];
}
~~~

It doesn’t matter what **ComplexObject** is or what **doLotsOfWork** entails, other than it being a placeholder for “lots of objects are being created here.”

We don’t know when those objects will be destroyed. ARC might destroy some or all of them immediately using **release**, or it might queue some or all of them up for destruction using **autorelease** – that’s an implementation detail we don’t have much control over.

However, if **autorelease** is used, then that loop will run 100 times before the autoreleased objects are released. That could mean your app chewing up huge amounts of RAM, most of which is objects awaiting deallocation.

The solution to this is to use **@autoreleasepool** blocks. We already have one of these in main.m, but you can create them wherever you need. Any code you place inside an **@autoreleasepool** block will automatically have its autoreleased objects destroyed when the block ends.

~~~
for (NSInteger i = 0; i < 100; ++i) {
   @autoreleasepool {
      ComplexObject *obj = [ComplexObject new];
      [obj doLotsOfWork];
   }
}
~~~

That allocates and destroys the same amount of memory, but now the high water mark – the total amount of memory in use at any one time – is significantly lower, because we free autoreleased objects each time the loop goes around.

>NOTE: Some methods have their own autorelease pools for exactly this situation. For example, the **enumerateObjectsUsingBlock** on **NSArray** and **enumerateSubstringsInRange** on **NSString** both wrap their blocks inside **@autoreleasepool** to ensure the high water mark stays low.

## Objective-C++

Objective-C is a strict superset of C, which means that any valid C code is valid Objective-C. You can, if you wish, write any of your files using Objective-C++, which is where any valid C++ code is valid Objective-C.

C++'s creator, Bjarne Stroustrup, once said that “C makes it easy to shoot yourself in the foot; C++ makes it harder, but when you do, it blows away your whole leg.”

There are some good reasons to switch to Objective-C++. The STL includes real generics like vector and map rather than the Swift-focused generics found in Objective-C. 

It also introduces features we’re used to in Swift, such as operator overloading and type inference, which means that code like this compiles just fine:

~~~
auto myString = @"Hello, world!";
~~~

There are some downsides to Objective-C++, some technical and some mental.

First, the Objective-C++ compiler is noticeably slower than the Objective-C compiler, so if you have a large project then you need to think twice before moving to Objective-C++. 

This is mitigated by the fact that you opt in to Objective-C++ on a per-file basis, so you can enable it for only one file if you wish.

You might also find that you suddenly get some compiler warnings you didn’t have previously, even before you write any C++ code. This is because C++ compilers are stricter than C compilers, but that’s OK – fix any problems that come up and you’ll be doing your code a favor even if you ultimately switch away from Objective-C++

There are a couple of mental downsides, largely caused by the fact that Objective-C and C++ are two very different languages.

Pushing them together in one file can really hurt your head: you can’t mix Objective-C and C++ classes when you want inheritance, and you can’t call a C++ object using Objective-C syntax or vice versa, so it’s down to you to make sure the two live in a together-but-separately manner.

>NOTE: Facebook’s Pop animation library is written in Objective-C++, as is WKWebView – largely thanks to WebKit being a C++ project.

To enable Objective-C++ support for a file, all you need to do is rename the file extension. It’s .m by default, but if you change it to .mm then you just enabled Objective-C++