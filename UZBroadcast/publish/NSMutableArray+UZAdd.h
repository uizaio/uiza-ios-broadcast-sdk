//
//  NSMutableArray+UZAdd.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (YYAdd)

/**
   Removes and returns the object with the lowest-valued index in the array.
   If the array is empty, it just returns nil.

   @return The first object, or nil.
 */
- (nullable id)lfPopFirstObject;

@end
