//
//  UZStreamingBuffer.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UZAudioFrame.h"
#import "UZVideoFrame.h"


/** current buffer status */
typedef NS_ENUM (NSUInteger, UZBuffferState) {
    UZBuffferState_Unknown = 0,      // Unknown
    UZBuffferState_Increase = 1,    // Poor buffer status should reduce bit rate
    UZBuffferState_Decline = 2      // If the buffer status is good, the code rate should be increased
};

@class UZStreamingBuffer;
/** this two method will control videoBitRate */
@protocol UZStreamingBufferDelegate <NSObject>
@optional
/** Current buffer changes (increase or decrease) Callback based on the updateInterval time in the buffer */
- (void)streamingBuffer:(nullable UZStreamingBuffer *)buffer bufferState:(UZBuffferState)state;
@end

@interface UZStreamingBuffer : NSObject


/** The delegate of the buffer. buffer callback */
@property (nullable, nonatomic, weak) id <UZStreamingBufferDelegate> delegate;

/** current frame buffer */
@property (nonatomic, strong, readonly) NSMutableArray <UZFrame *> *_Nonnull list;

/** buffer count max size default 1000 */
@property (nonatomic, assign) NSUInteger maxCount;

/** count of drop frames in last time */
@property (nonatomic, assign) NSInteger lastDropFrames;

/** add frame to buffer */
- (void)appendObject:(nullable UZFrame *)frame;

/** pop the first frome buffer */
- (nullable UZFrame *)popFirstObject;

/** remove all objects from Buffer */
- (void)removeAllObject;

@end
