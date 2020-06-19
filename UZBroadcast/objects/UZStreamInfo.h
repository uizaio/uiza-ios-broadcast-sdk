//
//  UZStreamInfo.h
//  UZLiveKit
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UZAudioConfiguration.h"
#import "UZVideoConfiguration.h"



/// Live state
typedef NS_ENUM (NSUInteger, UZLiveState){
    /// Ready
    UZLiveState_Ready = 0,
    /// Pending
    UZLiveState_Pending = 1,
    /// Start
    UZLiveState_Start = 2,
    /// Stop
    UZLiveState_Stop = 3,
    /// Error
    UZLiveState_Error = 4,
    ///  Refresh
    UZLiveState_Refresh = 5
};

typedef NS_ENUM (NSUInteger, UZSocketErrorCode) {
    UZSocketErrorCode_PreView = 201,              /// Preview failed
    UZSocketErrorCode_GetStreamInfo = 202,        /// Failed to obtain streaming information
    UZSocketErrorCode_ConnectSocket = 203,        /// Socket connection failed
    UZSocketErrorCode_Verification = 204,         /// Authentication server failed
    UZSocketErrorCode_ReConnectTimeOut = 205      /// Reconnect server timeout
};

@interface UZStreamInfo : NSObject

@property (nonatomic, copy) NSString *streamId;

#pragma mark -- FLV
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSInteger port;
#pragma mark -- RTMP
@property (nonatomic, copy) NSString *url;          ///< Upload address (just use RTMP)
///Audio configuration
@property (nonatomic, strong) UZAudioConfiguration *audioConfiguration;
///Video configuration
@property (nonatomic, strong) UZVideoConfiguration *videoConfiguration;

@end
