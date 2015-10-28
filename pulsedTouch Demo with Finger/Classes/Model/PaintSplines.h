//
//  Splines.h
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 11.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "PaintViewData.h"
#import "PaintViewLine.h"

#pragma mark - Getter methods

@interface PaintSplines : NSObject

- (instancetype) initWithData:(PaintViewData *)data;

- (NSMutableArray *) splineIncrement:(NSArray *)lineIncr
                             forLine:(NSArray *)touches;
- (void) addLastPointToPath:(CGMutablePathRef)path
                 fromPoints:(NSArray *)points;

@end
