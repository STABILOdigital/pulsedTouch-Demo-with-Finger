//
//  SID_LineIncrement.h
//  SID_PulsedTouchRecognizer
//
//  Created by Maik Borkenstein on 06.07.15.
//  Copyright (c) 2014 STABILO International GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *    A SID_LineIncrement is an incremental representation of a line since the last time a SID_LineIncrement was received. It contains an NSArray of SID_Touch points, with at least one touch point.
 *
 *    The first line increment contains all touch points since the start of that line and all consecutive touch points can be hung onto the previous line increment.
 */

@interface SID_LineIncrement : NSObject
/**
 *    An array of SID_Touch points.
 */

@property (nonatomic) NSArray* touches;

@end
