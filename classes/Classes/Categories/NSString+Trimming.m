//
//  NSString+Trimming.m
//  Classes
//
//  Created by Fadhil Hanri on 24/06/21.
//

#import "NSString+Trimming.h"

@implementation NSString (Trimming)

- (NSString*)fh_stringByTrimming {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
