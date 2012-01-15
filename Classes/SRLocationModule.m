//
//  Copyright (c) 2012, Infinite Droplets V.O.F.
//  All rights reserved.
//  
//  Starry was released under the BSD Licence
//

#import "SRLocationModule.h"

@implementation SRLocationModule

@synthesize latitude,longitude,longVisible,latVisible,locationManager, GPS, Compass;

-(id)initWithSRLocation:(SRLocation*)aLocation {
	if(self = [super init]) {
		NSString* locationString;
		NSString* compassString;
		
		locationManager = aLocation;
		
		initialXValueIcon = 10;
		
		[locationManager makeAwareOfInterface:self];
		
		//NSLog(@"SRLocationModule meldt de locatie lo:%f la:%f",longitude,latitude);
		
		elements = [[NSMutableArray alloc] init];
		
		if([locationManager staticValues]) {
			locationString = [[NSString alloc] initWithString:@"location_off.png"];
			GPS = FALSE;
		}
		else {
			locationString = [[NSString alloc] initWithString:@"location_on.png"];
			GPS = TRUE;
		}
		
		if([locationManager useCompass]) {
			compassString = [[NSString alloc] initWithString:@"compass.png"];
			Compass = TRUE;
		}
		else {
			compassString = [[NSString alloc] initWithString:@"compass_off.png"];
			Compass = FALSE;
		}
		
		//laad elements in - sla op in textures		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(190,-55, 28,28) 
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"longitude.png"]]
															identifier:@"long-edit" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(10, -57, 41, 31)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"radar.png"]] 
															identifier:@"icon" 
															 clickable:YES]];	
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(104,-60, 80,32) 
															   texture:[[Texture2D alloc] initWithString:NSLocalizedString(@"Latitude", @"") dimensions:CGSizeMake(80,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:9] 
															identifier:@"text-transparent"
															 clickable:NO]];
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(224,-60, 80,32) 
															   texture:[[Texture2D alloc] initWithString:NSLocalizedString(@"Longitude", @"") dimensions:CGSizeMake(80,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:9] 
															identifier:@"text-transparent" 
															 clickable:NO]];
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(104,-72, 80,32) 
															   texture:nil 
															identifier:@"lat" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(224,-72, 80,32) 
															   texture:nil 
															identifier:@"long" 
															 clickable:YES]];
		
		
				 

		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(380,-55, 28,28) 
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:locationString]]
																							   identifier:@"gps-toggle" 
																							  clickable:YES]];
		if([[[CLLocationManager alloc] init] headingAvailable]) {
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(345,-55, 28,28) 
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:compassString]]
															identifier:@"compass" 
															 clickable:YES]];
		}
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(70,-55, 28,28) 
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"latitude.png"]] 
															identifier:@"lat-edit" 
															 clickable:YES]];
		latVisible = YES;
		longVisible = YES;
		
		[locationString release];
	}
	return self;
}

-(void)draw {
	//draw module zelf
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	for (SRInterfaceElement* mElement in elements) {
		if([mElement identifier] == @"text-transparent") {
			glColor4f(0.68f, 0.68f, 0.68f, alphaValue);
			[[mElement texture] drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		}
		else if([mElement identifier] == @"lat") {
			if(latVisible == YES) {
				NSNumber * coordinateNumber = [[NSNumber alloc] initWithFloat:latitude];
				int degrees = [coordinateNumber intValue];
				float minutesF = ([coordinateNumber floatValue] - [coordinateNumber intValue]) * 60;
				NSNumber * minutesNumber = [[NSNumber alloc] initWithFloat:minutesF];
				int minutes = [minutesNumber intValue];
				float secondsF = ([minutesNumber floatValue] - [minutesNumber intValue])*60;
				NSNumber * secondsNumber = [[NSNumber alloc] initWithFloat:secondsF];
				int seconds = [secondsNumber intValue];
				NSString * northOrSouth;
				if (latitude >= 0) {
					northOrSouth = NSLocalizedString(@"locN", @"");
				}
				else {
					northOrSouth = NSLocalizedString(@"locS", @"");
					degrees = -degrees;
					minutes = -minutes;
					seconds = -seconds;
				}
				
				Texture2D* texture = [[Texture2D alloc] initWithString:[[NSString alloc] initWithFormat:@"%i°%i'%i\" %@",degrees,minutes,seconds,northOrSouth] dimensions:CGSizeMake(80,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11];
				glColor4f(1.0f, 1.0f, 1.0f, alphaValue);
				[texture drawInRect:[mElement bounds]];
				glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
				[texture release];
																
				[coordinateNumber release];
				[minutesNumber release];
				[secondsNumber release];
				degrees = 0;
				minutesF = 0;
				minutes = 0;
				secondsF = 0;
				seconds = 0;
			}
			
		}
		else if([mElement identifier] == @"long") {
			if(longVisible == YES) {
				NSNumber * coordinateNumber = [[NSNumber alloc] initWithFloat:longitude];
				int degrees = [coordinateNumber intValue];
				float minutesF = ([coordinateNumber floatValue] - [coordinateNumber intValue]) * 60;
				NSNumber * minutesNumber = [[NSNumber alloc] initWithFloat:minutesF];
				int minutes = [minutesNumber intValue];
				float secondsF = ([minutesNumber floatValue] - [minutesNumber intValue])*60;
				NSNumber * secondsNumber = [[NSNumber alloc] initWithFloat:secondsF];
				int seconds = [secondsNumber intValue];
				NSString * westOrEast;
				if (longitude >= 0) {
					westOrEast = NSLocalizedString(@"locW", @"");
				}
				else {
					westOrEast = NSLocalizedString(@"locE", @"");
					degrees = -degrees;
					minutes = -minutes;
					seconds = -seconds;
				}
				
			
															
				Texture2D* texture = [[Texture2D alloc] initWithString:[[NSString alloc] initWithFormat:@"%i°%i'%i\" %@",degrees,minutes,seconds,westOrEast] dimensions:CGSizeMake(80,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11];
				glColor4f(1.0f, 1.0f, 1.0f, alphaValue);
				[texture drawInRect:[mElement bounds]];
				glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
				[texture release];
															
				[coordinateNumber release];
				[minutesNumber release];
				[secondsNumber release];
				degrees = 0;
				minutesF = 0;
				minutes = 0;
				secondsF = 0;
				seconds = 0;
			}
			/*else {
				Texture2D* texture = [[Texture2D alloc] initWithString:[[NSString alloc] initWithFormat:@""] dimensions:CGSizeMake(80,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11];
				[texture drawInRect:[mElement bounds]];
				[texture release];
			}*/
		}
		else if([mElement identifier] == @"icon") {
			if(hiding) {
				glColor4f(1.0f, 1.0f, 1.0f, alphaValue);
			}
			if(keyboardVisible)
				[[elements objectAtIndex:1] setBounds:CGRectMake(xValueIcon, -57+145, 41, 31)];
			else 
				[[elements objectAtIndex:1] setBounds:CGRectMake(xValueIcon, -57, 41, 31)];
			[[mElement texture] drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		}
		else {
			glColor4f(1.0f, 1.0f, 1.0f, alphaValue);
			[[mElement texture] drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		}
	}
}

-(void)updateDisplayedLocationData {
	
	longitude	=	[locationManager longitude];
	latitude	=	[locationManager latitude];
	
	// NSLog(@"SRLocationModule meldt de locatie lo:%f la:%f",longitude,latitude);
}

-(void)toggleGPS {
	if(GPS) {
		[locationManager useStaticValues];
		[[elements objectAtIndex:6] setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"location_off.png"]]];
		GPS = FALSE;
	}
	else {
		[locationManager useGPSValues];
		[[elements objectAtIndex:6] setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"location_on.png"]]];
		GPS = TRUE;
	}
}

-(void)toggleCompass {
	if(Compass) {
		[locationManager setUseCompass:FALSE];
		[[elements objectAtIndex:7] setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"compass_off.png"]]];
		Compass = FALSE;
	}
	else {
		[locationManager setUseCompass:TRUE];
		[[elements objectAtIndex:7] setTexture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"compass.png"]]];
		Compass = TRUE;
	}
}

@end
