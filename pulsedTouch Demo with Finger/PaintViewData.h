//
//  lineData.h
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 21.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

@import CoreGraphics;
#import <Foundation/Foundation.h>

@interface PaintViewData : NSMutableData

// These variables can be set with the control subview,
@property (assign, nonatomic) BOOL       rectDisplay;
@property (assign, nonatomic) BOOL       touchAnalyzer;
@property (assign, nonatomic) NSUInteger v8tRec;
@property (assign, nonatomic) BOOL       recording;

// and these stay as they are:
@property (assign, nonatomic) CGFloat    minLineWidth;
@property (assign, nonatomic) CGFloat    maxLineWidth;
@property (assign, nonatomic) NSUInteger maxSplinePoints;

- (instancetype) init;

@end
