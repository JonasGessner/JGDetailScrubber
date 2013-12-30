//
//  JGDetailScrubber.m
//  JGDetailScrubber
//
//  Created by Jonas Gessner on 30.12.13
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGDetailScrubber.h"

@interface JGDetailScrubber () {
    float _lastValue;
    
    float _verticalChangeAdjustment;
    
    NSArray *_scrubbingLocations;
    
    CGFloat _thumbXLocation;
    CGFloat _thumbWidth;
}

@property (nonatomic, assign) float scrubbingValue;

@end


#define fitToValueRange(value) MAX(MIN(value, self.maximumValue), self.minimumValue)

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 838.00
#endif

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)


@implementation JGDetailScrubber


#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupSliderDefaults];
    }
    return self;
}

- (void)setupSliderDefaults {
    self.scrubbingSpeeds = @{@(0.0f) : @(1.0f),
                             @(50.0f) : @(0.5f),
                             @(100.0f) : @(0.25f),
                             @(150.0f) : @(0.1f)};
}

#pragma mark - UISlider Getters & Setters

- (void)updateScrubbingValue:(float)value {
    if (self.scrubbing && self.currentScrubbingSpeed < 1.0f) {
        float effectiveDifference = (value - _lastValue) * self.currentScrubbingSpeed;
        
        self.scrubbingValue += (effectiveDifference + _verticalChangeAdjustment);
        
        _verticalChangeAdjustment = 0.0f;
        
    } else {
        self.scrubbingValue = value;
    }
    
    _lastValue = value;
}

- (void)setValue:(float)value animated:(BOOL)animated {
    [self updateScrubbingValue:value];
    [super setValue:self.scrubbingValue animated:animated];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    NSAssert(!self.scrubbing, @"Changing the thumb image while the slider is scrubbing is not supported");
    
    [super setThumbImage:image forState:state];
}

#pragma mark - Custom Getters & Setters

- (void)setScrubbingSpeeds:(NSDictionary *)scrubbingSpeeds {
    NSAssert(!self.scrubbing, @"Changing the scrubbing speeds while the slider is scrubbing is not supported");
    
    if ([scrubbingSpeeds[@(0.0f)] isEqualToNumber:@(1.0f)]) {
        NSMutableDictionary *d = scrubbingSpeeds.mutableCopy;
        d[@(0.0f)] = @(1.0f);
        
        _scrubbingSpeeds = d.copy;
    }
    else {
        _scrubbingSpeeds = scrubbingSpeeds;
    }
    
    _scrubbingLocations = [self.scrubbingSpeeds.allKeys sortedArrayUsingComparator:^NSComparisonResult (NSNumber *obj1, NSNumber *obj2) {
        return [obj1 compare:obj2];
    }];
}

- (void)setScrubbingValue:(float)effectiveValue {
    if (_scrubbingValue == effectiveValue) {
        return;
    }
    
    _scrubbingValue = fitToValueRange(effectiveValue);
}

- (void)setCurrentScrubbingSpeed:(CGFloat)currentScrubbingSpeed {
    if (currentScrubbingSpeed == _currentScrubbingSpeed) {
        return;
    }
    
    _currentScrubbingSpeed = currentScrubbingSpeed;
    
    if ([self.delegate respondsToSelector:@selector(scrubber:didChangeToScrubbingSpeed:)]) {
        [self.delegate scrubber:self didChangeToScrubbingSpeed:_currentScrubbingSpeed];
    }
}

#pragma mark - Touch Handling

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.scrubbingSpeeds.count > 1) {
        _scrubbing = YES;
        
        float value = [self value];
        
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        
        CGPoint currentTouchPoint = [touch locationInView:self];
        
        CGRect thumbRect = [self thumbRectForBounds:self.bounds trackRect:trackRect value:value];
        
        _thumbWidth = thumbRect.size.width;
        
        _thumbXLocation = thumbRect.size.width-CGRectGetMaxX(thumbRect)+currentTouchPoint.x;
        
        BOOL begin = [super beginTrackingWithTouch:touch withEvent:event];
        
        if (iOS7) {
            [self setValue:value]; //fixes a UISlider bug on iOS 7
        }
        
        [self setCurrentScrubbingSpeed:1.0f];
        
        return begin;
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)scrubWithTouch:(UITouch *)touch {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    
    CGPoint currentTouchPoint = [touch locationInView:self];
    currentTouchPoint.x -= trackRect.origin.x;
    
    CGFloat currentY = currentTouchPoint.y;
    CGFloat previousY = [touch previousLocationInView:self].y;
    
    CGFloat verticalDelta = (CGFloat)fabsf(fabsf(currentY)-CGRectGetMidY(trackRect));
    
    if (verticalDelta >= 0.0f) {
        if (currentY != previousY) {
            NSUInteger index = 0;
            NSUInteger speedsCount = _scrubbingLocations.count;
            
            for (NSNumber *num in _scrubbingLocations) {
                index++;
                
                NSNumber *next = (speedsCount > index ? _scrubbingLocations[index] : nil);
                
                if ((CGFloat)num.floatValue <= verticalDelta && (next == nil || next.floatValue > verticalDelta)) {
                    [self setCurrentScrubbingSpeed:(CGFloat)[self.scrubbingSpeeds[num] floatValue]];
                    
                    break;
                }
            }
        }
    }
    else {
        [self setCurrentScrubbingSpeed:1.0f];
    }
    
    CGFloat firstSpeedChangeLocation = (CGFloat)[_scrubbingLocations[1] floatValue];
    
    if (verticalDelta >= firstSpeedChangeLocation && fabsf(currentY) < fabsf(previousY)) {
        float adjustment = powf((firstSpeedChangeLocation/verticalDelta), 4.0f);
        
        CGFloat actualValue = fitToValueRange(_lastValue);
        
        _verticalChangeAdjustment = (actualValue - self.scrubbingValue) * adjustment;
    }
    
    CGFloat relativeProgress = (currentTouchPoint.x-_thumbXLocation)/(trackRect.size.width-_thumbWidth);
    
    float progress = (self.maximumValue-self.minimumValue)*relativeProgress;
    
    [self setValue:progress animated:NO];
    
    if (self.continuous) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.scrubbingSpeeds.count > 1) {
        [self scrubWithTouch:touch];
        return YES;
    }
    else {
        return [super continueTrackingWithTouch:touch withEvent:event];
    }
}

- (void)finishScrubbing {
    _scrubbing = NO;
    [self setCurrentScrubbingSpeed:0.0f];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.scrubbingSpeeds.count > 1) {
        [self scrubWithTouch:touch];
        [self finishScrubbing];
    }
    else {
        [super endTrackingWithTouch:touch withEvent:event];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [self finishScrubbing];
    [super cancelTrackingWithEvent:event];
    
}

@end
