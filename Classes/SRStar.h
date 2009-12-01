//	
//	SRStar.h
//
//  A part of Sterren.app, planitarium iPhone application.
//  Created by: Jan-Willem Buurlage and Thijs Scheepers
//  Copyright 2006-2009 Mote of Life. All rights reserved.
//
//  Use without premission by Mote of Life is not authorised.
//
//  Mote of Life is a registred company at the Dutch Chamber of Commerce.
//  Chamber of Commerce registration number: 37126951
//

#import <UIKit/UIKit.h>
//#import "OpenGLCommon.h"

@interface SRStar : NSObject {
	
	int starID;
	NSString *name;
	NSString *bayer;
	NSString * x;
	NSString * y;
	NSString * z;
	NSString * mag;
	NSString * ci;
	
}

@property (nonatomic, readwrite) int starID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * bayer;
@property (nonatomic, retain) NSString * x;
@property (nonatomic, retain) NSString * y;
@property (nonatomic, retain) NSString * z;
@property (nonatomic, retain) NSString * ci;
@property (nonatomic, retain) NSString * mag;

@end