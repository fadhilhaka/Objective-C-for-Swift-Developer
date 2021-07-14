//
//  SCApp.h
//  Swifty Commits
//
//  Created by Fadhil Hanri on 14/07/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCApp : NSObject

- (void)fetchCommitsFromRepo:(NSString*)repo;

@end

NS_ASSUME_NONNULL_END
