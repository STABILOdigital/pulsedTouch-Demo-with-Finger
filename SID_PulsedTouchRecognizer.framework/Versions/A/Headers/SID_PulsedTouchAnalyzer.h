//
//  SID_PulsedTouchAnalyzer.h
//
//  Created by Maik Borkenstein on 31.08.15.
//  Copyright (c) 2015 STABILO International GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Protocol for the SID_PulsedTouchRecognizer class. By adhering to this protocol, a calling instance can receive addtional information about touch events which it has forwarded to the SID_PulsedTouchAnalyzer. The filtering algorithms in the analyzer allow it to classify touches as pen touches, finger touches or palm touches, so an effective palm rejection can be implemented.
 */
@protocol SID_PulsedTouchAnalyzerProtocol <NSObject>

@required
/**
 *  The SID_linesChangedClass contains an NSDictionary with NSArray elements, which in turn contain elements of the type SID_Touch, which provide most of the information of regular UITouch events, plus the touch type classification and the line affiliation if the touches were made by a STABILO SMART stylus. Each array is for one line, so the points are conveniently grouped. The order of the array follows the time at which the touches occurred, earlierst touch first.
 *
 *  @param touches NSSet of SID_Touch objects
 */
- (void) SID_linesChangedClass:(NSDictionary*) touchesDict;

@end

/**
 *  The SID_PulsedTouchRecognizer is a class to support the STABILO SMARTjunior and STABILO SMARTup active styli for on-screen writing. The signals from the touchscreen controller must be processed before they can be used like normal touch events. The SID_PulsedTouchAnalyzer offers methods for this processing and can be used alternatively to the SID_PulsedTouchRecognizer. It inherits from the generic NSObject class. A range of public properties make it widely configurable.
 */
@interface SID_PulsedTouchAnalyzer : NSObject

/**
 *  Lower limit of the pen velocity for touch filtering. Low values will filter finger touches better, but can cause unintended line endings whith fast pen movements. For writing, a value of 150 is adequate, for sketching, the value might need to be 500 or more.
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
 *  Maximum error limit to make a final decision on pen mode. Lower values will delay the determination of the two-digit pen mode but will reduce wrongly detected pen modes. Start with a value of 0.15 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double penModeErrorLimit;

/**
 *  Sensitivity for distinguishing a pen line from a finger touch. Higher values mean more certainty, but take longer for pen line filtering. Start with a value of 5.0 and adjust as needed.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double sensitivity;

/**
 *  Factor to calculate the maximum time of no touches between two on states of the pen. The maximum off time between two touches is 0.016667 * maxOffTimeFactor seconds, so the parameter maxOffTimeFactor gives the number of touch measurements between two on states. If the processor load is low, no touchEnded events are skipped and a value of 2.5 is adequate. With high processor load, a skipped touchEnded event is more likely and a higher value fo 6.5 might be needed. However, high values delay the detection when a line has ended and might lead to the linking of two separately entered lines.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double maxOffTimeFactor;

/**
 *  Horizontal distance in pixels around a pen touch point for determining the enclosingRect.
 *
 *  @since v1.0
 */
@property (assign, nonatomic) double xMarginForHitTesting;

/**
 *  Vertical distance in pixels around a pen touch point for determining the enclosingRect.
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
 *  Pen mode switch: This sets either one, two or three possible modes. With the default two modes, the recognition speed is high. Three modes allow more variation, but need extra time to avoid errors. Therefore, the mode has to be set manually on the pen AND in the software preferences. Possible values are 1 (SMARTjunior), 2 (SMARTup with 2 modes, default) or 3 (SMARTup with 3 modes).
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
 *  Initializes an instance of the SID_PulsedTouchAnalyzer. This offers the possibility to initialize the SID_PulsedTouchRecognizer without using an UIGestureRecognizer. The SID_PulsedTouchAnalyzer is a subclass of NSObject, but uses inside a version of the SID_PulsedTouchRecognizer.
 *
 *    When using this method of implementation, touch events must be forwarded (touchesBegan, touchesMoved, touchesEnded and touchesCancelled) to SID_touchesBegan:, SID_touchesMoved, SID_touchesEnded: and SID_TouchesCancelled:. Every touch event returns a set of SID_Touches to the method SID_linesChangedClass:, declared in the SID_PulsedTouchAnalyzer protocol.
 *
 *    @since v1.3
 *
 *    @param delegate The instance where the SID_linesChangedClass: method of the SID_PulsedTouchAnaylzer protocol is implemented. This should usually be set to self.
 *
 *    @return An initialized instance of the SID_PulsedTouchAnalyzer
 */
- (instancetype) initWithDelegate:(id) delegate;

//optional method for not using the internal iOS detection
/**
 *    Switches the internal iOS check on or off. As default, the internal check is switched on, to use the latest iOS compatible algorithms for the SID_PulsedTouchRecognizer. If switched off, the algorithms are set to an iOS 7 compatible version.
 *
 *    @since v1.1
 *
 *    @param detectionUse NO if the internal iOS detection should not be used. YES is the default value.
 */
- (void) SID_useInternalIOSDetection:(BOOL) detectionUse;

//INPUT
//input methods

/**
 *    The equivalent method to the touchesBegan of any gesture recognizer.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of a touchesBegan event.
 */
- (void) SID_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesMoved of any gesture recognizer.
 *
 *    @param touches The set of touches of a touchesMoved event.
 */
- (void) SID_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesEnded of any gesture recognizer. The only difference to the implementation for the SID_PulsedTouchRecognizer is the missing return value.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of a touchesEnded event.
 */
- (void) SID_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

/**
 *    The equivalent method to the touchesCancelled of any gesture recognizer.
 *
 *    @since v1.0
 *
 *    @param touches The set of touches of a touchesCancelled event.
 */
- (void) SID_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

//change of init values

//reset method

/**
 *    The reset method. This method resets the SID_PulsedTouchAnalyzer to the status right after initialization. This is mostly used when the screen has been cleared or all lines on the screen are deleted.
 *
 *    @since v1.0
 */
- (void) SID_cleanUp;

@end
