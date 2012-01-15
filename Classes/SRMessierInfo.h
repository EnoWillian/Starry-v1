//
//  Copyright (c) 2012, Infinite Droplets V.O.F.
//  All rights reserved.
//  
//  Starry was released under the BSD Licence
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "SRMessier.h"
#import "SRInterfaceElement.h"


@interface SRMessierInfo : NSObject {	
	SRMessier* currentMessier;
	
	NSMutableArray* elements;
	
	Texture2D* messierImage;
	Texture2D* messierText;
	Texture2D* interfaceBackground;
	Texture2D* background;
	Texture2D* pictureBackground;
	Texture2D* pictureForeground;
	//text...
	
	float alphaValue;
	float alphaValueName;
	
	BOOL hiding;
	NSTimer* showTimer;
	
	int pictureBgX;
	int navBgX;
	
	//BOOL visible;
}

@property (nonatomic, assign) BOOL hiding;
@property (nonatomic, assign) float alphaValue;
@property (nonatomic, assign) float alphaValueName;

//+ (SRMessierInfo*)shared;
- (void)messierClicked:(SRMessier*)theMessier;
- (void)draw;
- (void)show; 
- (void)hide; 

@end
