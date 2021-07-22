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