//
//  lineData.m
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 21.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "PaintViewData.h"

// Data object to ease communication between viewControllers and between them and their view.

@implementation PaintViewData

- (instancetype) init {
    self = [super init];
    if (self) {
        _minLineWidth    =  0.5;
        _maxLineWidth    =  2.0;
        _maxSplinePoints =  5;
        _rectDisplay     = YES;
        _touchAnalyzer   =  NO;
        _v8tRec          =   1;
        _recording       =  NO;
    }
    return self;
}

@end