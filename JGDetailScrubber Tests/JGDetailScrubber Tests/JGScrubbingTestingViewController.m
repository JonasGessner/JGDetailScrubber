//
//  JGScrubbingTestingViewController.m
//  JGDetailScrubber Tests
//
//  Created by Jonas Gessner on 30.12.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "JGScrubbingTestingViewController.h"

#import "JGDetailScrubber.h"

@interface JGScrubbingTestingViewController () <JGDetailScrubberDelegate> {
    JGDetailScrubber *_scrubber;
    UILabel *_speedLabel;
    
    UIView *_section1, *_section2, *_section3, *_section4;
}

@end

@implementation JGScrubbingTestingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _section1 = [[UIView alloc] init];
    _section1.backgroundColor = [UIColor redColor];
    [self.view addSubview:_section1];
    
    _section2 = [[UIView alloc] init];
    _section2.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_section2];
    
    _section3 = [[UIView alloc] init];
    _section3.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:_section3];
    
    _section4 = [[UIView alloc] init];
    _section4.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_section4];
    
    _scrubber = [[JGDetailScrubber alloc] init];
    _scrubber.delegate = self;
    [self.view addSubview:_scrubber];
    
    _speedLabel = [[UILabel alloc] init];
    _speedLabel.backgroundColor = [UIColor clearColor];
    _speedLabel.textAlignment = NSTextAlignmentCenter;
    _speedLabel.text = @"Not scrubbing";
    
    [self.view addSubview:_speedLabel];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat inset = 20.0f;
    
    CGRect frame = self.view.bounds;
    frame.origin.x = inset;
    frame.size.width -= inset*2.0f;
    
    frame.origin.y = inset;
    frame.size.height = _speedLabel.font.pointSize+5.0f;
    
    _speedLabel.frame = frame;
    
    frame.origin.y = inset*2.0f;
    frame.size.height = _scrubber.frame.size.height;
    
    _scrubber.frame = frame;
    
    frame.origin.y = CGRectGetMidY(frame);
    frame.origin.x = 0.0f;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = 50.0f;
    
    _section1.frame = frame;
    
    frame.origin.y += 50.0f;
    
    _section2.frame = frame;
    
    frame.origin.y += 50.0f;
    
    _section3.frame = frame;
    
    frame.origin.y += 50.0f;
    frame.size.height = self.view.frame.size.height-frame.origin.y;
    
    _section4.frame = frame;
}

#pragma mark - JGDetailScrubberDelegate

- (void)scrubber:(JGDetailScrubber *)slider didChangeToScrubbingSpeed:(CGFloat)speed {
    if (speed) {
        _speedLabel.text = [NSString stringWithFormat:@"Scrubbing Speed: %.f %%", speed*100.0f];
    }
    else {
        _speedLabel.text = @"Not scrubbing";
    }
    
}

@end
