//
//  SFQuote.h
//  SciFiQuotes
//
//  Created by Fadhil Hanri on 29/06/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHQuote : NSObject

@property (strong, nonatomic, nullable) NSString *quoteMock;
@property NSString *quote;
@property NSString *person;

- (nullable instancetype)initWithLine:(NSString*)line;

@end

NS_ASSUME_NONNULL_END
