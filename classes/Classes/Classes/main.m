//
//  main.m
//  Classes
//
//  Created by Fadhil Hanri on 15/06/21.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "NSString+Trimming.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
//        Person *person = [Person new];
        Person *person = [[Person alloc] initWithName:@"James Bond"];
        
        NSString *trimmedName = [person.name fh_stringByTrimming];
        NSLog(@"Hai %@", trimmedName);
        
        NSString *greeting = [person fetchGreetingForTime:@"night"];
        NSLog(@"%@", greeting);
        
//        person->name = @"Joy";
        
//        person.name = @"Joy";
//        person.nameToo = @"Anya";
//        [person setNameToo:@"Taylor"];
//        [person printGreeting];
//        [person printGreeting:@"Welcome!"];
//        [person printGreetingTo:@"Anya Taylor-Joy" atTimeOfDay:@"morning"];
//        [person performSelector:@selector(printGreeting:) withObject:@"Taylor"];
    }
    return 0;
}
