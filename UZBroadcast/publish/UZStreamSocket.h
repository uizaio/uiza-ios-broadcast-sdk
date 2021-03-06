//
//  UZStreamSocket.h
//  UZBroadcast
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UZStreamInfo.h"
#import "UZStreamingBuffer.h"
#import "UZBroadcastDebug.h"



@protocol UZStreamSocket;
@protocol UZStreamSocketDelegate <NSObject>

/** callback buffer current status */
- (void)socketBufferStatus:(nullable id <UZStreamSocket>)socket status:(UZBuffferState)status;
/** callback socket current status */
- (void)socketStatus:(nullable id <UZStreamSocket>)socket status:(UZBroadcastState)status;
/** callback socket errorcode */
- (void)socketDidError:(nullable id <UZStreamSocket>)socket errorCode:(UZSocketErrorCode)errorCode;
@optional
/** callback debugInfo */
- (void)socketDebug:(nullable id <UZStreamSocket>)socket debugInfo:(nullable UZBroadcastDebug *)debugInfo;
@end

@protocol UZStreamSocket <NSObject>
- (void)start;
- (void)stop;
- (void)sendFrame:(nullable UZFrame *)frame;
- (void)setDelegate:(nullable id <UZStreamSocketDelegate>)delegate;
@optional
- (nullable instancetype)initWithStream:(nullable UZStreamInfo *)stream;
- (nullable instancetype)initWithStream:(nullable UZStreamInfo *)stream reconnectInterval:(NSInteger)reconnectInterval reconnectCount:(NSInteger)reconnectCount;
@end
