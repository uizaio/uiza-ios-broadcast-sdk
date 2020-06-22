//
//  UZFrame.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UZFrame : NSObject

@property (nonatomic, assign,) uint64_t timestamp;
@property (nonatomic, strong) NSData *data;
/// flv or rtmp header
@property (nonatomic, strong) NSData *header;

@end
