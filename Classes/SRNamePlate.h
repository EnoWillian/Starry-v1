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
#import "SRInterfaceElement.h"

@interface SRNamePlate : NSObject {
	NSMutableArray* elements;
	float yTranslate;
	
	BOOL visible;
	BOOL info;
	BOOL hiding;
	
	int selectedType; //0 - messier, 1 - planets
}

@property (nonatomic, assign) float yTranslate;
@property (nonatomic, assign) BOOL hiding;
@property (nonatomic, assign) int selectedType;
@property (nonatomic, assign) BOOL visible;
@property (readonly) BOOL info;
@property (readonly) NSMutableArray* elements;

-(void)draw;
-(void)hide;
-(void)setName:(NSString*)name inConstellation:(NSString*)constellation showInfo:(BOOL)theInfo;

@end
