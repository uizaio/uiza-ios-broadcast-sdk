//
//  UZStreamingBuffer.m
//  UZLiveKit
//
//  Created by Nam Nguyen on 6/18/20.
//  Copyright © 2020 namnd. All rights reserved.
//

#import "UZStreamingBuffer.h"
#import "NSMutableArray+UZAdd.h"

static const NSUInteger defaultSortBufferMaxCount = 5; /// Sort within 5
static const NSUInteger defaultUpdateInterval = 1; /// Update frequency is 1s
static const NSUInteger defaultCallBackInterval = 5; /// interval 5s
static const NSUInteger defaultSendBufferMaxCount = 600; /// buffer size is 600

@interface UZStreamingBuffer (){
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray <UZFrame *> *sortList;
@property (nonatomic, strong, readwrite) NSMutableArray <UZFrame *> *list;
@property (nonatomic, strong) NSMutableArray *thresholdList;

/** Handle buffer buffer situation */
@property (nonatomic, assign) NSInteger currentInterval;
@property (nonatomic, assign) NSInteger callBackInterval;
@property (nonatomic, assign) NSInteger updateInterval;
@property (nonatomic, assign) BOOL startTimer;

@end

@implementation UZStreamingBuffer

- (instancetype)init {
    if (self = [super init]) {
        
        _lock = dispatch_semaphore_create(1);
        self.updateInterval = defaultUpdateInterval;
        self.callBackInterval = defaultCallBackInterval;
        self.maxCount = defaultSendBufferMaxCount;
        self.lastDropFrames = 0;
        self.startTimer = NO;
    }
    return self;
}

- (void)dealloc {
}

#pragma mark -- Custom
- (void)appendObject:(UZFrame *)frame {
    if (!frame) return;
    if (!_startTimer) {
        _startTimer = YES;
        [self tick];
    }

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    if (self.sortList.count < defaultSortBufferMaxCount) {
        [self.sortList addObject:frame];
    } else {
        /// Sort
        [self.sortList addObject:frame];
		[self.sortList sortUsingFunction:frameDataCompare context:nil];
        /// Drop frame
        [self removeExpireFrame];
        /// Add to buffer
        UZFrame *firstFrame = [self.sortList lfPopFirstObject];

        if (firstFrame) [self.list addObject:firstFrame];
    }
    dispatch_semaphore_signal(_lock);
}

- (UZFrame *)popFirstObject {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    UZFrame *firstFrame = [self.list lfPopFirstObject];
    dispatch_semaphore_signal(_lock);
    return firstFrame;
}

- (void)removeAllObject {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.list removeAllObjects];
    dispatch_semaphore_signal(_lock);
}

- (void)removeExpireFrame {
    if (self.list.count < self.maxCount) return;

    NSArray *pFrames = [self expirePFrames]; /// P frames between the first P and the first I
    self.lastDropFrames += [pFrames count];
    if (pFrames && pFrames.count > 0) {
        [self.list removeObjectsInArray:pFrames];
        return;
    }
    
    NSArray *iFrames = [self expireIFrames]; ///  Delete an I frame (but an I frame may correspond to multiple nal)
    self.lastDropFrames += [iFrames count];
    if (iFrames && iFrames.count > 0) {
        [self.list removeObjectsInArray:iFrames];
        return;
    }
    
    [self.list removeAllObjects];
}

- (NSArray *)expirePFrames {
    NSMutableArray *pframes = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < self.list.count; index++) {
        UZFrame *frame = [self.list objectAtIndex:index];
        if ([frame isKindOfClass:[UZVideoFrame class]]) {
            UZVideoFrame *videoFrame = (UZVideoFrame *)frame;
            if (videoFrame.isKeyFrame && pframes.count > 0) {
                break;
            } else if (!videoFrame.isKeyFrame) {
                [pframes addObject:frame];
            }
        }
    }
    return pframes;
}

- (NSArray *)expireIFrames {
    NSMutableArray *iframes = [[NSMutableArray alloc] init];
    uint64_t timeStamp = 0;
    for (NSInteger index = 0; index < self.list.count; index++) {
        UZFrame *frame = [self.list objectAtIndex:index];
        if ([frame isKindOfClass:[UZVideoFrame class]] && ((UZVideoFrame *)frame).isKeyFrame) {
            if (timeStamp != 0 && timeStamp != frame.timestamp) break;
            [iframes addObject:frame];
            timeStamp = frame.timestamp;
        }
    }
    return iframes;
}

NSInteger frameDataCompare(id obj1, id obj2, void *context){
    UZFrame *frame1 = (UZFrame *)obj1;
    UZFrame *frame2 = (UZFrame *)obj2;

    if (frame1.timestamp == frame2.timestamp)
        return NSOrderedSame;
    else if (frame1.timestamp > frame2.timestamp)
        return NSOrderedDescending;
    return NSOrderedAscending;
}

- (UZLiveBuffferState)currentBufferState {
    NSInteger currentCount = 0;
    NSInteger increaseCount = 0;
    NSInteger decreaseCount = 0;

    for (NSNumber *number in self.thresholdList) {
        if (number.integerValue > currentCount) {
            increaseCount++;
        } else{
            decreaseCount++;
        }
        currentCount = [number integerValue];
    }

    if (increaseCount >= self.callBackInterval) {
        return UZLiveBuffferIncrease;
    }

    if (decreaseCount >= self.callBackInterval) {
        return UZLiveBuffferDecline;
    }
    
    return UZLiveBuffferUnknown;
}

#pragma mark -- Setter Getter
- (NSMutableArray *)list {
    if (!_list) {
        _list = [[NSMutableArray alloc] init];
    }
    return _list;
}

- (NSMutableArray *)sortList {
    if (!_sortList) {
        _sortList = [[NSMutableArray alloc] init];
    }
    return _sortList;
}

- (NSMutableArray *)thresholdList {
    if (!_thresholdList) {
        _thresholdList = [[NSMutableArray alloc] init];
    }
    return _thresholdList;
}

#pragma mark -- 采样
- (void)tick {
    /** Sampling 3 stages If the network is good or all are poor, callback */
    _currentInterval += self.updateInterval;

    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    [self.thresholdList addObject:@(self.list.count)];
    dispatch_semaphore_signal(_lock);
    
    if (self.currentInterval >= self.callBackInterval) {
        UZLiveBuffferState state = [self currentBufferState];
        if (state == UZLiveBuffferIncrease) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(streamingBuffer:bufferState:)]) {
                [self.delegate streamingBuffer:self bufferState:UZLiveBuffferIncrease];
            }
        } else if (state == UZLiveBuffferDecline) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(streamingBuffer:bufferState:)]) {
                [self.delegate streamingBuffer:self bufferState:UZLiveBuffferDecline];
            }
        }

        self.currentInterval = 0;
        [self.thresholdList removeAllObjects];
    }
    __weak typeof(self) _self = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.updateInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        [self tick];
    });
}

@end
