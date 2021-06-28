//
//  SFQuote.m
//  SciFiQuotes
//
//  Created by Fadhil Hanri on 29/06/21.
//

#import "FHQuote.h"

@implementation FHQuote

- (instancetype)initWithLine:(NSString*)line {
    if (self == super.init) {
        NSArray *split = [line componentsSeparatedByString:@"/"];
        
        if ([split count] != 2) {
            return nil;
        } else {
            self.quote = split[0];
            self.person = split[1];
        }
        
    }
    return self;
}

@end
