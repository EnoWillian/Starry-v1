//
//  SRPlanetModule.m
//  Sterren
//
//  Created by Jan-Willem Buurlage on 27-12-09.
//  Copyright 2009 Web6.nl Diensten. All rights reserved.
//

#import "SRPlanetModule.h"


@implementation SRPlanetModule

-(id)init {
	if(self = [super init]) {
		
		initialXValueIcon = 112;
		
		elements = [[NSMutableArray alloc] init];
		
		//laad elements in - sla op in textures
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(12, -55, 31, 31)  
																 texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"planeticon.png"]]
															  identifier:@"icon" 
															   clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(178, -60, 137, 40)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"controls_bg.png"]] 
															identifier:@"controls_bg" 
															 clickable:NO]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(185, -55, 32, 32)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"stop.png"]] 
															identifier:@"stop" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(215, -55, 32, 32)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"rew.png"]] 
															identifier:@"rew" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(245, -55, 32, 32)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"play.png"]] 
															identifier:@"playpause" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(275, -55, 32, 32)
															   texture:[[Texture2D alloc] initWithImage:[UIImage imageNamed:@"fwd.png"]] 
															identifier:@"fwd" 
															 clickable:YES]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(52, -60, 64,32) 
															   texture:[[Texture2D alloc] initWithString:@"SNELHEID:" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:9] 
															identifier:@"text-transparent"
															 clickable:NO]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(105,-58, 64,32) 
															   texture:nil
															identifier:@"speed"
															 clickable:NO]];		
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(65, -75, 64,32) 
															   texture:[[Texture2D alloc] initWithString:@"DATUM:" dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:9] 
															identifier:@"text-transparent" 
															 clickable:NO]];
		
		[elements addObject:[[SRInterfaceElement alloc] initWithBounds:CGRectMake(105,-73, 64,32) 
															   texture:nil
															identifier:@"date" 
															 clickable:NO]];
		

	}
	return self;
}

-(void)draw {
	//draw module zelf
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	for (SRInterfaceElement* mElement in elements) {
		if([mElement identifier] == @"text-transparent") {
			glColor4f(0.4f, 0.4f, 0.4f, alphaValue);
			[[mElement texture] drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
		}
		else if([mElement identifier] == @"date") {
			Texture2D* texture = [[Texture2D alloc] initWithString:[[NSString alloc] initWithFormat:@"%@",[[[[UIApplication sharedApplication] delegate] timeManager] theDate]] dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11];
			glColor4f(0.294f, 0.513f, 0.93f, alphaValue);
			[texture drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
			[texture release];
			
		}
		else if([mElement identifier] == @"speed") {
			Texture2D* texture = [[Texture2D alloc] initWithString:[[NSString alloc] initWithFormat:@"%ix",[[[[UIApplication sharedApplication] delegate] timeManager] speed]] dimensions:CGSizeMake(64,32) alignment:UITextAlignmentLeft fontName:@"Helvetica-Bold" fontSize:11];
			glColor4f(0.56f, 0.831f, 0.0f, alphaValue);
			[texture drawInRect:[mElement bounds]];
			glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
			[texture release];
		}
		else if([mElement identifier] == @"icon") {
			if(hiding) {
				glColor4f(1.0f, 1.0f, 1.0f, alphaValue);
			}
			else {
				[[elements objectAtIndex:0] setBounds:CGRectMake(xValueIcon, -55, 31, 31)];
			}
			
			
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

@end