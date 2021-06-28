//
//  main.m
//  SciFiQuotes
//
//  Created by Fadhil Hanri on 29/06/21.
//

#import <Foundation/Foundation.h>
#import "FHApp.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Get a path to a file on the user’s directory.
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
        NSString *desktopPath = [paths objectAtIndex:0];
        
        FHApp *app = [[FHApp alloc] initWithFile:[desktopPath stringByAppendingPathComponent:@"quotes.txt"]];
        [app printQuote];
    }
    return 0;
}
