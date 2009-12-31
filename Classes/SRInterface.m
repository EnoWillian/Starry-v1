//
//  SRInterface.m
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


#import "SRInterface.h"
#import "SRRenderer.h"
#import "SRModule.h"

@implementation SRInterface

@synthesize timeModule,renderer,theNameplate, messierInfo, planetInfo, showingMessier, aNameplate;

-(id)initWithRenderer:(SRRenderer*)theRenderer {
	if(self = [super init]) {
		renderer = theRenderer;
		camera = [theRenderer camera];
		
		appDelegate = [[UIApplication sharedApplication] delegate];
		
		menuVisible = TRUE;
		
		
		[self loadMenu];
		[self loadModules];
		[self loadNameplate];
		[self loadTexture:@"click.png" intoLocation:textures[[UIElements count]]];
		
		messierInfo = [[SRMessierInfo alloc] init];
		planetInfo = [[SRPlanetInfo alloc] init];
		
		defaultTextureBool = TRUE;
		alphaDefault = 1.0f;
		yTranslate = 0.0f;
		defaultTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"defaultTexture.png"]];
		aFade = TRUE;
		
		xTranslate = 0;
		[[[UIElements objectAtIndex:[UIElements count] - 1] texture] invertTexCoord];
		
		notFoundTextureBool = FALSE;
		alphaNotFound = 0.0f;
		notFoundTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"notFound.png"]];
		foundTextString = [[NSString alloc] initWithString:@"Gevonden:"];
		foundText = [[Texture2D alloc] initWithString:foundTextString dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
		foundObjectText = [[Texture2D alloc] initWithString:@"M31" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
		bFade = FALSE;
	}
	return self;
}

-(void)loadNameplate {
	theNameplate = [[SRNamePlate alloc] init];
}


- (void)loadTextureWithString:(NSString *)text intoLocation:(GLuint)location {
	//Text opzetten
	UIFont* font;	
	CGRect rect = {0,0,32,32};
		
	UIGraphicsBeginImageContext(rect.size);
	
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, rect);
	
	CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 0.6);
    CGContextFillEllipseInRect(ctx, rect);

	[[UIColor lightGrayColor] setFill];
	font = [UIFont boldSystemFontOfSize:20];
	CGPoint point = CGPointMake((rect.size.width / 2) - ([text sizeWithFont:font].width / 2), (rect.size.height / 2) - ([text sizeWithFont:font].height / 2));
	
	[text drawAtPoint:point withFont:font];	
	
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGImageRef textureImageTemp = outputImage.CGImage;
	
	CGImageRef textureImage = [self CGImageRotatedByAngle:textureImageTemp angle:90];
	
	NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
		
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
	CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);	
	
	CGContextTranslateCTM(textureContext, 0, rect.size.height);
	CGContextScaleCTM(textureContext, 1.0, -1.0);
	CGContextSetBlendMode(textureContext, kCGBlendModeCopy);
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
}

- (void)loadTexture:(NSString *)name intoLocation:(GLuint)location {
	CGImageRef textureImage = [UIImage imageNamed:name].CGImage;
    if (textureImage == nil) {
        NSLog(@"Failed to load texture image");
		return;
    }
	
    NSInteger texWidth = CGImageGetWidth(textureImage);
    NSInteger texHeight = CGImageGetHeight(textureImage);
	
	GLubyte *textureData = (GLubyte *)malloc(texWidth * texHeight * 4);
	
    CGContextRef textureContext = CGBitmapContextCreate(textureData,
														texWidth, texHeight,
														8, texWidth * 4,
														CGImageGetColorSpace(textureImage),
														kCGImageAlphaPremultipliedLast);
	CGContextTranslateCTM (textureContext, 0, texHeight);
	CGContextScaleCTM (textureContext, 1.0, -1.0);
	CGContextSetBlendMode(textureContext, kCGBlendModeCopy);
	CGContextDrawImage(textureContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), textureImage);
	CGContextRelease(textureContext);
	
	glBindTexture(GL_TEXTURE_2D, location);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
	
	free(textureData);
	
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	//glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);	//werkt niet goed! 
}

-(void)loadMenu {
	//elementen inladen
	UIElements = [[NSMutableArray alloc] init];
	
	//main menu met knoppen

	
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(0, -63, 480, 63) 
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"nav_bg.png"]] 
														  identifier:@"menu" 
														   clickable:NO]];
		  
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(12, -55, 31, 31)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"radar.png"]] 
														  identifier:@"location" 
														   clickable:YES]];
	  
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(62, -55, 31, 31)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"calendar.png"]]
														  identifier:@"time" 
														   clickable:YES]];
	
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(112, -55, 31, 31)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"planeticon.png"]]
														  identifier:@"planet" 
														   clickable:YES]];
	
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(165, -55, 179, 32)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"search.png"]] 
														  identifier:@"searchfield" 
														   clickable:YES]];
	   
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(345, -55, 31, 31)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"searchicon.png"]] 
														  identifier:@"search" 
														   clickable:NO]];
	 
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(392, -55, 31, 31)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"gears.png"]] 
														  identifier:@"settings" 
														   clickable:YES]];
	
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(0, -63, 480, 63) 
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"indicator_overlay.png"]] 
														  identifier:@"menu_overlay" 
														   clickable:NO]];		
		
	[UIElements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(440, 8, 32, 32)  
															 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]] 
														  identifier:@"arrow" 
														   clickable:YES]];
	
	xTranslate = 63;
}

-(void)loadModules {
	modules = [[NSMutableArray alloc] init];
	
	//tijd	
	timeModule = [[SRTimeModule alloc] init];
	[modules addObject:timeModule];
	
	//locatie
	locationModule = [[SRLocationModule alloc] initWithSRLocation:[renderer location]];
	[modules addObject:locationModule];
	
	//planets
	planetModule = [[SRPlanetModule alloc] init];
	[modules addObject:planetModule];
	
	//settings
	settingsModule = [[SRSettingsModule alloc] init];
	[modules addObject:settingsModule];
}

-(void)renderInterface {
	//we rekenen uit hoelang het per frame is om animaties smooth te laten verlopen
	if (lastDrawTime) { timeElapsed = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime; }
    lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
	
	// -- animaties..
	[self calculateAnimations];
	[[timeModule manager] tickOfTime:timeElapsed];
	//NSLog(@"%f", timeElapsed);
	
	glMatrixMode(GL_PROJECTION); 
	glLoadIdentity();
	glRotatef(-90.0, 0.0, 0.0, 1.0); //x hor, y vert
	glOrthof(0.0, 480, 0.0, 320, -1.0, 1.0); //projectie opzetten
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	//glDepthMask(GL_FALSE); 
	
	//glAlphaFunc( GL_EQUAL, 1.0f );
	//glEnable( GL_ALPHA_TEST );

	
	glColor4f(1.0, 1.0, 1.0, 1.0);      
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glTexCoordPointer(2, GL_FLOAT, 0, textureCoords);
	glDisableClientState(GL_COLOR_ARRAY);
    glColor4f(1.0, 1.0, 1.0, 1.0);      
    glVertexPointer(3, GL_FLOAT, 0, textureCorners);
    glEnableClientState(GL_VERTEX_ARRAY);
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(1.0, 1.0, 1.0, 1.0);      

	[theNameplate draw];
	
	glTranslatef(0, xTranslate, 0);
	
	
	int i = 0;
	for (SRInterfaceElement* element in UIElements) {
		
		if([element identifier] == @"arrow") {
			glTranslatef(0, -xTranslate, 0);
			[[element texture] drawInRect:[element bounds]];
			glTranslatef(0, xTranslate, 0);
		} 
		else if ([element identifier] == @"menu") {
			[[element texture] drawInRect:[element bounds]];
		}
		else if (menuVisible) {
			glTranslatef(0, -yTranslate, 0);
			[[element texture] drawInRect:[element bounds]];
			glTranslatef(0, yTranslate, 0);
		}
		
		++i;
	}
	
	for (SRModule* module in modules) {
		if([module visible]) {
			[module draw];
		}
	}
	
	glTranslatef(0, -xTranslate, 0);
	

	if(isClicking) {
		GLfloat touchCorners[] = {
			rectClicked.origin.x, rectClicked.origin.y + rectClicked.size.height, 0,
			rectClicked.origin.x + rectClicked.size.width, rectClicked.origin.y + rectClicked.size.height, 0,
			rectClicked.origin.x + rectClicked.size.width, rectClicked.origin.y, 0,
			rectClicked.origin.x, rectClicked.origin.y, 0
		};
		
		GLfloat touchCoords[] = {
			0, 1,
			1, 1,
			1, 0, 
			0, 0
		};
		
		glTexCoordPointer(2, GL_FLOAT, 0, touchCoords);
		glVertexPointer(3, GL_FLOAT, 0, touchCorners);
		
		glBindTexture(GL_TEXTURE_2D, textures[[UIElements count]]);
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
	}
	
	if(showingMessier) {
		[messierInfo draw];
	}
	
	if(showingPlanet) {
		[planetInfo draw];
	}
	
	if([[appDelegate settingsManager] showRedOverlay]) {
		[self drawRedOverlay];
	}

	if(defaultTextureBool) {
		glColor4f(1.0, 1.0, 1.0, alphaDefault);      
		[defaultTexture drawInRect:CGRectMake(0,-192,512,512)];
	}
	if(notFoundTextureBool) {
		glColor4f(1.0, 1.0, 1.0, alphaNotFound);      
		[notFoundTexture drawInRect:CGRectMake(176,68,128,64)];
		[searchIcon drawInRect:CGRectMake(220,87,39,39)];
		glColor4f(0.5, 0.5, 0.5, alphaNotFound);   
		
		float combinedwidth = [foundTextString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]].width + 
							  [foundObjectTextString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]].width + 5;
		
		[foundText drawInRect:CGRectMake(240 - combinedwidth / 2,55,64,32)];
		if(searchResult)
			glColor4f(0.56f, 0.831f, 0.0f, alphaNotFound);
		else 
			glColor4f(1.0f, 0.2f, 0.2f, alphaNotFound);
		[foundObjectText drawInRect:CGRectMake(240 - combinedwidth / 2 + [foundTextString sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:11.0]].width + 2,55,64,32)];
	}
	
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
			
	glDisable(GL_TEXTURE_2D); 
}

-(void)drawRedOverlay {
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
	const GLfloat redOverlay[] = {
		0.0, 0.0, 0.0,			1.0f, 0.0f, 0.0f, 0.5f,			//bottom-left
		0.0, 320.0, 0.0,		1.0f, 0.0f, 0.0f, 0.5f,			//top-left
		480.0, 0.0, 0.0,		1.0f, 0.0f, 0.0f, 0.5f,			//bottom-right
		480.0, 320.0, 0.0,		1.0f, 0.0f, 0.0f, 0.5f,			//top-right
	};
	
	glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
	glEnableClientState(GL_VERTEX_ARRAY);
	//glEnableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glVertexPointer(3, GL_FLOAT, 28, redOverlay);
	//glColorPointer(4, GL_FLOAT, 28, &redOverlay[3]);	
	glColor4f(1.0f, 0.0f, 0.0f, 1.0f);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(BOOL)UIElementAtPoint:(CGPoint)point {
	
	BOOL flag = FALSE;

	if(showingMessier == TRUE) {
		[messierInfo hide];
		aMessier = YES;
		clicker = @"messierinfo";
		return TRUE;
	}
	
	if(showingPlanet == TRUE) {
		[planetInfo hide];
		aPlanet = YES;
		clicker = @"planetinfo";
		return TRUE;
	}
	
	//checken of het onder een UIElement valt
	for (SRInterfaceElement* element in UIElements) {		
		if([element identifier] == @"arrow") {
			if(CGRectContainsPoint([element bounds], CGPointMake(point.y, point.x)) && !flag && [element clickable]) {
				clicker = [element identifier];
				isClicking = TRUE;
				CGRect clicked = [element bounds];
				rectClicked = CGRectInset(clicked, -16, -16);
				flag = TRUE;
			}
		}		
		else if(CGRectContainsPoint([element bounds], CGPointMake(point.y, point.x - xTranslate)) && !flag && [element clickable] && menuVisible)  {
			clicker = [element identifier];
			isClicking = TRUE;
			CGRect clicked = [element bounds];
			clicked.origin.y += xTranslate;
			rectClicked = CGRectInset(clicked, -16, -16);
			flag = TRUE;
		}
	}
	
	if(!menuVisible) {
	for (SRModule* module in modules) {
		if([module visible]) {
			for (SRInterfaceElement* element in [module elements]) {
				if(CGRectContainsPoint([element bounds], CGPointMake(point.y, point.x - xTranslate)) && !flag && [element clickable])  {
					clicker = [element identifier];
					isClicking = TRUE;
					CGRect clicked = [element bounds];
					clicked.origin.y += xTranslate;
					rectClicked = CGRectInset(clicked, -16, -16);
					flag = TRUE;
				}				
			}
		}
	}
	}
	
	if([theNameplate visible] && [theNameplate info]) {
		for (SRInterfaceElement* element in [theNameplate elements]) {
			if(CGRectContainsPoint([element bounds], CGPointMake(point.y, point.x + [theNameplate yTranslate])) && !flag && [element clickable])  {
				clicker = [element identifier];
				isClicking = TRUE;
				CGRect clicked = [element bounds];
				clicked.origin.y -= [theNameplate yTranslate];
				rectClicked = CGRectInset(clicked, -16, -16);
				flag = TRUE;
			}				
		}
	}
	return flag;
}

-(void)touchEndedAndExecute:(BOOL)result {
	isClicking = FALSE;
	
	// Als er een keyboard omhoog staat mag er niet nog een keer een keyboard omhoog komen.
	// Als de click niet weggesleept is mag er door worden gegaan
	if(![fieldTmp isFirstResponder] && result && clicker != @"messierinfo" && clicker != @"planetinfo") {
		
		BOOL flagToggle = FALSE;
	
		if(clicker == @"time") {
			//show tijd crap
			if([timeModule visible]) {
				[timeModule hide];	
				aModule = TRUE;
			}
			else {
				/* voordat je een nieuwe module laat zien moet je eerst een oude verbergen */
				[[UIElements objectAtIndex:2] setBounds:CGRectZero];
				[self hideAllModules];
				[timeModule show];
				aModule = TRUE;
			}
		}
		else if(clicker == @"location") {
			//show tijd crap
			if([locationModule visible]) {
				[locationModule hide];	
				aModule = TRUE;
			}
			else {
				/* voordat je een nieuwe module laat zien moet je eerst een oude verbergen */
				[[UIElements objectAtIndex:1] setBounds:CGRectZero];
				[self hideAllModules];
				[locationModule show];
				aModule = TRUE;
			}
		}
		else if(clicker == @"settings") {
			if([settingsModule visible]) {
				[settingsModule hide];	
				aModule = TRUE;
			}
			else {
				/* voordat je een nieuwe module laat zien moet je eerst een oude verbergen */
				[[UIElements objectAtIndex:6] setBounds:CGRectZero];
				[self hideAllModules];
				[settingsModule show];
				aModule = TRUE;
			}
		}
		else if(clicker == @"planet") {
			if([planetModule visible]) {
				[planetModule hide];	
				aModule = TRUE;
			}
			else {
				/* voordat je een nieuwe module laat zien moet je eerst een oude verbergen */
				[[UIElements objectAtIndex:3] setBounds:CGRectZero];
				[self hideAllModules];
				[planetModule show];
				aModule = TRUE;
				[renderer setPlanetView:TRUE];
				[theNameplate hide];
				aNameplate = TRUE;
				[camera setPlanetView:TRUE];
				[camera resetZoomValue];
			}
		}
		else if(clicker == @"searchfield" || clicker == @"search") {
			currentlyEditingIdentifier = @"search";
			[self bringUpTheKeyboardWithText:@"" onLocationX:9 Y:175 withColor:[UIColor blackColor] andSendResultsTo:self];
		}
		else if(clicker == @"arrow") {
			flagToggle = YES;
			[[[UIElements objectAtIndex:[UIElements count] - 1] texture] invertTexCoord];
		}
		// Knoppen voor de tijd module
		else if(clicker == @"playpause") {
			[[timeModule manager] playPause];
		}
		else if(clicker == @"stop") {
			[[timeModule manager] reset];
		}
		else if(clicker == @"fwd") {
			[[timeModule manager] fwd];
		}
		else if(clicker == @"rew") {
			[[timeModule manager] rew];
		}
		// Knoppen voor de locatie module
		else if(clicker == @"lat-edit" || clicker == @"lat") {
			NSNumber* aNumber = [[NSNumber alloc] initWithFloat:[locationModule latitude]];
			currentlyEditingIdentifier = @"lat";
			[locationModule setLatVisible:NO];
			[self bringUpTheKeyboardWithText:[aNumber stringValue] onLocationX:0 Y:104 withColor:[UIColor whiteColor] andSendResultsTo:self]; // 74 omdat dit ook de locatie is van de data
			//Waarom reset de interface zich naar alles ingeklapt?
			
			if([locationModule GPS]) {
				[locationModule toggleGPS];	
			}
			
			[aNumber release];
		}
		else if(clicker == @"long-edit" || clicker == @"long") {
			NSNumber* aNumber = [[NSNumber alloc] initWithFloat:[locationModule longitude]];
			currentlyEditingIdentifier = @"long";
			[locationModule setLongVisible:NO];
			[self bringUpTheKeyboardWithText:[aNumber stringValue] onLocationX:0 Y:224 withColor:[UIColor whiteColor] andSendResultsTo:self]; // 174 omdat dit ook de locatie is van de data
			//Waarom reset de interface zich naar alles ingeklapt?
			
			if([locationModule GPS]) {
				[locationModule toggleGPS];	
			}
			
			[aNumber release];
		}
		else if(clicker == @"gps-toggle") {
			[locationModule toggleGPS];
		}
		else if(clicker == @"red") {
			if(![[appDelegate settingsManager] showRedOverlay]) {
				[[appDelegate settingsManager] setShowRedOverlay:TRUE];
			}
			else {
				[[appDelegate settingsManager] setShowRedOverlay:FALSE];
			}
		}
		else if(clicker == @"brightness_plus") {
			float brightness = [[appDelegate settingsManager] brightnessFactor];
			brightness += 0.1;
			[[appDelegate settingsManager] setBrightnessFactor:brightness];
		}
		else if(clicker == @"brightness_minus") {
			float brightness = [[appDelegate settingsManager] brightnessFactor];
			brightness -= 0.1;
			[[appDelegate settingsManager] setBrightnessFactor:brightness];
		}		
		else if(clicker == @"constellations") {
			BOOL constellations = [[appDelegate settingsManager] showConstellations];
			if(constellations) {
				[[appDelegate settingsManager] setShowConstellations:FALSE];
			}
			else {
				[[appDelegate settingsManager] setShowConstellations:TRUE];
			}
		}		
		else if(clicker == @"info") {
			if([theNameplate selectedType] == 0) {
				[messierInfo show];
				aMessier = YES;
				showingMessier = YES;
			}
			else if([theNameplate selectedType] == 1) {
				[planetInfo show];
				aPlanet = YES;
				showingPlanet = YES;				
			}
		}	
		else if(clicker == @"icon") {	
			if([timeModule visible]) {
				[timeModule hide];	
				[[UIElements objectAtIndex:2] setBounds:CGRectMake(62, -55, 31, 31)];
				aModule = TRUE;
			}
			if([locationModule visible]) {
				[locationModule hide];
				[[UIElements objectAtIndex:1] setBounds:CGRectMake(12, -55, 31, 31)];
				aModule = TRUE;
			}
			if([settingsModule visible]) {
				[settingsModule hide];
				[[UIElements objectAtIndex:6] setBounds:CGRectMake(392, -55, 31, 31)];
				aModule = TRUE;
			}
			if([planetModule visible]) {
				[camera setPlanetView:FALSE];
				[camera resetZoomValue];
				[planetModule hide];
				[[timeModule manager] setSpeed:1];
				[[UIElements objectAtIndex:3] setBounds:CGRectMake(112, -55, 31, 31)];
				aModule = TRUE;
				[renderer setPlanetView:FALSE];
			}
			
			hidingMenu = FALSE;
			aMenu = TRUE;
			menuVisible = TRUE;
		}
		
		if(flagToggle) {
			if(!aInterface) {
				if(xTranslate == 0) {
					[self hideInterface]; 
				}
				else {
					[self showInterface]; 
				}
			}
		}
		
	}
}

-(void)calculateAnimations {
	//als interval te groot is worden animaties onmiddelijk. Dit willen we voorkomen.
	if(timeElapsed > 0.1) {
		return;
	}
	
	if(aMenu) {
		if(hidingMenu) {
			yTranslate += 7 * (timeElapsed / 0.05); 
			
			if(yTranslate >= 63) {
				aMenu = FALSE;
				menuVisible = NO;
				yTranslate = 63;
			}
		}
		else {
			yTranslate -= 7 * (timeElapsed / 0.05); 
			
			if(yTranslate <= 0) {
				aMenu = FALSE;
				yTranslate = 0;
				
			}
			
		}
	}
	
	if(aMessier) {
		if([messierInfo hiding]) {
			[messierInfo setAlphaValue:[messierInfo alphaValue] - ( 0.1f * (timeElapsed / 0.05) )];
			[messierInfo setAlphaValueName:[messierInfo alphaValueName] - ( 0.1f * (timeElapsed / 0.05) )];
			if([messierInfo alphaValue] <= 0.0f) {
				aMessier = FALSE;
				showingMessier = FALSE;
				[messierInfo setHiding:FALSE];
			}
		}
		else {
			[messierInfo setAlphaValue:[messierInfo alphaValue] + ( 0.1f * (timeElapsed / 0.05) )];
			[messierInfo setAlphaValueName:[messierInfo alphaValueName] + ( 0.1f * (timeElapsed / 0.05) )];
			if([messierInfo alphaValueName] >= 1.0f) {
				aMessier = FALSE;
				[messierInfo setAlphaValue: 1.0f];
				[messierInfo setAlphaValueName: 1.0f];
			}
		}	
	}
	
	if(aPlanet) {
		if([planetInfo hiding]) {
			[planetInfo setAlphaValue:[planetInfo alphaValue] - ( 0.1f * (timeElapsed / 0.05) )];
			[planetInfo setAlphaValueName:[planetInfo alphaValueName] - ( 0.1f * (timeElapsed / 0.05) )];
			if([planetInfo alphaValue] <= 0.0f) {
				aPlanet = FALSE;
				showingPlanet = FALSE;
				[planetInfo setHiding:FALSE];
			}
		}
		else {
			[planetInfo setAlphaValue:[planetInfo alphaValue] + ( 0.1f * (timeElapsed / 0.05) )];
			[planetInfo setAlphaValueName:[planetInfo alphaValueName] + ( 0.1f * (timeElapsed / 0.05) )];
			if([planetInfo alphaValueName] >= 1.0f) {
				aPlanet = FALSE;
				[planetInfo setAlphaValue: 1.0f];
				[planetInfo setAlphaValueName: 1.0f];
			}
		}	
	}
	
	
	if(aModule) {
		for (SRModule* module in modules) {
			if([module visible]) {
				if([module hiding]) {
					[module setAlphaValue:[module alphaValue] - ( 0.1f * (timeElapsed / 0.05) ) ];
					if([module alphaValue] <= 0.0f) {
						aModule = FALSE;
						[module setVisible:NO]; 
						[module setHiding:NO];
						[module setAlphaValue:0.0f];
					}
				}
				else {
					if([module xValueIcon] > 12) {
						[module setXValueIcon:[module xValueIcon] - ((([module initialXValueIcon] - 12) / 8) * (timeElapsed / 0.05) )];
					}
					if([module xValueIcon] <= 12) {
						[module setXValueIcon:12];	
					}					
					
					[module setAlphaValue:[module alphaValue] + ( 0.1f * (timeElapsed / 0.05) ) ];
					if([module alphaValue] >= 1.0f) {
						[module setAlphaValue:1.0f];
					}
					
					if([module alphaValue] == 1.0f && [module xValueIcon] == 12) {
						aModule = FALSE;
						[module setHiding:TRUE];
					}
				}
			}
		}
	}
	
	if(aNameplate) {
		if([theNameplate hiding]) {
			[theNameplate setYTranslate:[theNameplate yTranslate] + ( 6 * (timeElapsed / 0.05) )]; }
		else {
			[theNameplate setYTranslate:[theNameplate yTranslate] - ( 6 * (timeElapsed / 0.05) )];  }
		
		
		if([theNameplate yTranslate] <= 0) {
			aNameplate = FALSE;
			//[theNameplate setHiding:TRUE];
			[theNameplate setYTranslate:0];
		}
		else if ([theNameplate yTranslate] >= 32) {
			[theNameplate setYTranslate:32];
			aNameplate = FALSE;
			[theNameplate setVisible:NO];
		} 
	}
	
	if(aInterface) {
		if(interfaceDown) {
			xTranslate += 7 * (timeElapsed / 0.05); }
		else {
			xTranslate -= 7 * (timeElapsed / 0.05); }
		
		if(xTranslate >= 63.0) {
			aInterface = FALSE;
			xTranslate = 63;
		}
		else if(xTranslate < 0.0) {
			aInterface = FALSE;
			xTranslate = 0;
		}
	}
	
	if(aFade) {
		alphaDefault -= 0.05 * (timeElapsed / 0.05);
		if (alphaDefault <= 0.0) {
			defaultTextureBool = FALSE;
			aFade = FALSE;
		}	
	}
	if(bFade) {
		alphaNotFound -= 0.01 * (timeElapsed / 0.01);
		if (alphaNotFound <= 0.0) {
			notFoundTextureBool = FALSE;
			bFade = FALSE;
		}
	}
}

-(void)hideInterface {
	aInterface = TRUE;
	interfaceDown = TRUE;
}

-(void)showInterface {
	aInterface = TRUE;
	interfaceDown = FALSE;
}

-(void) hideAllModules {
	hidingMenu = TRUE;
	aMenu = TRUE;
}



-(GLuint)textures {
	return textures[1];
}

- (CGImageRef)CGImageRotatedByAngle:(CGImageRef)imgRef angle:(CGFloat)angle
{
	// Uitleg: http://blog.coriolis.ch/2009/09/04/arbitrary-rotation-of-a-cgimage/
	
	CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, FALSE);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextTranslateCTM(bmContext,
						  -(rotatedRect.size.width/2),
						  -(rotatedRect.size.height/2));
	
	CGContextScaleCTM(bmContext, 1, -1);
	CGContextTranslateCTM(bmContext, 0, -height);
	
	CGContextDrawImage(bmContext, CGRectMake(0, 0,
											 rotatedRect.size.width,
											 rotatedRect.size.height),
					   imgRef);
	
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
	[(id)rotatedImage autorelease];
	
	return rotatedImage;
}

-(void)bringUpTheKeyboardWithText:(NSString *)placeholder onLocationX:(int)locX Y:(int)locY withColor:(UIColor*)color andSendResultsTo:(id)delegate {
	//NSLog(@"Bring up the Keyboard");
	
	fieldTmp = [[UITextField alloc] initWithFrame:CGRectMake((locX-26), (locY+25), 80, 32)];
	[fieldTmp setFont:[UIFont fontWithName:@"Helvetica-Bold" size:11]];
	[fieldTmp setTextColor:color];
	[fieldTmp setTextAlignment:UITextAlignmentLeft];
	[fieldTmp setDelegate:delegate];
	[fieldTmp setText:placeholder];
	[fieldTmp setAutocorrectionType:UITextAutocorrectionTypeNo];
	[fieldTmp setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[fieldTmp setReturnKeyType:UIReturnKeyDone];
	[fieldTmp setTransform:CGAffineTransformMakeRotation(M_PI / 2.0)];
	if	(currentlyEditingIdentifier == @"lat" || currentlyEditingIdentifier == @"long") {
		[fieldTmp setKeyboardType:UIKeyboardTypeNumbersAndPunctuation]; // UIKeyboardTypeNumberPad werkt niet omdat deze geen '.' en 'return' knop heeft
	}
	
	[fieldTmp setClearsOnBeginEditing:NO];
	// Unhide de uiElementsView (Anders werkt de multitouch in glView niet)
	[[appDelegate uiElementsView] setHidden:NO];
	// We moeten de view toevoegen aan de glView
 	[[appDelegate uiElementsView] addSubview:fieldTmp];
	// Nu om focus te zetten op dit UI element
	[fieldTmp becomeFirstResponder];
	// Nu transleren we de hele glView naar boven om plaats te maken voor het keyboard, met animatie
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3]; // 0.3 lijkt even snel te zijn als het keyboard.
	[[appDelegate glView] setTransform:CGAffineTransformMakeTranslation(160 , 0)];
	[UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if(textField == fieldTmp) {
		// Hide de uiElementsView
		[[appDelegate uiElementsView] setHidden:YES];
		// Nu transleren we de hele glView weer naar beneden omdat het keyboard weg gaat.
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3]; // 0.3 lijkt even snel te zijn als het keyboard.
		// van 160,0 terug naar 0,0
		[[appDelegate glView] setTransform:CGAffineTransformMakeTranslation(0 , 0)];
		[UIView commitAnimations];
		
		NSString *aValue = [[NSString alloc] initWithString:[fieldTmp text]];
		
		if	(currentlyEditingIdentifier == @"lat") {
			[[locationModule locationManager] useStaticValues];
			[[locationModule locationManager] setLatitude:[aValue floatValue]];
			//[locationModule updateDisplayedLocationData]; // Wordt al gedaan in setLatitude
			[locationModule setLatVisible:YES];
		}
		else if (currentlyEditingIdentifier == @"long") {
			[[locationModule locationManager] useStaticValues];	
			[[locationModule locationManager] setLongitude:[aValue floatValue]];
			//[locationModule updateDisplayedLocationData]; // Wordt al gedaan in setLongitude
			[locationModule setLongVisible:YES];
		}
		else if (currentlyEditingIdentifier == @"search") {
			SRMessier * aMessierObject;
			SRPlanetaryObject* bPlanet; // aPlanet is een ivar
			SRStar* aStar;
			SRConstellation* aConstellation;
			SRMessier * foundMessier;
			SRStar * foundStar;
			SRConstellation* foundConstellation;
			SRPlanetaryObject* foundPlanet;
			SRSun* foundSun;
			SRMoon* foundMoon;
			searchResult = FALSE;
			
			BOOL found = FALSE;
			
			int type; //0 = messier, 1 = planet, 2 = ster, 3 = sterrenbeeld, 4 = zon, 5 = maan
			
			for(aMessierObject in [[appDelegate objectManager] messier]) {
				if ([[[aMessierObject name] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
					foundMessier = aMessierObject;
					searchResult = TRUE;
					type = 0;
					found = TRUE;
				}
				else if ([[[aMessierObject name] lowercaseString] hasPrefix:[aValue lowercaseString]] && !found) {
					foundMessier = aMessierObject;
					searchResult = TRUE;
					type = 0;
				}						
			}
			
			for(bPlanet in [[appDelegate objectManager] planets]) {
				if ([[[bPlanet name] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
					foundPlanet = bPlanet;
					searchResult = TRUE;
					type = 1;
					found = TRUE;
				}
				else if ([[[bPlanet name] lowercaseString] hasPrefix:[aValue lowercaseString]] && !found) {
					foundPlanet = bPlanet;
					searchResult = TRUE;
					type = 1;
				}						
			}
			
			for(aStar in [[appDelegate objectManager] stars]) {	
				if ([[[aStar name] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
					foundStar = aStar;
					searchResult = TRUE;
					type = 2;
					found = TRUE;
				}
				else if ([[[aStar name] lowercaseString] hasPrefix:[aValue lowercaseString]] && !found) {
					foundStar = aStar;
					searchResult = TRUE;
					type = 2;
				}						
			}
			
			for(aConstellation in [[appDelegate objectManager] constellations]) {
				if ([[[aConstellation name] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
					foundConstellation = aConstellation;
					searchResult = TRUE;
					type = 3;
					found = TRUE;
				}
				if ([[[aConstellation name] lowercaseString] hasPrefix:[aValue lowercaseString]] && !found) {
					foundConstellation = aConstellation;
					searchResult = TRUE;
					type = 3;
				}						
			}
			
			if ([[[NSString stringWithString:@"Zon"] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
				foundSun = [[appDelegate objectManager] sun];
				searchResult = TRUE;
				type = 4;
				found = TRUE;
			}
			
			if ([[[NSString stringWithString:@"Maan"] lowercaseString] isEqualToString:[aValue lowercaseString]]) {
				foundMoon = [[appDelegate objectManager] moon];
				searchResult = TRUE;
				type = 5;
				found = TRUE;
			}
			
			if(searchResult) {
				if(searchIcon)
					[searchIcon release];
				searchIcon = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"searchYes.png"]];
				
				float azTmp, alTmp;
				
				if(type == 0) { // Messier
					if(foundObjectText)
						foundObjectTextString = foundMessier.name;
						[foundObjectText release];
						foundObjectText = [[Texture2D alloc] initWithString:foundMessier.name dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
						[theNameplate setName:foundMessier.name inConstellation:@"messier" showInfo:YES];
						[messierInfo messierClicked:foundMessier];
						[theNameplate setSelectedType:type];
						Vertex3D posForCam = [foundMessier myCurrentPosition];
						azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
						alTmp = 90-(180/M_PI)*acos(-posForCam.z);
						//NSLog(@"azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
						
						Vertex3D position = foundMessier.position;
						
						[renderer setHighlightPosition:position];
						[renderer setHighlightSize:32]; 
						[renderer setHighlight:TRUE];
					
						[self setANameplate:TRUE];
				}
				else if(type == 1) { //Planeet
					foundObjectTextString = foundPlanet.name;

					if(foundObjectText)
						[foundObjectText release];
					foundObjectText = [[Texture2D alloc] initWithString:foundPlanet.name dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
					
					[theNameplate setName:foundPlanet.name inConstellation:@"planeet" showInfo:YES];
					[planetInfo planetClicked:foundPlanet];
					[theNameplate setSelectedType:type];
					Vertex3D posForCam = [foundPlanet myCurrentPosition];
					azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
					alTmp = 90-(180/M_PI)*acos(-posForCam.z);
					
					//NSLog(@"azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
					
					Vertex3D position = foundPlanet.position;
					
					[renderer setHighlightPosition:position];
					[renderer setHighlightSize:32]; 
					[renderer setHighlight:TRUE];
					
					[self setANameplate:TRUE];
				}
				else if(type == 2) { // Ster
					if(foundObjectText)
						foundObjectTextString = foundStar.name;
					[foundObjectText release];
					foundObjectText = [[Texture2D alloc] initWithString:foundStar.name dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
					[theNameplate setName:foundStar.name inConstellation:foundStar.bayer showInfo:NO];
					//[messierInfo messierClicked:foundStar];
					[theNameplate setSelectedType:type];
					
					Vertex3D posForCam = [foundStar myCurrentPosition];
					azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
					alTmp = 90-(180/M_PI)*acos(-posForCam.z);
					//NSLog(@"azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
					
					Vertex3D position = Vertex3DMake([foundStar.x floatValue],[foundStar.y floatValue],[foundStar.z floatValue]);
					
					[renderer setHighlightPosition:position];
					[renderer setHighlightSize:32]; 
					[renderer setHighlight:TRUE];
					
					[self setANameplate:TRUE];
				}
				else if(type == 3) { // Constellation
					if(foundObjectText)
						foundObjectTextString = foundConstellation.name;
					[foundObjectText release];
					foundObjectText = [[Texture2D alloc] initWithString:foundConstellation.name dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
					
					//Vertex3D posForCam = [foundStar myCurrentPosition];
					Vertex3D posForCam = [foundConstellation myCurrentPosition];
					azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
					alTmp = 90-(180/M_PI)*acos(-posForCam.z);
					
					
					//azTmp = foundConstellation.ra;
					//alTmp = foundConstellation.dec;
					NSLog(@"Sterrenbeeld resultaat: azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
					
				}
				else if(type == 4) {
					foundObjectTextString = [NSString stringWithString:@"Zon"];
					
					if(foundObjectText)
						[foundObjectText release];
					foundObjectText = [[Texture2D alloc] initWithString:@"Zon" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
					
					[theNameplate setName:@"Zon" inConstellation:@"onze ster" showInfo:YES];
					[planetInfo planetClicked:foundSun];
					[theNameplate setSelectedType:type];
					Vertex3D posForCam = [foundSun myCurrentPosition];
					azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
					alTmp = 90-(180/M_PI)*acos(-posForCam.z);
					
					//NSLog(@"azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
					
					Vertex3D position = foundSun.position;
					
					[renderer setHighlightPosition:position];
					[renderer setHighlightSize:32]; 
					[renderer setHighlight:TRUE];
					
					[self setANameplate:TRUE];
				}
				else if (type == 5) {
					foundObjectTextString = [NSString stringWithString:@"Maan"];
					
					if(foundObjectText)
						[foundObjectText release];
					foundObjectText = [[Texture2D alloc] initWithString:@"Maan" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];
					
					[theNameplate setName:@"Maan" inConstellation:@"" showInfo:YES];
					//[planetInfo planetClicked:foundMoon];
					[theNameplate setSelectedType:type];
					Vertex3D posForCam = [foundMoon myCurrentPosition];
					azTmp = (180/M_PI)*atan2(posForCam.y,posForCam.x);
					alTmp = 90-(180/M_PI)*acos(-posForCam.z);
					
					//NSLog(@"azTmp:%f alTmp:%f posZ:%f",azTmp,alTmp,posForCam.z);
					
					Vertex3D position = foundMoon.position;
					
					[renderer setHighlightPosition:position];
					[renderer setHighlightSize:32]; 
					[renderer setHighlight:TRUE];
					
					[self setANameplate:TRUE];
				}

				
				notFoundTextureBool = TRUE;
				alphaNotFound = 1.0f;
				//notFoundTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"notFound.png"]];
				notFoundTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(notFoundFade:) userInfo:nil repeats:NO] retain];				
				
				
				
				[camera setAzimuth:azTmp];
				[camera setAltitude:alTmp];
				[camera adjustView];				
			}
			else {
				if(searchIcon)
					[searchIcon release];
				searchIcon = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"searchNo.png"]];
				
				if(foundObjectText)
					[foundObjectText release];
				foundObjectTextString = [[NSString alloc] initWithString:@"Niets"];
				foundObjectText = [[Texture2D alloc] initWithString:@"Niets" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11.0];				
				
				notFoundTextureBool = TRUE;
				alphaNotFound = 1.0f;
				//notFoundTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:@"notFound.png"]];
				notFoundTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(notFoundFade:) userInfo:nil repeats:NO] retain];
			}
		}
		
		//[fieldTmp setText:@""];
		[fieldTmp removeFromSuperview]; // Verwijder uit glView
		//[fieldTmp release]; /* FIXME Werkt niet als ik fieldTmp hier release maar anders hebben we een leak */
		[aValue release];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}
						  
-(void)fadeDefaultTexture {
	//aFade = TRUE;
}

-(void)notFoundFade:(NSTimer*)theTimer {
	bFade = TRUE;
	[notFoundTimer release];
}


@end
