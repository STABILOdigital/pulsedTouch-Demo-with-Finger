//
//  SID_Line.h
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 17.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SID_PulsedTouchRecognizer/SID_Touch.h"

@interface PaintViewLine : NSObject
/**
 *  mode: -1 : palm touch
 *         0 : open, wait for next one
 *         1 : blue   penMode
 *         2 : red    penMode
 *         3 : yellow penMode
 *         9 : finger touch (green color)
 */
@property (assign, nonatomic) NSInteger  mode;               // Which pattern has been detected?
@property (assign, nonatomic) NSUInteger length;             // How many points are there so far?
@property (strong, nonatomic) NSMutableArray *touches;       // Constituents of the line.

// These variables can be set with the control subview,
@property (assign, nonatomic) CGFloat    width;
@property (assign, nonatomic) CGFloat    alphaValue;
@property (assign, nonatomic) CGFloat    bright;
@property (assign, nonatomic) NSUInteger color;

- (instancetype) init;
- (instancetype) initWithIncrement:(NSArray *)increment andLine:(PaintViewLine *)line;
- (void) addIncrement:(NSArray *)increment;
- (void) copyToLine:(PaintViewLine *)line;

@end
