//
//  SCApp.m
//  Swifty Commits
//
//  Created by Fadhil Hanri on 14/07/21.
//

#import "SCApp.h"

@implementation SCApp

- (void)fetchCommitsFromRepo:(NSString*)repo {
    if (![self checkRepoIsValid:repo]) {
        exit(0);
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/commits", repo];
    NSURL *url = [NSURL URLWithString:urlString];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
    
    if (error != nil) {
        NSLog(@"Fatal error 1: %@", [error localizedDescription]);
        exit(0);
    }
    
    // decode the NSData into an array of dictionaries
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    // if there was an error, bail out
    if (error != nil) {
        NSLog(@"Fatal error 2: %@", [error localizedDescription]);
        exit(0);
    }
    
    // loop through each dictionary in the array
    for (NSDictionary *entry in json) {
        // pull interesting data into variables
        NSString *name = entry[@"commit"][@"author"][@"name"] ?: @"Anonymous";
        NSString *email = entry[@"commit"][@"author"][@"email"] ?: @"-";
        NSString *date = entry[@"commit"][@"author"][@"date"] ?: @"-";
        NSString *message = entry[@"commit"][@"message"] ?: @"-";
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *dateFromStr = [dateFormatter dateFromString:date];
        [dateFormatter setDateFormat:@"EEEE, d MMMM yyyy"];
        date = [dateFormatter stringFromDate:dateFromStr];
        
        // remove line breaks for easier reading
        message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        
        // print it all out
        printf("Commit by %s(%s) at %s.\nCommit message: %s\n", [name cStringUsingEncoding:NSUTF8StringEncoding], [email cStringUsingEncoding:NSUTF8StringEncoding], [date cStringUsingEncoding:NSUTF8StringEncoding], [message cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

- (BOOL)checkRepoIsValid:(NSString*)repo {
    __block int slashCount = 0;
    [repo enumerateSubstringsInRange:NSMakeRange(0, [repo length])
                             options:0
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        // Get warning: Implicit conversion loses integer precision: 'NSUInteger' (aka 'unsigned long') to 'unsigned int'
        // https://stackoverflow.com/questions/16918826/objective-c-implicit-conversion-loses-integer-precision-nsuinteger-aka-unsig/16918980
        // Change (unsigned int) to NSUInteger
        NSUInteger len = [substring length];
        char buffer[len];
        
        [substring getCharacters:buffer range:NSMakeRange(0, len)];
        
        for (int i = 0; i < len; i++) {
            NSString *current = [NSString stringWithFormat:@"%c", buffer[i]];
            
            if ([current isEqual:@"/"]) {
                slashCount += 1;
            }
        }
    }];
    
    if (slashCount != 1) {
        NSLog(@"Error: Invalid repo's name.");
        return FALSE;
    }
    
    return TRUE;
}

@end
