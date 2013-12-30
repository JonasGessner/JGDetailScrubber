//
//  JGDetailScrubber.h
//  JGDetailScrubber
//
//  Created by Jonas Gessner on 30.12.13
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//


@import UIKit;

@protocol JGDetailScrubberDelegate;

@interface JGDetailScrubber : UISlider

/**
 The scrubber's delegate. Must conform to the \c JGDetailScrubberDelegate protocol.
 */
@property (nonatomic, weak) id <JGDetailScrubberDelegate> delegate;

/**
 @discussion This dictionary holds the scrubbing speeds ( \c NSNumber) as value for the Y-offsets as keys ( \c NSNumber).
 
 @code
    scrubber.scrubbingSpeeds = @{@(0.0f)    : @(1.0f),
                                 @(50.0f)   : @(0.5f),
                                 @(100.0f)  : @(0.25f),
                                 @(150.0f)  : @(0.1f)};
 */
@property (nonatomic, strong) NSDictionary *scrubbingSpeeds;



/**
 @return The current scrubbing speed. If \c tracking is \c NO then the returned value will be \c 0.0f.
 */
@property (nonatomic, assign, readonly) CGFloat currentScrubbingSpeed;



/**
 @return \c YES if the scrubber is currently scrubbing and \c NO if it isn't.
 */
@property (nonatomic, assign, readonly) BOOL scrubbing;


@end


@protocol JGDetailScrubberDelegate <NSObject>

@optional
- (void)scrubber:(JGDetailScrubber *)slider didChangeToScrubbingSpeed:(CGFloat)speed;

@end