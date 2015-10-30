//
//  SIDDetailViewController.h
//  PulsedTouch Demo with Finger
//
//  Created by Peter Kämpf on 04.04.14.
//  Copyright (c) 2014 STABILO digital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintView.h"
#import "PaintViewData.h"
#import "PaintViewLine.h"
#import "SID_PulsedTouchRecognizer/SID_PulsedTouchAnalyzer.h"
#import "SID_PulsedTouchRecognizer/SID_PulsedTouchRecognizer.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) PaintView     *paint;
@property (strong, nonatomic) PaintViewData *pvData;
@property (strong, nonatomic) SID_PulsedTouchAnalyzer *tAn;
@property (strong, nonatomic) SID_PulsedTouchRecognizer *tRec;
@property (strong, nonatomic) PaintViewLine *linePresets;
@property (assign, nonatomic) CGFloat       lineSpeed;

- (CGFloat) calculateFrameRate;
- (void)    handleTouchEnded:(SID_PulsedTouchRecognizer *)tRec;
- (void)    eraseButton;
- (void)    switchMode;
- (void)    startRecording;

@end
