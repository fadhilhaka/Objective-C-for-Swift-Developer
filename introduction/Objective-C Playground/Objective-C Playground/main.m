//
//  main.m
//  Objective-C Playground
//
//  Created by Fadhil Hanri on 09/06/21.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // variable
        int i = 10;
        
        if (i == 10) {
           NSLog(@"Hello, World!");
        }
        
        // switch/case
        i = 20;
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
        
        i = 10;
        switch (i) {
            case 10:
            {
                int foo = 1;
                NSLog(@"It's something else, count: %d", foo);
            }
        }
        
        // loops
        NSArray *names = @[@"Laura", @"Janet", @"Kim"];
        for (NSString *name in names) {
           NSLog(@"Hello, %@", name);
        }
        
        for (int i = 1; i <= 5; ++i) {
           NSLog(@"%d * %d is %d", i, i, i * i);
        }
        
        // nil coalescing
        NSString *name = nil;
        NSLog(@"Hello, %@!", name ?: @"Anonymous");
        
        // const pointers
        NSString *first = @"Hello";
        NSLog(@"%p", first);
        first = @"World";
        NSLog(@"%p", first);
        
        // integers
        NSInteger j = 10;
        NSLog(@"%ld", (long)j);
        
//        NSInteger k = 10;
//        NSLog(@"%d", k);
        
        NSString *str = @"Reject common sense to make the impossible possible!";
        NSLog(@"%@", str);
    }
    return 0;
}
