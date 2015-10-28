//
//  PaintView.m
//  PaintingSample
//
//  Created by Peter Kämpf on 04.11.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.3   Sept 18, 2015
//

#import "PaintView.h"

@interface PaintView () {
    CALayer      *greenLayer,     // Layer for drawing the enclosingRect
    *redLayer;
    CGContextRef  lineContext;
}
@property (assign, nonatomic) CGAffineTransform flipTransform;

@end

@implementation PaintView

#pragma mark - Initialisation

- (instancetype)initWithFrame:(CGRect)frame andData:(PaintViewData *)data {
    
    self = [super initWithFrame:frame];
    if (self) {
        _pvData = data;
    }
    
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled   = YES;
    self.exclusiveTouch         =  NO;
    self.layer.backgroundColor  = [UIColor whiteColor].CGColor;
    self.splinefunc             = [[PaintSplines alloc] initWithData:data];
    self.flipTransform          = CGAffineTransformIdentity;
    
    // Fill the basic context with a white bitmap:
    float scale = [self contentScaleFactor];
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, scale);
    lineContext = UIGraphicsGetCurrentContext();
    [self fillWhite:lineContext];
    
    // Invert the coordinate system:
    CGContextTranslateCTM(lineContext, 0.0, self.bounds.size.height);
    CGContextScaleCTM(lineContext, 1.0, -1.0);
    CGContextSetLineCap(lineContext, kCGLineCapRound);
    
    // Define the context for drawing the enclosingRect:
    greenLayer = [self layerWithColor:[UIColor greenColor].CGColor];
    
    // Define the context for drawing the palmRect:
    redLayer   = [self layerWithColor:[UIColor redColor].CGColor];
    return self;
}

// Initialize one of the Rect layers:

- (CALayer *)layerWithColor:(CGColorRef)color {
    
    CALayer *layer = [CALayer layer];
    [layer setFrame:CGRectZero];
    [layer setBackgroundColor:color];
    [layer setOpacity:0.1];
    [layer setNeedsDisplayOnBoundsChange:YES];
    [self.layer addSublayer:layer];
    
    return layer;
}

#pragma mark - UI methods

// Clear the lineContext. Called from the ViewController when the appropriate button is pressed.

- (void) clearScreen {
    
    for (CAShapeLayer *layer in [self.layer.sublayers copy]) {
        [layer removeFromSuperlayer];
    }
    [self fillWhite:lineContext];
    
    // Re-establish the two Rect layers:
    greenLayer = [self layerWithColor:[UIColor greenColor].CGColor];
    redLayer   = [self layerWithColor:[UIColor redColor].CGColor];
}

// Fills the context with white color and forces a redraw.

- (void) fillWhite:(CGContextRef)context {
    
    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextFillRect(context, self.bounds);
    [self setNeedsDisplay];
}

#pragma mark - Line Drawing

// This method repaints the paths in the bitmap at the base of the displayed picture.

- (void) addPath:(CGPathRef)path with:(PaintViewLine *)line {
    
    // Prepare drawing into the layer before it is copied to the bitmap:
    UIGraphicsPushContext(lineContext);
    UIColor *color = [self lineColorFor:line];
    CGContextSetStrokeColorWithColor(lineContext, [color CGColor]);
    CGContextSetLineWidth(lineContext, 0.5 * line.width);
    CGContextSetLineJoin(lineContext, kCGLineJoinRound);
    CGContextSetLineCap(lineContext, kCGLineCapRound);
    if (line.mode == 3) {
        CGContextSetLineCap(lineContext, kCGLineCapButt);
    } else {
        CGContextSetLineCap(lineContext, kCGLineCapRound);
    }
    CGContextAddPath(lineContext, path);
    
    // Now paint the path into the current context:
    CGContextStrokePath(lineContext);
    UIGraphicsPopContext();
}

// Set line color to one of five preset values:

- (UIColor *)lineColorFor:(PaintViewLine *)line {
    
    switch (line.color) {
        case  9: {
            return [UIColor colorWithRed:0.000*line.bright
                                   green:0.800*line.bright
                                    blue:0.300*line.bright
                                   alpha:line.alphaValue];
        }
        case  3: {
            return [UIColor colorWithRed:1.000*line.bright
                                   green:1.000*line.bright
                                    blue:0.000*line.bright
                                   alpha:0.33];
        }
        case  2: {
            return [UIColor colorWithRed:1.000*line.bright
                                   green:0.166*line.bright
                                    blue:0.000*line.bright
                                   alpha:line.alphaValue];
        }
        case  1: {
            return [UIColor colorWithRed:0.000*line.bright
                                   green:0.300*line.bright
                                    blue:0.800*line.bright
                                   alpha:line.alphaValue];
        }
        default: {
            return [UIColor colorWithRed:1.000*line.bright
                                   green:1.000*line.bright
                                    blue:1.000*line.bright
                                   alpha:1.0];
        }
    }
}

#pragma mark - Rect Drawing

// Paint the red and green rectangles in their layers:

- (void) drawGreenRect:(CGRect)enclosingRect andRedRect:(CGRect)palmRect {
    
    // Paint the green rect from enclosingRect:
    [greenLayer setFrame:enclosingRect];
    
    // Paint the red rect from palmRect:
    [redLayer setFrame:palmRect];
}

// Redraw the screen. Called by the OS when provoked by setNeedsDisplay.

- (void) drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Paint the bitmap, which includes the confirmed lines:
    if (lineContext) {
        CGImageRef cacheImage = CGBitmapContextCreateImage(lineContext);
        CGContextDrawImage(context, CGRectApplyAffineTransform(self.bounds, self.flipTransform), cacheImage);
        CGImageRelease(cacheImage);
    }
    
    // Reset the clipRects:
    self.clipRect = CGRectNull;
}

#pragma mark - Cleanup

- (void) dealloc {
}

@end
