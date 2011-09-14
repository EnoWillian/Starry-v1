//
//  GLViewController.m
//
//  A part of Sterren.app, planetarium iPhone application.
//  Created by: Jan-Willem Buurlage and Thijs Scheepers
//  Copyright 2006-2009 Mote of Life. All rights reserved.
//
//  Use without premission by Mote of Life is not authorised.
//
//  Mote of Life is a registred company at the Dutch Chamber of Commerce.
//  Chamber of Commerce registration number: 37126951
//


#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"
#import "SterrenAppDelegate.h"

@implementation GLViewController

@synthesize camera,theView,renderer,iPadWidth,iPadHeight;

- (void)drawView:(UIView *)theView
{
    glColor4f(0.0, 0.0, 0.0, 0.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Drawing code here
	[renderer render];
}

-(void)setupView:(GLView*)view
{
	
	theView = view;
	theView.multipleTouchEnabled = YES;
	camera = [[SRCamera alloc] initWithView:view];
	renderer = [[SRRenderer alloc] setupWithOwner:self];
	
	iPadWidth = 320;
	iPadHeight = 480;
	
}

- (void)dealloc 
{
    [super dealloc];
}

/* Event handling. 
 * Swipe beweging -> Camera draait naar tegenovergestelde kant
 * Move beweging -> Camera beweegt met de vinger mee
 */

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *aTouch = [touches anyObject];
	
	iPadWidth = 320;
	iPadHeight = 480;
	
	CGPoint relativePoint;
	relativePoint.x = [aTouch locationInView:theView].x*320/iPadWidth;
	relativePoint.y = [aTouch locationInView:theView].y*480/iPadHeight;
	
	if([[renderer interface] UIElementAtPoint:relativePoint]) {
		UIClick = YES;
		ScreenClick = NO;
	}
	else {
		UIClick = NO;
		ScreenClick = YES;
	}
	
	//NSUInteger touchCount = [touches count];	
	//NSLog(@"touchesBegan count: %d", touchCount);
	//lastTouchCount = touchCount;
	dTouch = 1;
	dX = 0;
	dY = 0;
	
	//[camera registerInitialLocationWithX:[aTouch locationInView:theView].x y:[aTouch locationInView:theView].y]
	
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//if(!UIClick) {
	NSUInteger touchCount = [touches count];
	dTouch++;
	//NSLog(@"touchesMoved count: %d lastTouchCount: %d dTouch: %d", touchCount, lastTouchCount, dTouch);
	
	
	/*if(dTouch < 5 && lastTouchCount == 1) 
	 lastTouchCount = touchCount;
	 else {
	 if(touchCount != lastTouchCount)
	 return;
	 //}*/
	
	if(touchCount == 1) {
		UITouch *aTouch = [touches anyObject];
		
		if(
		   ![renderer planetView]) {
			int x, y;
			x = [aTouch locationInView:theView].x - [aTouch previousLocationInView:theView].x;
			y = [aTouch locationInView:theView].y - [aTouch previousLocationInView:theView].y;
			
			if (UIClick == NO) {
				[camera rotateCameraWithX:x 
										Y:y];
			}
			
			dX += x;
			dY += y;
		}
		
		// Als er teveel wordt verschuift cancel de clicks
		if ( -15 < dX < 15 || -15 < dY < 15) {
			//NSLog(@"Click canceld");
			ScreenClick = NO;
			if(UIClick) {
				UIClick = NO;
				[[renderer interface] touchEndedAndExecute:NO];
			}
		}
		
		return;
	}
	else if(touchCount == 2 && UIClick == NO) {
		
		ScreenClick = NO;
		
		NSArray *twoTouches = [touches allObjects];
		UITouch *firstTouch = [twoTouches objectAtIndex:0];
		UITouch *secondTouch = [twoTouches objectAtIndex:1];
		
		CGPoint firstPoint = [firstTouch locationInView:theView];
		CGPoint secondPoint = [secondTouch locationInView:theView];
		
		CGFloat smallestx;
		if (firstPoint.x < secondPoint.x) 
			smallestx = firstPoint.x;
		else 
			smallestx = secondPoint.x;
		
		CGFloat smallesty;
		if (firstPoint.y < secondPoint.y) 
			smallesty = firstPoint.y;
		else 
			smallesty = secondPoint.y;
		
		CGFloat dx = abs(firstPoint.x - secondPoint.x);
		CGFloat dy = abs(firstPoint.y - secondPoint.y);
		
		CGFloat touchDistance = sqrt(dx*dx + dy*dy);
		if (lastTouchCount != 2 || dTouch < 6) {
			initialTouchDistance = touchDistance;
			lastTouchDistance = touchDistance;
		}
		CGPoint touchCenter;
		touchCenter.x = smallestx+dx;
		touchCenter.y = smallesty+dy;
		
		CGFloat zoomDelta;
		
		//if (lastTouchCount == 2) {
		zoomDelta = lastTouchDistance - touchDistance;
		
		[camera zoomCameraWithDelta:zoomDelta
							centerX:touchCenter.x
							centerY: touchCenter.y];
		//}
		
		lastTouchDistance = touchDistance;
		
		//NSLog(@"Delta zoom %f", zoomDelta);
		
	}
	
	lastTouchCount = touchCount;
	//}
}

-(void)checkScreenObjectClicked:(NSSet *)touches {
	UITouch *aTouch = [touches anyObject];
	int x = [aTouch locationInView:theView].x;
	int y = [aTouch locationInView:theView].y;
	
	// Tenopzichte van het midden uitrekenen iPhone screen (iPadHeight*iPadWidth)
	int deltaX = -x+(iPadWidth/2);
	int deltaY = -y+(iPadHeight/2);
	
	
	float fieldOfView = [camera fieldOfView];
	float altitude = [camera altitude];
	float azimuth = [camera azimuth];
	
	float standardHeight = cosf(0.5*(sqrtf(powf((fieldOfView*iPadHeight)/iPadWidth,2)+powf((fieldOfView*iPadHeight)/iPadWidth,2))));
	float radPerPixel;
	
	//FIXME: Fout in deze berekening voor volledig ingezoomd
	//if(fieldOfView > 0.75) {
	/*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		radPerPixel = sinf(0.5*(sqrtf(powf((fieldOfView*iPadHeight)/iPadWidth,2)+powf((fieldOfView*iPadHeight)/iPadWidth,2))))/(iPadWidth+(fieldOfView*(iPadWidth/4)));
	else */
		radPerPixel = sinf(0.5*(sqrtf(powf((fieldOfView*iPadHeight)/iPadWidth,2)+powf((fieldOfView*iPadHeight)/iPadWidth,2))))/(iPadWidth+(fieldOfView*(iPadWidth/2)));
	
	// Coordinaten in het vlak
	float fiX = deltaX * radPerPixel;
	float fiY = deltaY * radPerPixel;
	float fiZ = -standardHeight;
	// Bereken straal hulp-bol
	float dSphere1 = sqrtf(powf(fiX,2) + powf(fiY,2) + powf(fiZ,2));
	//NSLog(@"fiX:%f y:%f z:%f rHulp-Bol:%f",fiX,fiY,fiZ,dSphere1);
	// Bereken coordinaten die de bol raken
	float coX = fiX / dSphere1;
	float coY = fiY / dSphere1;
	float coZ = fiZ / dSphere1;
	//float dSphere2 = sqrtf(powf(coX,2) + powf(coY,2) + powf(coZ,2));
	//NSLog(@"coX:%f y:%f z:%f",coX,coY,coZ);
	
	float rotationY1 = (altitude-90)*(M_PI/180);
	float rotationZ = azimuth*(M_PI/180);
	
	float brX = coX;
	float brY = coY;
	float brZ = coZ;
	
	/*float brX = 0;
	 float brY = 0;
	 float brZ = -1;*/
	
	float maX,maY,maZ;
	
	maX = (cos(rotationY1)*brX+0*brY+sin(rotationY1)*brZ);
	maY = (0*brX+1*brY+0*brZ);
	maZ = ((-sin(rotationY1)*brX)+0*brY+cos(rotationY1)*brZ);
	
	brX = maX;
	brY = maY;
	brZ = maZ;
	
	maX = (cos(rotationZ)*brX+(-sin(rotationZ)*brY)+0*brZ);
	maY = (sin(rotationZ)*brX+cos(rotationZ)*brY+0*brZ);
	maZ = (0*brX+0*brY+1*brZ);
	
	brX = maX;
	brY = maY;
	brZ = maZ;
	
	
	
	float rotationY = (90-[[renderer location] latitude])*(M_PI/180);
	float rotationZ1 = [[renderer location] longitude]*(M_PI/180);
	float rotationZ2 = [[[[renderer interface] timeModule] manager] elapsed]*(M_PI/180);
	//float rotationZ2 = rotationZ1 + rotationZ3;
	
	// voor goed voorbeeld: http://www.math.umn.edu/~nykamp/m2374/readings/matvecmultex/
	// wikipedia rotatie matrix: http://en.wikipedia.org/wiki/Rotation_matrix
	
	//float maX,maY,maZ;
	
	// Matrix vermenigvuldiging met draai om de y-as (locatie)
	maX = (cos(rotationY)*brX+0*brY+sin(rotationY)*brZ);
	maY = (0*brX+1*brY+0*brZ);
	maZ = ((-sin(rotationY)*brX)+0*brY+cos(rotationY)*brZ);
	
	brX = maX;
	brY = maY;
	brZ = maZ;
	
	// Matrix vermenigvuldiging met draai om de  z-as (locatie)
	maX = (cos(rotationZ1)*brX+(-sin(rotationZ1)*brY)+0*brZ);
	maY = (sin(rotationZ1)*brX+cos(rotationZ1)*brY+0*brZ);
	maZ = (0*brX+0*brY+1*brZ);
	
	brX = maX;
	brY = maY;
	brZ = maZ;
	
	// Matrix vermenigvuldiging met draai om de  z-as (tijd)
	maX = (cos(rotationZ2)*brX+(-sin(rotationZ2)*brY)+0*brZ);
	maY = (sin(rotationZ2)*brX+cos(rotationZ2)*brY+0*brZ);
	maZ = (0*brX+0*brY+1*brZ);
	
	brX = maX;
	brY = maY;
	brZ = maZ;
	
	float stX,stY,stZ,plX,plY,plZ;
	stX = -20*brX;
	stY = -20*brY;
	stZ = -20*brZ;
	
	plX = -15*brX;
	plY = -15*brY;
	plZ = -15*brZ;
	
	
	
	float zoomingValue = [camera zoomingValue];
	float xd,yd,zd,sunD,moonD;
	
	SRSun * sun = [[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] objectManager] sun];
	xd = sun.position.x-plX;
	yd = sun.position.y-plY;
	zd = sun.position.z-plZ;
	sunD = sqrt(xd*xd + yd*yd + zd*zd);
	
	if (sunD < (1.5 * (1/zoomingValue))) {
		[[[renderer interface] theNameplate] setName:NSLocalizedString(@"Sun", @"") inConstellation:NSLocalizedString(@"Our star", @"") showInfo:NO];
		[[renderer interface] setANameplate:TRUE];
		
		Vertex3D position = sun.position;
		
		[renderer setHighlightPosition:position];
		[renderer setObjectInFocus:sun];
		[renderer setSelectedStar:nil];
		[renderer setPlanetHighlighted:TRUE];
		[renderer setSelectedPlanet:sun];
		[renderer setHighlightSize:32]; 
		[renderer setHighlight:TRUE];
	}
	else {			
		SRMoon * moon = [[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] objectManager] moon];
		xd = moon.position.x-plX;
		yd = moon.position.y-plY;
		zd = moon.position.z-plZ;
		moonD = sqrt(xd*xd + yd*yd + zd*zd);
		
		if (moonD < (1.5 * (1/zoomingValue))) {
			[[[renderer interface] theNameplate] setName:NSLocalizedString(@"Moon", @"") inConstellation:@"" showInfo:NO];
			[[renderer interface] setANameplate:TRUE];
            
			Vertex3D position = Vector3DMake(moon.position.x, moon.position.y, moon.position.z);
			
			[renderer setHighlightPosition:position];
			[renderer setObjectInFocus:moon];
			[renderer setSelectedStar:nil];
			[renderer setPlanetHighlighted:TRUE];
			[renderer setSelectedPlanet:(SRPlanetaryObject*)moon];
			[renderer setHighlightSize:32]; 
			[renderer setHighlight:TRUE];
		}
		else {
			float planetD,closestD;
			closestD = 15; // moet een hoge begin waarde hebben vanwege het steeds kleiner worden
			SRPlanetaryObject * planet;
			SRPlanetaryObject * closestPlanet;
			for(planet in [[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] objectManager] planets]) {
				
				
				// http://freespace.virgin.net/hugo.elias/routines/r_dist.htm
				xd = planet.position.x-plX;
				yd = planet.position.y-plY;
				zd = planet.position.z-plZ;
				planetD = sqrt(xd*xd + yd*yd + zd*zd);
				if (planetD < closestD) {
					closestD = planetD;
					closestPlanet = planet;
					//NSLog(@"Closest planet:%@",planet.name);
				}
			}
			if (closestD < (1.5 * (1/zoomingValue))) {
				[[[renderer interface] theNameplate] setSelectedType:1];					
				[[[renderer interface] theNameplate] setName:NSLocalizedString(closestPlanet.name, @"") inConstellation:NSLocalizedString(@"planet", @"") showInfo:YES];
				[[renderer interface] setANameplate:TRUE];
				
				[[[renderer interface] planetInfo] planetClicked:closestPlanet];
				
				Vertex3D position = closestPlanet.position;
				
				[renderer setHighlightPosition:position];
				[renderer setObjectInFocus:closestPlanet];
				[renderer setSelectedStar:nil];
				[renderer setPlanetHighlighted:TRUE];
				[renderer setSelectedPlanet:closestPlanet];
				[renderer setHighlightSize:32]; 
				[renderer setHighlight:TRUE];
			}
			else {
				float messierD;
				closestD = 18; // moet een hoge begin waarde hebben vanwege het steeds kleiner worden
				SRMessier * aMessier;
				SRMessier * closestMessier;
				for(aMessier in [[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] objectManager] messier]) {	
					xd = aMessier.position.x-stX;
					yd = aMessier.position.y-stY;
					zd = aMessier.position.z-stZ;
					messierD = sqrt(xd*xd + yd*yd + zd*zd);
                    
                    if ([aMessier visibleWithZoom:zoomingValue]) {
                        
                        if (messierD < closestD) {
                            closestD = messierD;
                            closestMessier = aMessier;
                        } 
                    }
				}
				//FIXME waarom zo'n raar getal?
				if(closestD < (1.5 * (1/zoomingValue))) {
					[[[renderer interface] theNameplate] setSelectedType:0];
					[[[renderer interface] theNameplate] setName:closestMessier.name inConstellation:NSLocalizedString(@"messier", @"") showInfo:YES];
					[[renderer interface] setANameplate:TRUE];
					
					[[[renderer interface] messierInfo] messierClicked:closestMessier];
					
					Vertex3D position = closestMessier.position;
					
					[renderer setHighlightPosition:position];
					[renderer setObjectInFocus:closestMessier];
					[renderer setSelectedStar:nil];
					[renderer setPlanetHighlighted:FALSE];
					[renderer setSelectedPlanet:nil];
					[renderer setHighlightSize:32]; 
					[renderer setHighlight:TRUE];
					
					
				}
				else {
					
					SRStar * star;
					SRStar * closestStar;
					float starD;
					closestD = 20; // moet een hoge begin waarde hebben vanwege het steeds kleiner worden
					
					for(star in [[[[UIApplication sharedApplication] delegate] objectManager] stars]) {
						
						
						// http://freespace.virgin.net/hugo.elias/routines/r_dist.htm
						xd = [star position].x - stX;
						yd = [star position].y -stY;
						zd = [star position].z -stZ;
						starD = sqrt(xd*xd + yd*yd + zd*zd);
						
						if ([star visibleWithZoom:zoomingValue]) {
							if (starD < closestD) {
								
								closestD = starD;
								closestStar = star;
								
							}
							
						}
						
					}
					
					if (closestD < (1.5 * (1/zoomingValue))) {
						//NSLog(@"Delta of closest: %f",closestD);
						[[[renderer interface] theNameplate] setSelectedType:2];
						/*if (closestStar.name == @"" || closestStar.name == @" ") {
						 [[[renderer interface] theNameplate] setName:NSLocalizedString(@"Nameless star", @"") inConstellation:closestStar.bayer showInfo:YES];
						 }*/
						//else {
						@try {
							if([[closestStar bayer] isEqualToString:@""] || [[closestStar bayer] isEqualToString:@" "] || ![closestStar bayer]) {
								[[[renderer interface] theNameplate] setName:NSLocalizedString(closestStar.name, @"") inConstellation:@"" showInfo:YES];
							}
							else {
								@try {
									NSString* constellationStr = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-3, 3)];
									NSString* greekStrTmp;
									NSString* numberStr;
									NSString* numberStr2;
									char first;
									if(![[NSScanner scannerWithString:[[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-4, 1)]] scanInt:nil]) {
										numberStr2 = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-4, 1)];
										greekStrTmp = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-7, 3)];
										first = [greekStrTmp characterAtIndex:2];
										if(isupper(first)) {
											greekStrTmp = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-6, 2)];
										}
										numberStr = [[closestStar bayer] substringWithRange:NSMakeRange(0, [[closestStar bayer] length]-7)];
									}
									else {
										numberStr2 = [NSString stringWithString:@""];
										greekStrTmp = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-6, 3)];
										first = [greekStrTmp characterAtIndex:2];
										if(isupper(first)) {
											greekStrTmp = [[closestStar bayer] substringWithRange:NSMakeRange([[closestStar bayer] length]-6, 2)];
										}
										numberStr = [[closestStar bayer] substringWithRange:NSMakeRange(0, [[closestStar bayer] length]-6)];
									}
									NSString* greekStr = [[NSString alloc] init];
									if([greekStrTmp isEqualToString:@"Alp"])
										greekStr = @"α";
									else if([greekStrTmp isEqualToString:@"Bet"])
										greekStr = @"β";
									else if([greekStrTmp isEqualToString:@"Gam"])
										greekStr = @"γ";
									else if([greekStrTmp isEqualToString:@"Del"])
										greekStr = @"δ";
									else if([greekStrTmp isEqualToString:@"Eps"])
										greekStr = @"ε";
									else if([greekStrTmp isEqualToString:@"Zet"])
										greekStr = @"ζ";
									else if([greekStrTmp isEqualToString:@"Eta"])
										greekStr = @"η";
									else if([greekStrTmp isEqualToString:@"The"])
										greekStr = @"θ";
									else if([greekStrTmp isEqualToString:@"Iot"])
										greekStr = @"ι";
									else if([greekStrTmp isEqualToString:@"Kap"])
										greekStr = @"κ";
									else if([greekStrTmp isEqualToString:@"Lam"])
										greekStr = @"λ";
									else if([greekStrTmp isEqualToString:@"Mu"])
										greekStr = @"μ";
									else if([greekStrTmp isEqualToString:@"Nu"])
										greekStr = @"ν";
									else if([greekStrTmp isEqualToString:@"Xi"])
										greekStr = @"ξ";
									else if([greekStrTmp isEqualToString:@"Omi"])
										greekStr = @"ο";
									else if([greekStrTmp isEqualToString:@"Pi"])
										greekStr = @"π";
									else if([greekStrTmp isEqualToString:@"Rho"])
										greekStr = @"ρ";
									else if([greekStrTmp isEqualToString:@"Sig"])
										greekStr = @"σ";
									else if([greekStrTmp isEqualToString:@"Tau"])
										greekStr = @"τ";
									else if([greekStrTmp isEqualToString:@"Ups"])
										greekStr = @"υ";
									else if([greekStrTmp isEqualToString:@"Phi"])
										greekStr = @"φ";
									else if([greekStrTmp isEqualToString:@"Chi"])
										greekStr = @"χ";
									else if([greekStrTmp isEqualToString:@"Psi"])
										greekStr = @"ψ";
									else if([greekStrTmp isEqualToString:@"Ome"])
										greekStr = @"ω";
									else {
										NSLog(@"Griekse letter: %@",greekStrTmp);
										greekStr = @"";
									}
									[[[renderer interface] theNameplate] setName:NSLocalizedString(closestStar.name, @"") inConstellation:[NSString stringWithFormat:@"%@ %@ %@",numberStr,greekStr,constellationStr] showInfo:YES];
									
								}
								@catch (NSException * e) {
									[[[renderer interface] theNameplate] setName:NSLocalizedString(closestStar.name, @"") inConstellation:[closestStar bayer] showInfo:YES];
									
								}
								@finally {
									
								}
								
								
								
								//}
								//[greekStrTmp release];
								//[numberStr release];
								//[constellationStr release];
								//[greekStr release];
							}
						}
						@catch(NSException * exception) {
							[[[renderer interface] theNameplate] setName:NSLocalizedString(closestStar.name, @"") inConstellation:@"" showInfo:YES];
						}
						[[renderer interface] setANameplate:TRUE];
						[[[renderer interface] starInfo] starClicked:closestStar];
						
						
						Vertex3D position = Vector3DMake([closestStar position].x, [closestStar position].y, [closestStar position].z);
						
						[renderer setHighlightPosition:position];
						[renderer setObjectInFocus:closestStar];
						[renderer setSelectedStar:closestStar];
						[renderer setPlanetHighlighted:FALSE];
						[renderer setSelectedPlanet:nil];
						[renderer setHighlightSize:32]; 
						[renderer setHighlight:TRUE];
						
					}
					else {
						if ([[[renderer interface] theNameplate] visible]) {
							
							[renderer setHighlight:FALSE];
							[renderer setSelectedStar:nil];
							[renderer setPlanetHighlighted:FALSE];
							[renderer setSelectedPlanet:nil];
							[renderer setObjectInFocus:nil];
							[[[renderer interface] theNameplate] hide];
							[[renderer interface] setANameplate:TRUE];
							
							
						}
					}
				}
				
			}
			
		}	
		//}
		
		
	}
	
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	NSUInteger touchCount = [touches count]; // Voor kliken mag maar 1 touch gebruikt worden
	UITouch *touch = [[event allTouches] anyObject];
	
	BOOL tappedTwice = NO;
	if ([touch tapCount] == 2 && !UIClick && ScreenClick && touchCount == 1) {
		tappedTwice = YES;
		//NSLog(@"Tapped twice");
		UITouch *aTouch = [touches anyObject];
		int x = [aTouch locationInView:theView].x;
		int y = [aTouch locationInView:theView].y;
		int deltaX = -x+(iPadWidth/2);
		int deltaY = -y+(iPadHeight/2);
		[camera zoomCameraWithX:deltaX andY:deltaY];
	}
	
	else if ([touch tapCount] == 1 && !UIClick && ScreenClick && touchCount == 2) {
		[camera zoomCameraOut];
	}
	
	if(UIClick && touchCount == 1) {
		//NSLog(@"Clicked the interface");
		[[renderer interface] touchEndedAndExecute:YES];	
	}
	else if(ScreenClick && dTouch < 4 && touchCount == 1 && ![renderer planetView]) {
		[self performSelector:@selector(checkScreenObjectClicked:) withObject:touches];
		//[self.nextResponder touchesEnded:touches withEvent:event];
	}
	else {
		UITouch *aTouch = [touches anyObject];
		int x, y;
		
		dTouch = 0; // zet delta touch terug naar nul
		
		//testen voor swipe
		x = [aTouch locationInView:theView].x - [aTouch previousLocationInView:theView].x;
		y = [aTouch locationInView:theView].y - [aTouch previousLocationInView:theView].y;
		
		if(x > 5 || x < -5) {
			//NSLog(@"swipe horizontal");
			[camera initiateHorizontalSwipeWithX:x];
		}
		if(y > 5 || y < -5) {
			[camera initiateVerticalSwipeWithY:y];
		}
		else {
			//geen swipe, enkele touch?
			//[camera RAAndDecForPoint:[aTouch previousLocationInView:theView]];
		}
	}
	
}

@end