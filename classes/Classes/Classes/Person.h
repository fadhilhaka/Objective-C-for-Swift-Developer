//
//  Person.h
//  Classes
//
//  Created by Fadhil Hanri on 15/06/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject
//{
//    @public
//    NSString *name;
//}
@property NSString *name;
@property NSString *nameToo;

- (void)printGreeting;
- (void)printGreeting:(NSString*)greeting;
- (void)printGreetingToo:(NSString*)greeting;
- (void)printGreetingTo:(NSString*)name atTimeOfDay:(NSString*)time;

@end

NS_ASSUME_NONNULL_END
