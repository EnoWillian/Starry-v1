//
//  SRObjectManager.h
//  Sterren
//
//  Created by Thijs Scheepers on 05-12-09.
//  Copyright 2009 Web6.nl Diensten. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLView.h"
#import "OpenGLCommon.h"
#import "SRPlanetaryObject.h"
#import "SRSun.h"
#import "SRCamera.h"
#import "SRStar.h"
#import "SRConstellation.h"
#import "SterrenAppDelegate.h"
#import "SRInterface.h"
#import "SRLocation.h"


@interface SRObjectManager : NSObject {
	GLfloat planetPoints[56];
	GLfloat stringPoints[56];
	GLfloat starPoints[15000];
	GLfloat constellationPoints[15000];
	int planetNum;
	int starNum;
	int constellationNum;
	
	//lichamen
	SRSun* sun;
	SRPlanetaryObject *mercury;
	SRPlanetaryObject *venus;
	SRPlanetaryObject *earth;
	SRPlanetaryObject *mars;
	SRPlanetaryObject *jupiter;
	SRPlanetaryObject *saturn;
	SRPlanetaryObject *uranus;
	SRPlanetaryObject *neptune;
}

@end