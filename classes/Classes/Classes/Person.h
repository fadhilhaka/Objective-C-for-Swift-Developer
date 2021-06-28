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
@property (null_resettable) NSString *name;
@property (readonly) NSString *nameToo;

- (nonnull instancetype)initWithName:(nonnull NSString*)name;
- (void)printGreeting;
- (void)printGreeting:(nonnull NSString*)greeting;
- (void)printGreetingToo:(nonnull NSString*)greeting;
- (void)printGreetingTo:(nonnull NSString*)name atTimeOfDay:(nonnull NSString*)time;
- (nonnull NSString*)fetchGreetingForTime:(nonnull NSString*)time;

@end

NS_ASSUME_NONNULL_END
