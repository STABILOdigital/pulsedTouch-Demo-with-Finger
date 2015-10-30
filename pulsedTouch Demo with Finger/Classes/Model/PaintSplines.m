//
//  Splines.m
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 11.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import "PaintSplines.h"

@interface PaintSplines ()
@property (strong, nonatomic) PaintViewData *pvData;
@end

@implementation PaintSplines

#pragma mark - Initialization and helper methods

- (instancetype) initWithData:(PaintViewData *)data {
    self        = [super init];
    self.pvData = data;
    
    return self;
}

#pragma mark - Spline drawing

- (NSMutableArray *) splineIncrement:(NSArray *)lineIncr
                             forLine:(NSArray *)touches {
    
    // Get the points from the newLine and the lineIncr:
    NSUInteger length      = [touches count];
    NSUInteger incrLength  = [lineIncr count];
    NSUInteger startIndex  = length - incrLength;
    SID_Touch *lastTouch   = [lineIncr lastObject];
    if (lastTouch.classification > 3) {
        startIndex++;
    }
    NSUInteger maxData     = incrLength * self.pvData.maxSplinePoints;
    NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:maxData];
    
    if (length == 0) {
        return nil;
        
        // The first point must serve as a starting point.
    } else if (length < 3) {
        if (startIndex == 0) {
            SID_Touch *tp = [touches firstObject];
            if (tp.classification < 3) {
                [points addObject:[NSValue valueWithCGPoint:tp.point]];
            }
        }
        return nil;
        
        // Only with four points or more we can really plot a B-spline.
    } else {
        SID_Touch *tp0, *tp1, *tp2, *tp3;
        CGPoint   pi3, pi4;
        
        if (startIndex < 3) {
            // Step one with extrapolated starting point, so that the first segment can be splined:
            tp1       = [touches firstObject];
            tp2       = [touches objectAtIndex:1L];
            tp3       = [touches objectAtIndex:2L];
            tp0       = [[SID_Touch alloc] init];
            tp0.point = CGPointMake(1.5*tp1.point.x - 0.75*tp2.point.x + 0.25*tp3.point.x,
                                    1.5*tp1.point.y - 0.75*tp2.point.y + 0.25*tp3.point.y);
            
        } else {
            tp0 = [touches objectAtIndex:startIndex-3];
            tp1 = [touches objectAtIndex:startIndex-2];
            tp2 = [touches objectAtIndex:startIndex-1];
            tp3 = [touches objectAtIndex:startIndex];
        }
        
        CGFloat divisions   = (tp2.velocity.x + tp2.velocity.y) / (tp2.timestamp - tp1.timestamp);
        NSUInteger interpol = (NSUInteger)divisions;
        if (interpol > self.pvData.maxSplinePoints) {
            divisions = divisions * self.pvData.maxSplinePoints / interpol;
            interpol  = self.pvData.maxSplinePoints;
        }
        
        // Now prepare the splining part of the segment:
        CGFloat pi0x = (-tp0.point.x + 3 * tp1.point.x - 3 * tp2.point.x + tp3.point.x) / 6.0;
        CGFloat pi1x = ( tp0.point.x - 2 * tp1.point.x +     tp2.point.x              ) / 2.0;
        CGFloat pi2x = (-tp0.point.x                   +     tp2.point.x              ) / 2.0;
        CGFloat pi3x = ( tp0.point.x + 4 * tp1.point.x +     tp2.point.x              ) / 6.0;
        CGFloat pi0y = (-tp0.point.y + 3 * tp1.point.y - 3 * tp2.point.y + tp3.point.y) / 6.0;
        CGFloat pi1y = ( tp0.point.y - 2 * tp1.point.y +     tp2.point.y              ) / 2.0;
        CGFloat pi2y = (-tp0.point.y                   +     tp2.point.y              ) / 2.0;
        CGFloat pi3y = ( tp0.point.y + 4 * tp1.point.y +     tp2.point.y              ) / 6.0;
        
        // Add the first point to the array. It should be the point which was last in the previous loop
        // and is roughly pt1, i.e. the point with the index line.length - incrLength - 2
        pi3  = CGPointMake(pi3x, pi3y);
        [points addObject:[NSValue valueWithCGPoint:pi3]];
        for (NSUInteger i = 1; i < interpol; i++) {
            double t = (double)i / divisions;
            pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
            pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
            [points addObject:[NSValue valueWithCGPoint:pi4]];
        }
        divisions = (tp3.velocity.x + tp3.velocity.y) / (tp3.timestamp - tp2.timestamp);
        
        // Now loop over the known points. No guessing needed here!
        for (NSUInteger n = startIndex+1; n < length; n++) {
            
            // prepare for next run of the loop. If the last point is an extrapolation, stop the loop:
            SID_Touch *touch = touches[n];
            tp0      = tp1;
            tp1      = tp2;
            tp2      = tp3;
            tp3      = touch;
            interpol = (NSUInteger)divisions;
            if (interpol > self.pvData.maxSplinePoints) {
                divisions = divisions * self.pvData.maxSplinePoints / interpol;
                interpol  = self.pvData.maxSplinePoints;
            }
            
            pi0x = (-tp0.point.x + 3 * tp1.point.x - 3 * tp2.point.x + tp3.point.x) / 6.0;
            pi1x = ( tp0.point.x - 2 * tp1.point.x +     tp2.point.x              ) / 2.0;
            pi2x = (-tp0.point.x                   +     tp2.point.x              ) / 2.0;
            pi3x = ( tp0.point.x + 4 * tp1.point.x +     tp2.point.x              ) / 6.0;
            pi0y = (-tp0.point.y + 3 * tp1.point.y - 3 * tp2.point.y + tp3.point.y) / 6.0;
            pi1y = ( tp0.point.y - 2 * tp1.point.y +     tp2.point.y              ) / 2.0;
            pi2y = (-tp0.point.y                   +     tp2.point.y              ) / 2.0;
            pi3y = ( tp0.point.y + 4 * tp1.point.y +     tp2.point.y              ) / 6.0;
            pi3  = CGPointMake(pi3x, pi3y);
            
            [points addObject:[NSValue valueWithCGPoint:pi3]];
            for (NSUInteger i = 1; i < interpol; i++) {
                double t = (double)i / divisions;
                pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
                pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
                [points addObject:[NSValue valueWithCGPoint:pi4]];
            }
            divisions = (tp3.velocity.x + tp3.velocity.y) / (tp3.timestamp - tp2.timestamp);
        }
        
        // The last point must be close to pt2, so we can continue at the same point next time:
        pi3x = ( tp1.point.x + 4 * tp2.point.x + tp3.point.x) / 6.0;
        pi3y = ( tp1.point.y + 4 * tp2.point.y + tp3.point.y) / 6.0;
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(pi3x, pi3y)]];
    }
    return points;
}

// Add one extrapolated point. This really helps (sometimes)!

- (void) addLastPointToPath:(CGMutablePathRef)path fromPoints:(NSArray *)points {
    
    NSUInteger length = [points count];
    if (length < 2) {
        return;
        
        // If the line never had more than two points, it needs to be painted completely.
    } else if (length < 3) {
        SID_Touch *tp1 = [points objectAtIndex:length-2];
        CGPathMoveToPoint(path, NULL, tp1.point.x, tp1.point.y);
        SID_Touch *tp2 = [points objectAtIndex:length-1];
        CGPathMoveToPoint(path, NULL, tp2.point.x, tp2.point.y);
        CGPoint pt3 = CGPointMake(2*tp2.point.x - tp1.point.x, 2*tp2.point.y - tp1.point.y);
        CGPathAddLineToPoint(path, NULL, pt3.x, pt3.y);
        
        // Set up the splining for the last gap, and then some more.
    } else {
        SID_Touch *tp0 = [points objectAtIndex:length-3];
        SID_Touch *tp1 = [points objectAtIndex:length-2];
        SID_Touch *tp2 = [points objectAtIndex:length-1];
        CGPoint pt3    = CGPointMake(1.5*tp2.point.x - 0.75*tp1.point.x + 0.25*tp0.point.x,
                                     1.5*tp2.point.y - 0.75*tp1.point.y + 0.25*tp0.point.y);
        
        CGFloat divisions   = (tp2.velocity.x + tp2.velocity.y) / (tp2.timestamp - tp1.timestamp);
        NSUInteger interpol = (NSUInteger)divisions;
        if (interpol > self.pvData.maxSplinePoints) {
            divisions = divisions * self.pvData.maxSplinePoints / interpol;
            interpol  = self.pvData.maxSplinePoints;
        }
        
        CGFloat pi0x = (-tp0.point.x + 3 * tp1.point.x - 3 * tp2.point.x + pt3.x) / 6.0;
        CGFloat pi1x = ( tp0.point.x - 2 * tp1.point.x +     tp2.point.x        ) / 2.0;
        CGFloat pi2x = (-tp0.point.x                   +     tp2.point.x        ) / 2.0;
        CGFloat pi3x = ( tp0.point.x + 4 * tp1.point.x +     tp2.point.x        ) / 6.0;
        CGFloat pi0y = (-tp0.point.y + 3 * tp1.point.y - 3 * tp2.point.y + pt3.y) / 6.0;
        CGFloat pi1y = ( tp0.point.y - 2 * tp1.point.y +     tp2.point.y        ) / 2.0;
        CGFloat pi2y = (-tp0.point.y                   +     tp2.point.y        ) / 2.0;
        CGFloat pi3y = ( tp0.point.y + 4 * tp1.point.y +     tp2.point.y        ) / 6.0;
        
        CGPoint pi4;
        for (NSUInteger i = 1; i < interpol; i++) {
            double t = (double)i / divisions;
            pi4.x    = (pi2x + t*(pi1x + t*pi0x))*t + pi3x;
            pi4.y    = (pi2y + t*(pi1y + t*pi0y))*t + pi3y;
            CGPathAddLineToPoint(path, NULL, pi4.x, pi4.y);
        }
        pi4 = CGPointMake(( tp1.point.x + 4 * tp2.point.x + pt3.x) / 6.0,
                          ( tp1.point.y + 4 * tp2.point.y + pt3.y) / 6.0);
        CGPathAddLineToPoint(path, NULL, pi4.x, pi4.y);
    }
}

@end
