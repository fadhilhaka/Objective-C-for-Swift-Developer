//
//  Person.m
//  Classes
//
//  Created by Fadhil Hanri on 15/06/21.
//

#import "Person.h"

@interface Person ()
@property (readwrite) NSString *nameToo;
@end

@implementation Person

@synthesize name = _name;

- (NSString*)name {
    NSLog(@"Reading name!");
    if (_name == nil) {
        return @"Anonymous";
    } else {
        return _name;
    }
}

- (void)setName:(NSString *)newName {
    NSLog(@"Writing name!");
    _name = newName;
}

- (instancetype)initWithName:(NSString*)name {
    if (self == [super init]) {
        NSLog(@"Init name!");
        self.name = name;
    }
    return self;
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

- (NSString*)fetchGreetingForTime:(NSString*)time {
    //    Test apply nil to property
        NSString *str = nil;
        self.name = str;
    
    return [NSString stringWithFormat:@"Good %@, %@!", time, self.name];
}

@end
