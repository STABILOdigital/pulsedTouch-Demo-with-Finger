//
//  SID_Line.m
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 17.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "PaintViewLine.h"

@implementation PaintViewLine

- (instancetype) init {
    
    self = [super init];
    if (self) {
        self.touches = nil;
        _length      = 0;
        _mode        = 2;
        _width       = 5;
        _alphaValue  = 1.0;
        _bright      = 0.8;
        _color       = 1;
    }
    return self;
}

- (instancetype) initWithIncrement:(NSArray *)increment andLine:(PaintViewLine *)line {
    
    self = [super init];
    if (self) {
        self.touches = [[NSMutableArray alloc] initWithArray:increment];
        _length      = [increment count];
    }
    
    // If the supplied sample line exists, inherit its characteristics:
    if (line) {
        _mode        = line.mode;
        _width       = line.width;
        _alphaValue  = line.alphaValue;
        _bright      = line.bright;
        _color       = line.color;
        
        // Or, if no line exists, use default values:
    } else {
        _mode        = 2;
        _width       = 5;
        _alphaValue  = 1.0;
        _bright      = 0.8;
        _color       = 1;
    }
    return self;
}

- (void) addIncrement:(NSArray *)increment {
    
    [self.touches addObjectsFromArray:increment];
    self.length += [increment count];
}

// Copy all parameters over to another line, except for the actual touch points:

- (void) copyToLine:(PaintViewLine *)line {
    
    line.mode       = self.mode;
    line.width      = self.width;
    line.alphaValue = self.alphaValue;
    line.bright     = self.bright;
    line.color      = self.color;
}

@end
