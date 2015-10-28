//
//  SIDDetailViewController.m
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//
//  Version 1.4   Sept 18, 2015
//

#import <stdio.h>
#import "DetailViewController.h"
#import "PaintView.h"
#import "PaintSplines.h"
#import "SID_PulsedTouchRecognizer/SID_Touch.h"

@interface DetailViewController () <SID_PulsedTouchAnalyzerProtocol> {
    CGRect         layerFrame;
    double         lastTime;
    CGFloat        frameRate;
    NSUInteger     frameRateCounter;
    NSMutableSet  *setOfKeys;
    PaintViewLine *lastLine;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString            *filePath;
@property (strong, nonatomic) NSMutableArray      *fileData;
@property (strong, nonatomic) NSMutableDictionary *layersDict;

- (void)configureView;

@end

#define DAMPING 0.7

static NSString *const SID_RectNotification      = @"SID_RectNotification";

@implementation DetailViewController

#pragma mark - Managing the UI

- (void) configureView {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // First load the preset parameters:
    self.pvData = [[PaintViewData alloc] init];
    
    // Then initialize both modules:
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect bounds     = CGRectMake(0.0, 0.0, screenRect.size.width, screenRect.size.height);
    if (screenRect.size.width > screenRect.size.height) {
        bounds        = CGRectMake(0.0, 0.0, screenRect.size.height, screenRect.size.width);
    }
    
    // Initialize the view:
    self.paint = [[PaintView alloc] initWithFrame:bounds
                                          andData:(PaintViewData *)self.pvData];
    [self.view addSubview:self.paint];
    
    // Now add the pulsedTouchRecognizer.
    self.tAn  = [[SID_PulsedTouchAnalyzer alloc] initWithDelegate:self];
    
    self.tRec = [[SID_PulsedTouchRecognizer alloc] initWithTarget:self
                                                           action:@selector(handleTouchEnded:)];
    self.tRec.delaysTouchesBegan   = YES;
    self.tRec.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:self.tRec];
    [self switchMode];
    
    // Switch the touchRecognizer on or off. Unfortunately, this does not work for the Analyzer.
    if (self.pvData.touchAnalyzer) {
        self.tRec.enabled = NO;
    } else {
        self.tRec.enabled = YES;
    }
    
    lastTime         = [[NSDate date] timeIntervalSince1970];
    frameRate        =  0.0;
    frameRateCounter =  0;
    setOfKeys        = [[NSMutableSet alloc] init];
    lastLine         = [[PaintViewLine alloc] init];
    
    self.linePresets = [[PaintViewLine alloc] init];
    self.fileData    = [[NSMutableArray alloc] init];
    self.layersDict  = [[NSMutableDictionary alloc] init];
    self.lineSpeed   = 0.0;
    
    // One observer for setting the penMode:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyPenMode:)
                                                 name:SID_PenModeNotification
                                               object:nil];
    // one for the line ended message:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(endLine:)
                                                 name:SID_LineEndedNotification
                                               object:nil];
    // and one observer for processed rects:
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(processedRects:)
                                                 name:SID_RectNotification
                                               object:nil];
}

# pragma Mark - Touch processor configuration.

- (void) switchMode {
    
    // Tell the pulsedGestureRecognizer whether to process finger touches:
    if (self.pvData.v8tRec < 2) {
        [self.tRec setFailOnFingerTouch:NO];
    } else {
        [self.tRec setFailOnFingerTouch:YES];
    }
    
    // Check if we want to use the iOS7 or iOS8 version:
    if (self.pvData.v8tRec > 0) {
        [self.tRec SID_useInternalIOSDetection:YES];
    } else {
        [self.tRec SID_useInternalIOSDetection:NO];
    }
}

// Get the screen refresh rate from the PaintView:

- (CGFloat)calculateFrameRate {
    
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSince1970] - lastTime;
    lastTime              += elapsed;
    CGFloat newRate        = frameRateCounter / elapsed;
    frameRateCounter       = 0;
    
    // Apply some simple damping:
    if (frameRate > 0.1) {
        frameRate = DAMPING * newRate + (1.0 - DAMPING) * frameRate;
    } else {
        frameRate = newRate;
    }
    
    return frameRate;
}

// What to do when the orientation changes.

- (void) viewWillTransitionToSize:(CGSize)size
        withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.tRec SID_cleanUp];
}

// Override to allow orientations other than the default portrait orientation for iPad.
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    // Return YES for all orientations
    return YES;
}

// What to do when the Erase button was pressed.

- (void) eraseButton {
    
    for (CAShapeLayer *layer in [self.layersDict allValues]) {
        [layer removeFromSuperlayer];
    }
    [self.layersDict removeAllObjects];
    
    [self.tRec SID_cleanUp];
    [self.paint clearScreen];
    frameRate = 0.0;
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}

#pragma mark - Touch handling

// Actions to perform when a UI gesture has been recognized

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Return self.tRec.failOnFingerTouch
    if ([gestureRecognizer isEqual:self.tRec]) {
        return YES;
    } else {
        return self.tRec.failOnFingerTouch;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.pvData.touchAnalyzer) {
        [self.tAn SID_touchesBegan:touches withEvent:(UIEvent *)event];
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.pvData.touchAnalyzer) {
        [self.tAn SID_touchesMoved:touches withEvent:(UIEvent *)event];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.pvData.touchAnalyzer) {
        [self.tAn SID_touchesEnded:touches withEvent:(UIEvent *)event];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.pvData.touchAnalyzer) {
        [self.tAn SID_touchesCancelled:touches withEvent:(UIEvent *)event];
    }
}

// Delegated protocol method for touchAnalyzer

- (void) SID_linesChangedClass:(NSDictionary *)touchesDict {
    
    // Loop over the NSArray entries
    for (NSString *key in touchesDict) {
        NSArray *touchArray   = touchesDict[key];
        SID_Touch *firstTouch = [touchArray firstObject];
        
        // Select the touch handling according to type:
        switch (firstTouch.classification) {
                
                // First a finger touch
            case 2:
            case 6:
                switch (firstTouch.state) {
                    case 1:
                        [self openNewPathWithIncrement:touchArray forKey:firstTouch.lineID];
                        break;
                        
                    case 2:
                        [self paintIncrement:touchArray forKey:firstTouch.lineID withEnd:NO];
                        break;
                        
                    default:
                        [self paintIncrement:touchArray forKey:firstTouch.lineID withEnd:YES];
                }
                break;
                
                // Next a palm touch to ignore
            case 3:
                break;
                
                // Now what counts: Pen line points!
            default:
                
                // If the key is not yet in the set, initialize a new array and add the key to the key set.
                // No plotting so far:
                if (![setOfKeys containsObject:firstTouch.lineID]) {
                    [setOfKeys addObject:firstTouch.lineID];
                    [self openNewPathWithIncrement:touchArray forKey:firstTouch.lineID];
                    
                    // If we get consecutive points, we start plotting them:
                } else {
                    [self paintIncrement:touchArray forKey:firstTouch.lineID withEnd:NO];
                }
        }
    }
    
    // Process the events properly for file and screen output:
    if (self.paint.pvData.recording) [self writeLines:touchesDict];
}

// Target method for tRec:

- (void) handleTouchEnded:(SID_PulsedTouchRecognizer *)tRec {
    
    // Get the dictionary with new line increments for looping over:
    NSDictionary *newIncrements = [self.tRec get_SID_LineIncrement];
    
    // Loop over the NSDictionary entries
    for (NSString *key in newIncrements) {
        NSArray *lineIncr = newIncrements[key];
            
        // If the key is not yet in the set, initialize a new array and add the key to the key set.
        // No plotting so far:
        if (![setOfKeys containsObject:key]) {
            [setOfKeys addObject:key];
            [self openNewPathWithIncrement:lineIncr forKey:key];
            
            // If we get consecutive points, we start plotting them:
        } else {
            [self paintIncrement:lineIncr forKey:key withEnd:NO];
        }
    }

    // Process the events properly for file and screen output:
    if (self.paint.pvData.recording) [self writeLines:newIncrements];
}

#pragma mark - Touch Processing

// Open a new layer if a new line start is detected:

- (void) openNewPathWithIncrement:(NSArray *)lineIncr forKey:(NSString *)key {
    
    // Define the layer for drawing the new line:
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    
    if (pathLayer) {
        [self.paint.layer addSublayer:pathLayer];
        pathLayer.delegate = self;
        pathLayer.frame    = layerFrame;
        
        // Pen lines will get a preliminary color, ideally inherited from the line before:
        SID_Touch *firstTouch  = [lineIncr lastObject];
        SID_Touch *lastTouch   = [lineIncr lastObject];
        PaintViewLine *newLine = [[PaintViewLine alloc] initWithIncrement:lineIncr andLine:lastLine];
        
        [pathLayer setValue:key     forKey:@"Key"];
        [pathLayer setValue:newLine forKey:@"Line"];
        [self setLine:newLine inLayer:pathLayer toMode:newLine.mode];
        
        // Add an extra path to store the un-extrapolated path (this one does not get displayed, but appended each time)
        UIBezierPath *shortPath = [[UIBezierPath alloc] init];
        [shortPath moveToPoint:firstTouch.point];
        [pathLayer setValue:shortPath forKey:@"shortPath"];
        
        // Start drawing if we have enough points:
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, firstTouch.point.x, firstTouch.point.y);
        if ([lineIncr count] > 2) {
            NSMutableArray *points = [self.paint.splinefunc splineIncrement:lineIncr forLine:lineIncr];
            for (NSUInteger n = 1; n < [lineIncr count]; n++) {
                CGPoint nextPoint = [points[n] CGPointValue];
                CGPathAddLineToPoint(path, nil, nextPoint.x, nextPoint.y);
            }
        }
        
        // Depending on the line type, we choose a square or round line start:
        if (lastTouch.classification == 1) {
            if (newLine.mode == 3) {
                [pathLayer setLineCap:kCALineCapButt];
            } else {
                [pathLayer setLineCap:kCALineCapRound];
            }
        } else {
            
            // Undecided touches get the default mode:
            [pathLayer setLineCap:kCALineCapRound];
        }
        
        // Set the rest of the layer accordingly:
        pathLayer.path        = path;
        pathLayer.opaque      = NO;
        pathLayer.strokeColor = [self.paint lineColorFor:newLine].CGColor;
        pathLayer.fillColor   = [UIColor clearColor].CGColor;
        pathLayer.lineWidth   = 0.5 * newLine.width;
        pathLayer.lineJoin    = kCALineJoinRound;
        [self.layersDict setObject:pathLayer forKey:key];
    }
    CGPathRelease(pathLayer.path);
}

// Add the most recent Increment to the line of an existing layer:

- (void) paintIncrement:(NSArray *)lineIncr forKey:(NSString *)key withEnd:(BOOL)end {
    
    CAShapeLayer *layer = self.layersDict[key];
    
    if (layer) {
        PaintViewLine *line = [layer valueForKey:@"Line"];
        SID_Touch *lastTouch = [lineIncr lastObject];
        
        // If palm touches are reported, delete the line and layer:
        if (lastTouch.classification == 3 || line.mode < 0) {
            
            // Pen mode is -1: We need to delete the line! Get the oldPath from the layer:
            CGMutablePathRef oldPath = CGPathCreateMutableCopy(layer.path);
            CGRect dirtyRect    = CGRectInset(CGPathGetBoundingBox(oldPath), -line.width, -line.width);
            self.paint.clipRect = CGRectUnion(self.paint.clipRect, dirtyRect);
            
            // In any case: Delete the layer of this path:
            [layer removeFromSuperlayer];
            [self.layersDict removeObjectForKey:key];
            [setOfKeys       removeObject:key];
            CGPathRelease(oldPath);
        } else {
            
            [line setLength:[line.touches count]];
            NSUInteger length = [lineIncr count];

            // Finger touches get mode 9:
            if (lastTouch.classification == 2 || lastTouch.classification == 6) {
                [self setLine:line inLayer:layer toMode:9L];

                // Only use half the extrapolation to get better results:
            } else if (lastTouch.classification > 3 && length > 1) {
                SID_Touch *lastTrueTouch = lineIncr[length-2];
                lastTouch.point = CGPointMake(0.5*(lastTrueTouch.point.x + lastTouch.point.x),
                                              0.5*(lastTrueTouch.point.y + lastTouch.point.y));
                line.length--;
            }
            
            if (length > 0) {

            // Extend the line by all non-extrapolated points:
                for (NSUInteger j = 0; j < length; j++) {
                SID_Touch *touch = [lineIncr objectAtIndex:j];
                
                    // Update the parameters for the stored path:
                if (touch.classification < 3) {
                    [line.touches addObject:touch];
                    self.lineSpeed = DAMPING * self.lineSpeed + (1.0 - DAMPING) * (touch.velocity.x + touch.velocity.y);
                }
            }
                
                // Update the parameters for the UI:
                NSMutableArray *points = [self.paint.splinefunc splineIncrement:lineIncr forLine:line.touches];
                
                // Get the oldPath from the layer and append the new points minus the last one to it
                UIBezierPath *shortPath  = [layer valueForKey:@"shortPath"];
                
                // Open newPath to draw the new increment into:
                CGMutablePathRef newPath = CGPathCreateMutable();
                if ([points count]) {
                    CGPoint nextPoint = [points[0] CGPointValue];
                    [shortPath addLineToPoint:nextPoint];
                    CGPathMoveToPoint(newPath, nil, nextPoint.x, nextPoint.y);
                    
                    for (NSUInteger n = 1; n < [points count]; n++) {
                        nextPoint = [points[n] CGPointValue];
                        [shortPath addLineToPoint:nextPoint];
                        CGPathAddLineToPoint(newPath, nil, nextPoint.x, nextPoint.y);
                    }

// Extra points if there is an extrapolated point:
                    if (lastTouch.classification > 3) {
                        [self.paint.splinefunc addLastPointToPath:newPath fromPoints:line.touches];
                    }
                }
                
                // End detected: Close the line and transfer it to the bitmap:
                if (end) {
                    
                    // Paint this path to the bitmap.
                    [self.paint addPath:layer.path with:line];
                    [layer removeFromSuperlayer];
                    [self.layersDict removeObjectForKey:lastTouch.lineID];
                    [setOfKeys       removeObject:lastTouch.lineID];
                }
                
                // Put the extended shortPath back and place the extrapolated path into the layer:
                CGMutablePathRef oldPath = CGPathCreateMutableCopy(shortPath.CGPath);
                CGPathAddPath(oldPath, nil, newPath);
                layer.path = oldPath;
                CGPathRelease(oldPath);
                
                // Update the display where something new happened:
                CGRect dirtyRect    = CGRectInset(CGPathGetBoundingBox(newPath), -line.width, -line.width);
                self.paint.clipRect = CGRectUnion(self.paint.clipRect, dirtyRect);
                CGPathRelease(newPath);
            }               // lineIncr count > 0
        }                   // touch.classification != 3
        
        // Draw inside the clipping rect:
        [layer setNeedsDisplayInRect:self.paint.clipRect];
        
        // Count the number of screen redraws.
        frameRateCounter++;
    }                       // layer exists
}

- (void) applyPenMode:(NSNotification *)notification {
    
    // Transfer the parameters from the message dictionary to their properties:
    for (NSString *key in notification.userInfo) {
        CAShapeLayer *layer = self.layersDict[key];
        PaintViewLine *line = [layer valueForKey:@"Line"];
        
        // Extract the information from the dictionary item:
        line.mode = [notification.userInfo[key] longValue];
        
        if (line.mode > 9) {
            [self setLine:line inLayer:layer toMode:line.mode];
            
            // Realistically, there can only be one good line. Save its properties,
            // so the line can serve as a template for future lines.
            [line copyToLine:lastLine];
            
            // A negative penMode means we should erase the line and remove it from memory:
        } else if (line.mode < 0) {
            CAShapeLayer *layer = self.layersDict[key];
            [layer removeFromSuperlayer];
            [self.layersDict removeObjectForKey:key];
            [setOfKeys       removeObject:key];
        }
    }
    
    // Now clean the setOfKeys and apply the newly found penMode retrospectively:
    if (lastLine.mode > 9 && [setOfKeys count] > 1) {
        
        for (NSString *key in [setOfKeys copy]) {
            if ([notification.userInfo objectForKey:key]) continue;
            
            CAShapeLayer *layer = self.layersDict[key];
            if (layer) {
                PaintViewLine *line = [layer valueForKey:@"Line"];
                if (line.mode == lastLine.mode) continue;
                
                [self setLine:line inLayer:layer toMode:lastLine.mode];
                
                // Paint this path to the bitmap. What is left here has the mode 0, so no check needed:
                [self.paint addPath:layer.path with:line];
                [layer removeFromSuperlayer];
                [self.layersDict removeObjectForKey:key];
                [setOfKeys       removeObject:key];
            }
        }
    }
    
    // Paint into bitmap, now using the full screen to erase unwanted lines!
    [self.paint setNeedsDisplay];
}

// Apply all changes to a line when the mode changes:

- (void) setLine:(PaintViewLine *)line inLayer:(CAShapeLayer *)layer toMode:(NSInteger)mode {
    
    line.mode = mode;
    switch (mode) {
        case  1:
        case 10:
            line.color      = 1;
            line.width      = self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;
            
        case  2:
        case 20:
            line.color      = 2;
            line.width      = self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;
            
        case  3:
        case 30:
            line.color      =  3;
            line.width      = 50.0;
            line.bright     =  1.0;
            line.alphaValue =  0.33;
            break;
            
        case  9:
            line.color      = 9;
            line.width      = 2 * self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;
            
        default:
            line.color      = 0;
            line.width      = self.linePresets.width;
            line.bright     = self.linePresets.bright;
            line.alphaValue = self.linePresets.alphaValue;
            break;
    }
    
    // Set the new color immediately
    [layer setStrokeColor:[self.paint lineColorFor:line].CGColor];
    [layer setLineWidth:0.5 * line.width];
}

// Merge good lines into the bitmap. Finish or erase the identified paths and finish drawing the lines:

- (void) endLine:(NSNotification *)notification {
    
    for (NSString *key in notification.userInfo) {
        
        // Dump and recreate the pathLayer:
        CAShapeLayer *layer = self.layersDict[key];
        PaintViewLine *line = [layer valueForKey:@"Line"];
        
        if (line) {
            
            // The notification value is one of the possible pen modes. If we have set line.mode to 9
            // (finger) before, we must not overwrite this here! The notification value for finger
            // lines is 0, and this would make our pretty finger line a line of undefined penMode.
            if (line.mode != 9) {
                line.mode = [notification.userInfo[key] longValue];
            }
            
            // … but only when we are sure about the line!
            if (line.mode > 0) {
                if (line.mode > 9) {
                    line.color = line.mode / 10;
                } else {
                    line.color = line.mode;
                }
                
                // Add a little extrapolation at the end of the lines to catch the last point:
                CGMutablePathRef path = CGPathCreateMutableCopy(layer.path);
                [self.paint.splinefunc addLastPointToPath:path fromPoints:line.touches];
                
                // Paint this path to the bitmap:
                if (!CGPathIsEmpty(path)) {
                    [self.paint addPath:path with:line];
                }
                CGPathRelease(path);
                
                [layer removeFromSuperlayer];
                [self.layersDict removeObjectForKey:key];
                [setOfKeys       removeObject:key];
                
            } else if (line.mode < 0) {
                
                // Finger smudge: Delete the layer of this path:
                [layer removeFromSuperlayer];
                [self.layersDict removeObjectForKey:key];
                [setOfKeys       removeObject:key];
            }
        }
    }
    
    // Paint into bitmap, now using the full screen to erase unwanted lines!
    [self.paint setNeedsDisplay];
}

// Start the rect drawing:

- (void) processedRects:(NSNotification *)notification {
    
    // Transfer the parameters from the message dictionary to their properties:
    CGRect enclosingRect = [notification.userInfo[@"greenRect"] CGRectValue];
    CGRect palmRect      = [notification.userInfo[@"redRect"] CGRectValue];
    
    if (self.pvData.rectDisplay) {
        [self.paint drawGreenRect:enclosingRect andRedRect:palmRect];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Steuerung", @"Steuerung");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - File methods

// Open or close a file when button is tapped
- (void) startRecording {
    
    // Toggle the switch:
    self.paint.pvData.recording = !self.paint.pvData.recording;
    
    // Depending on state, open or close the file:
    if (self.paint.pvData.recording) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (paths.count > 0) {
            NSString *filename = [NSString stringWithFormat:@"Touch protocol.txt"];
            self.filePath      = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        }
    } else {
        [self.fileData writeToFile:self.filePath atomically:NO];
    }
}

- (void) writeLines:(NSDictionary *)newIncrements {
    
    // Put the content of the NSSet in a text file.
    for (NSString *key in newIncrements) {
        NSArray *touches = newIncrements[key];
        
        for (SID_Touch *touch in touches) {
            NSTimeInterval now = touch.timestamp;
            switch (self.tRec.state) {
                case UIGestureRecognizerStateBegan:
                {
                    [self.fileData addObject:[NSString stringWithFormat:@"Linie %@ beginnt zur Zeit %15.6f an %5.1f %5.1f", key, now, touch.point.x, touch.point.y]];
                    break;
                }
                    
                case UIGestureRecognizerStateChanged:
                {
                    [self.fileData addObject:[NSString stringWithFormat:@"Linie %@ weiter  zur Zeit %15.6f an %5.1f %5.1f", key, now, touch.point.x, touch.point.y]];
                    break;
                }
                    
                case UIGestureRecognizerStateRecognized:
                {
                    [self.fileData addObject:[NSString stringWithFormat:@"Linie %@ endet   zur Zeit %15.6f an %5.1f %5.1f", key, now, touch.point.x, touch.point.y]];
                    break;
                }
                    
                default:
                {
                    [self.fileData addObject:[NSString stringWithFormat:@"Linie %@ in Phase %ld zur Zeit %15.6f an %5.1f %5.1f", key, (long)self.tRec.state, touch.timestamp, touch.point.x, touch.point.y]];
                }
            }
        }
    }
}

#pragma mark - Default ViewController stuff

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
    [self.fileData   removeAllObjects];
    [self.layersDict removeAllObjects];
    [setOfKeys       removeAllObjects];
}

@end
