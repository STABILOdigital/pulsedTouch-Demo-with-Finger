//
//  SID_PulsedTouchRecognizer.h
//
//  Created by Maik Borkenstein on 24.10.14.
//  Copyright (c) 2014 STABILO International GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *    The SID_PulsedTouchRecognizer is a class to support the STABILO SMARTjunior and STABILO SMARTup active styli for on-screen writing. The signals from the touchscreen controller must be processed before they can be used like normal touch events. The SID_PulsedTouchRecognizer offers methods for this processing and can be used like any gesture recognizer, since it inherits from UIGestureRecognizer. A range of public properties make it widely configurable.
 */

@interface SID_PulsedTouchRecognizer : UIGestureRecognizer

//////////////////////////////////////////////////////////////////////
/// @name Properties
//////////////////////////////////////////////////////////////////////

/**
 *  Lower limit of the pen velocity for touch filtering. Low values will filter finger touches better, but can cause unintended line endings with fast pen movements. For writing, a value of 150 is adequate, for sketching, the value might need to be 500 or more.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double minimumSpeed;

/**
 *  Multiple of the averaged previous pen velocity to produce the velocity limit for the next touch point matching. A higher value allows for bigger fluctuations in pen speed, but makes the inclusion of close finger touches into the pen line more likely. Start with a value of 5.0 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double speedLimitFactor;

/**
 *  Maximum error limit to make a final decision on the pen mode. Lower values will delay the determination of the two-digit pen mode but will reduce detection errors. Start with a value of 0.15 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double penModeErrorLimit;

/**
 *  Sensitivity for distinguishing a pen line from a finger touch. Higher values mean more certainty, but take longer for pen line filtering. Start with a value of 4.0 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double sensitivity;

/**
 *  Factor to calculate the maximum time of no touches between two on states of the pen. The maximum off time between two touches is 0.016667 * maxOffTimeFactor seconds, so the parameter maxOffTimeFactor gives the number of touch measurements between two on states. If the processor load is low, no touchEnded events are skipped and a value of 2.5 is adequate. With high processor load, a skipped touchEnded event is more likely and a higher value up to 6.5 might be needed. However, high values delay the detection when a line has ended and might lead to the linking of two separately entered lines.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double maxOffTimeFactor;

/**
 *  Horizontal distance in pixels around a pen touch point for determining the enclosingRect. New touch events close to detected pen contacts will be directly classified when within xMarginForHitTesting pixels of the most recent pen contact.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double xMarginForHitTesting;

/**
 *  Vertical distance in pixels around a pen touch point for determining the enclosingRect. New touch events close to detected pen contacts will be directly classified when within yMarginForHitTesting pixels of the most recent pen contact.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double yMarginForHitTesting;

/**
 *  Limit time between lines of the same penMode. It is assumed that mode switching will always take longer than this value (in seconds). Start with a value of 0.4 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) NSTimeInterval timeBetweenSameLines;

/**
 *  Pen mode switch: This sets either one, two or three possible modes. The default two modes give an optimum compromise between high detection speed and low detecion error. Three modes allow more variation, but need extra time to avoid errors. Therefore, the mode has to be set manually on the pen AND in the software preferences. Possible values are 1 (SMARTjunior), 2 (SMARTup with 2 modes, default) or 3 (SMARTup with 3 modes, expert setting).
 *
 *  @since v.1.2
 */
@property (assign, nonatomic) NSUInteger penModeSwitch;

/**
 *  Switch to select if the touch Recognizer should report a finger touch as a separate line (failOnFingerTouch = NO) or if the detection of a finger touch should cause it to set its state to UIGestureRecognizerStateFailed (failOnFingerTouch = YES) so a gesture recognizer can take over.
 */
@property (assign, nonatomic) BOOL failOnFingerTouch;

//INIT
//init methods

/**
 *    Initializes an instance of the SID_PulsedTouchRecognizer. This is one of the two possible ways how to use the touch recognizer. The initWithTarget:action: method is the most convinient way to initialize a SID_PulsedTouchRecognizer while using the benefits of the gesture recognizer system.
 *
 *    When using this method of implementation, there is no need to forward the touch events (touchesBegan, touchesMoved, touchesEnded and touchesCancelled) to SID_touchesBegan:, SID_touchesMoved, SID_touchesEnded: and SID_TouchesCancelled:. There is also no need to use the SID_changeView: method.
 *
 *    @since v1.0
 *
 *    @param target The target of the SID_PulsedTouchRecognizer. Mostly the view controller itself (self).
 *    @param action The action handle to process the outputs of the SID_PulsedTouchRecognizer.
 *
 *    @return An initialized instance of the SID_PulsedTouchRecognizer
 */
- (instancetype) initWithTarget:(id)target action:(SEL)action;

/**
 *    Initializes an instance of the SID_PulsedTouchRecognizer. This is the second of the two possible ways how to use the touch recognizer.
 *
 *    When using this method of implementation, the level of control of touch events within your application is higher, but all touch events must be forwarded (touchesBegan, touchesMoved, touchesEnded and touchesCancelled) to the internal SID_touchesBegan:, SID_touchesMoved, SID_touchesEnded: and SID_TouchesCancelled: methods. When the view which receives the touch events changes, the method SID_changeView: must be called.
 *
 *    @since v1.0
 *
 *    @param view The view the touch recognizer uses to retrieve the touch point coordinates
 *
 *    @return An initialized instance of the SID_PulsedTouchRecognizer
 */
- (instancetype) initInView:(UIView*) view;

/**
 *  Delegate method for interacting with other gestureRecognizers
 *
 *  @param gestureRecognizer the other gestureRecognizer
 *
 *  @return If YES the pulsedTouchRecognizer will prevent the gestureRecognizer from analyzing the touch events.
 */

- (void) SID_useInternalIOSDetection:(BOOL) detectionUse;

//INPUT
//input methods

/**
 *    The equivalent method to the touchesBegan of any gesture recognizer.
 *
 *    This method is only necessary when the SID_PulsedTouchRecognizer is initialized with initInView:.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of the touchesBegan event.
 */
- (void) SID_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesMoved of any gesture recognizer.
 *
 *    This method is only necessary when the SID_PulsedTouchRecognizer is initialized with initInView:.
 *
 *    @param touches The set of touches of the touchesMoved event.
 */
- (void) SID_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesEnded of any gesture recognizer. The only difference is the return value.
 *
 *    This method is only needed when the SID_PulsedTouchRecognizer is initialized with initInView:. Since the return value is a dictionary of SID_LineIncrements, there is no need to call the get_SID_LineIncrement: method.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of the touchesEnded event.
 *
 *    @return A dictionary with multiple lines and its line identifier as key in the dictionary. Each line is represented as SID_LineIncrement.
 */
- (void) SID_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesCancelled of any gesture recognizer.
 *
 *    This method is only needed when the SID_PulsedTouchRecognizer is initialized with initInView:.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of the touchesCancelled event.
 */
- (void) SID_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

//change of init values

/**
 *    Changes the UIView of the SID_PulsedTouchRecognizer to retrieve the correct touch coordinates inside the view.
 *
 *    This method is only needed when the SID_PulsedTouchRecognizer has been initialized with initInView:
 *
 *    @since v1.0
 *
 *    @param view The view the SID_PulsedTouchRecognizer operates on.
 */
- (void) SID_changeView:(UIView*) view;

//reset method

/**
 *    The reset method. This method resets the SID_PulsedTouchRecognizer to the status right after initialisation. This is mostly used when the screen has been cleared or all lines on the screen are deleted.
 *
 *    @since v1.0
 */
- (void) SID_cleanUp;

//OUTPUT
//method to get the outputs

/**
 *    Returns a NSDictionary of SID_LineIncrements since the last time this method was used (incremental use).
 *
 *    This method is only needed when the initWithTarget:action: is used for initialization. It is not needed when initInView: was used for inititialization.
 *
 *    @since v1.0
 *
 *    @return A dictionary with multiple lines and its line identifier as key in the dictionary. Each line is represented as a SID_LineIncrement.
 */
- (NSDictionary*) get_SID_LineIncrement;

@end

