//
//  SID_Touch.h
//  SID_PulsedTouchRecognizer
//
//  Created by Peter Kämpf on 31.08.15.
//  Copyright (c) 2015 STABILO International GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *   An SID_Touch is the smallest unit of the SID_PulsedTouchRecognizer. It represents a touch point with its point coordinates, the timestamp of the touch and the speed between it and the most recent touch point of the same line. If the touch event starts a new line or is isolated, the velocity property is 0. On top, it includes information on the type of touch, and, if the touch event belongs to a pen line, the line identifier.
 */
@interface SID_Touch : NSObject

/**
 *    The touch point coordinates.
 */
@property (assign, nonatomic) CGPoint point;

/**
 *    The time the touch occured.
 */
@property (assign, nonatomic) NSTimeInterval timestamp;

/**
 *    The ID of the touch set by iOS.
 */
@property (assign, nonatomic) NSString *identifier;

/**
 *    The speed between this and the previous touch point of the same line, split in X- and Y-coordinates.
 */
@property (assign, nonatomic) CGPoint velocity;     // speed from previous touch in pix/s.

/**
 *  The identifier of the line to which the touch has been related
 */
@property (strong, nonatomic) NSString *lineID;

/**
 *  The type of contact of this touch event. The classification can contain one of seven values.
 *
 *  The classification is represented by the values 0 to 3. Only classification mode 0 might change over time to a mode > 0. Three further values denote an extrapolated point. These extrapolations are a convenience to enable the GUI to draw the line closer to the tip position of the pen, but will need to be overwritten in the next cycle.
 *
 *  * 0 - unknown classification yet, but will change over time
 *  * 1 - pen
 *  * 2 - finger
 *  * 3 - palm
 *  * 4 - extrapolated point with unknown classification
 *  * 5 - extrapolated pen point
 *  * 6 - extrapolated finger point
 *
 *  For further information about the pen, look at the penMode within the SID_PenModeNotification.
 */
@property (assign, nonatomic) NSInteger classification;

/**
 *  Describes the state of the touch, analogous to the state of a touch event. Possible values are:
 *
 *  * 1 - Began
 *  * 2 - Changed
 *  * 3 - Ended
 *  * 4 - Cancelled
 *
 */
@property (assign, nonatomic) NSInteger state;

@end
