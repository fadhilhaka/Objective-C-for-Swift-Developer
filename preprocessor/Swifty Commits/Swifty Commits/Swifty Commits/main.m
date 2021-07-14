//
//  main.m
//  Swifty Commits
//
//  Created by Fadhil Hanri on 14/07/21.
//

#import <Foundation/Foundation.h>
#import "SCApp.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *repo = @"apple/swift";
        
        if (argc == 2) {
            repo = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        }
        
        SCApp *app = [SCApp new];
        [app fetchCommitsFromRepo:repo];
    }
    return 0;
}
