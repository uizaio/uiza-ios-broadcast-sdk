//
//  NSMutableArray+UZAdd.m
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "NSMutableArray+UZAdd.h"

@implementation NSMutableArray (YYAdd)

- (void)lfRemoveFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

- (id)lfPopFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self lfRemoveFirstObject];
    }
    return obj;
}

@end
