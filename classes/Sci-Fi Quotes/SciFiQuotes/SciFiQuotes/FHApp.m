//
//  SFApp.m
//  SciFiQuotes
//
//  Created by Fadhil Hanri on 29/06/21.
//

#import "FHApp.h"

@implementation FHApp

- (instancetype)initWithFile:(NSString*)filePath {
    if (self == [super init]) {
        NSLog(@"Prepare quotes!");
        
        NSError *error;
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"txt"];
        NSString *contents = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        
        if (error != nil) {
            NSLog(@"Fatal error: %@", [error localizedDescription]);
            exit(0);
        }
        
        NSArray *contentLines = [contents componentsSeparatedByString:@"\n"];
        
        self.quotes = [NSMutableArray arrayWithCapacity:[contentLines count]];
        
        for (NSString *line in contentLines) {
            FHQuote *quote = [[FHQuote alloc] initWithLine:line];
            
            if (quote != nil) {
                [self.quotes addObject:quote];
            }
        }
    }
    return self;
}

- (void)printQuote {
    NSInteger random = arc4random_uniform((u_int32_t) [self.quotes count]);
    FHQuote *selectedQuote = self.quotes[random];
    
    printf("%s\n", [selectedQuote.quote cStringUsingEncoding:NSUTF8StringEncoding]);
    printf("\t – %s\n", [selectedQuote.person cStringUsingEncoding:NSUTF8StringEncoding]);
}

@end
