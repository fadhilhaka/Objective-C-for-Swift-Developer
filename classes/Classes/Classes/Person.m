//
//  Person.m
//  Classes
//
//  Created by Fadhil Hanri on 15/06/21.
//

#import "Person.h"

@implementation Person

@synthesize name = _name;

- (NSString*)name {
   NSLog(@"Reading name!");
   return _name;
}

- (void)setName:(NSString *)newName {
   NSLog(@"Writing name!");
   _name = newName;
}

- (void)printGreeting {
    NSLog(@"Hey Yo! %@!", self.name);
}

- (void)printGreeting:(NSString*)greeting {
    NSLog(@"Hey %@.", greeting);
}

- (void)printGreetingToo:(NSString*)greeting {
    NSLog(@"Hey %@.", greeting);
}

- (void)printGreetingTo:(NSString*)name atTimeOfDay:(NSString*)time {
    if ([time isEqualToString:@"morning"]) {
        NSLog(@"Good morning, %@!", self.nameToo);
    } else {
        NSLog(@"Good evening, %@!", name);
    }
}

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

@end
