//
//  SFApp.h
//  SciFiQuotes
//
//  Created by Fadhil Hanri on 29/06/21.
//

#import <Foundation/Foundation.h>
#import "FHQuote.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHApp : NSObject

@property NSMutableArray<FHQuote *> *quotes;

- (instancetype)initWithFile:(NSString*)filePath;
- (void)printQuote;

@end

NS_ASSUME_NONNULL_END
