//
//  Copyright (c) 2012, Infinite Droplets V.O.F.
//  All rights reserved.
//  
//  Starry was released under the BSD Licence
//

#import "SRObjectManager.h"
#import "XMLParser.h"

#import "SRSQLiteDelegate.h"
#import "SterrenAppDelegate.h"


@implementation SRObjectManager

@synthesize constellations,constellationNum,constellationPoints,
			planets,planetNum,planetPoints,
			stars,starNum,starPoints,starSizeNum,
			sun, moon,
			messier,messierNum,messierPoints;

-(id)init {
    
    if(self = [super init]) {
		stars = [[NSMutableArray alloc] init];
		constellations = [[NSMutableArray alloc] init];
		messier = [[NSMutableArray alloc] init];
		planets = [[NSMutableArray alloc] init];
		
    }
    return self;
}

-(void)parseData {
	
	SRSQLiteDelegate * sqlLoader = [[SRSQLiteDelegate alloc] init];
	[sqlLoader checkAndCreateDatabase];
	[sqlLoader readStarsFromDatabase];
	
	NSData * dataConstellations = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"constellations" ofType: @"xml"]];
	NSXMLParser *xmlParserConstellations = [[NSXMLParser alloc] initWithData:dataConstellations];
	XMLParser *parserConstellations = [[XMLParser alloc] initXMLParser];
	[xmlParserConstellations setDelegate:parserConstellations];
	BOOL success = [xmlParserConstellations parse];
	[xmlParserConstellations release];
	[parserConstellations release];
	
	
	if(success) {
		//NSLog(@"Constellations-parse completed");
	}
	else {
		NSLog(@"Er is een fout opgetreden bij het inladen van de sterrenbeelden"); 
	}
	
	NSData * dataMessier = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"messier" ofType: @"xml"]];
	NSXMLParser *xmlParserMessier = [[NSXMLParser alloc] initWithData:dataMessier];
	XMLParser *parserMessier = [[XMLParser alloc] initXMLParser];
	[xmlParserMessier setDelegate:parserMessier];
	success = [xmlParserMessier parse];
	[xmlParserMessier release];
	[parserMessier release];
	
	if(success) {
		//NSLog(@"Messier-parse completed");
	}
	else {
		NSLog(@"Er is een fout opgetreden bij het inladen van de Messier objecten"); 
	} 
	
}

-(void)buildPlanetData {
	if ([planets count] < 1) {
		moon = [[SRMoon alloc] init];
		sun = [[SRSun alloc] init];
		
		SRPlanetaryObject *earth = [[SRPlanetaryObject alloc] initWitha:1.00000	
											   e:0.01671	
											   i:0.000
											   w:288.064
											   o:174.873
											  Mo:357.529
											name:@"Earth"];
		[planets addObject:earth];
		[earth release];
	
		SRPlanetaryObject *jupiter = [[SRPlanetaryObject alloc] initWitha:5.20260		
												 e:0.04849		
												 i:1.303
												 w:273.867
												 o:100.464
												Mo:20.020
											  name:@"Jupiter"];
		[planets addObject:jupiter];
		[jupiter release];
		
		SRPlanetaryObject *mercury = [[SRPlanetaryObject alloc] initWitha:0.38710		
												 e:0.20563		
												 i:7.005
												 w:29.125
												 o:48.331
												Mo:174.795
											  name:@"Mercury"];
		[planets addObject:mercury];
		[mercury release];
	
		SRPlanetaryObject *venus = [[SRPlanetaryObject alloc] initWitha:0.72333		
											   e:0.00677		
											   i:3.395
											   w:54.884
											   o:76.680
											  Mo:50.416
											name:@"Venus"];
		[planets addObject:venus];
		[venus release];
	
		SRPlanetaryObject *mars = [[SRPlanetaryObject alloc] initWitha:1.52368		
											  e:0.09340		
											  i:1.850
											  w:286.502
											  o:49.558
											 Mo:19.373
										   name:@"Mars"];
		[planets addObject:mars];
		[mars release];
	
		SRPlanetaryObject *saturn = [[SRPlanetaryObject alloc] initWitha:9.55491		
												e:0.05551		
												i:2.489
												w:339.391
												o:113.666
											   Mo:317.021
											 name:@"Saturn"];
		[planets addObject:saturn];
		[saturn release];
	
		SRPlanetaryObject *uranus = [[SRPlanetaryObject alloc] initWitha:19.21845		
												e:0.04630		
												i:0.773
												w:98.999
												o:74.006
											   Mo:141.050
											 name:@"Uranus"];
		[planets addObject:uranus];
		[uranus release];
	
		SRPlanetaryObject *neptune = [[SRPlanetaryObject alloc] initWitha:30.11039		
												 e:0.00899		
												 i:1.770
												 w:276.340
												 o:131.784
												Mo:256.225
											  name:@"Neptune"];
	
		[planets addObject:neptune];
		[neptune release];
		
		SRPlanetaryObject *pluto = [[SRPlanetaryObject alloc] initWitha:39.543		
																		e:0.2490		
																		i:17.140
																		w:113.768
																		o:110.307
																	   Mo:14.882
																	 name:@"Pluto"];
		
		[planets addObject:pluto];
		[pluto release];
	}
	
	[sun recalculatePosition:[[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] timeManager] simulatedDate]];
	[moon recalculatePosition:[[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] timeManager] simulatedDate]];
	
	SRPlanetaryObject *planet;
	
	for (planet in planets) {
		[planet recalculatePosition:[[(SterrenAppDelegate*)[[UIApplication sharedApplication] delegate] timeManager] simulatedDate]];
		if (planet.a != 1) {  //slordig hooorr
			[planet setViewOrigin:[[planets objectAtIndex:0] positionHelio]];
		}
	}
	
	const GLfloat planetPointsTmp[] = {
		// de Zon
		[sun position].x, [sun position].y, [sun position].z,																	1.0, 1.0, 0.8, 0.9, 90.0,
		//de maan
		[moon position].x, [moon position].y, [moon position].z,																1.0, 1.0, 1.0, 1.0, 32.0,		
		// Jupiter
		[[planets objectAtIndex:1] position].x, [[planets objectAtIndex:1] position].y, [[planets objectAtIndex:1] position].z,	1.0, 0.9, 0.5, 1.0, 10.0,
		// Mercurius
		[[planets objectAtIndex:2] position].x, [[planets objectAtIndex:2] position].y, [[planets objectAtIndex:2] position].z,	0.9, 0.9, 0.9, 1.0, 10.0,
		// Venus
		[[planets objectAtIndex:3] position].x, [[planets objectAtIndex:3] position].y, [[planets objectAtIndex:3] position].z,	0.8, 0.8, 0.8, 1.0, 10.0,
		// Mars
		[[planets objectAtIndex:4] position].x, [[planets objectAtIndex:4] position].y, [[planets objectAtIndex:4] position].z,	1.0, 0.8, 0.8, 1.0, 10.0,
		// Saturnus
		[[planets objectAtIndex:5] position].x, [[planets objectAtIndex:5] position].y, [[planets objectAtIndex:5] position].z,	0.9, 0.8, 0.6, 1.0, 10.0,
		// Uranus
		[[planets objectAtIndex:6] position].x, [[planets objectAtIndex:6] position].y, [[planets objectAtIndex:6] position].z,	0.9, 0.9, 1.0, 1.0, 5.0,
		// Neptunus
		[[planets objectAtIndex:7] position].x, [[planets objectAtIndex:7] position].y, [[planets objectAtIndex:7] position].z,	0.8, 0.8, 1.0, 1.0, 5.0,
		//Pluto
		[[planets objectAtIndex:8] position].x, [[planets objectAtIndex:8] position].y, [[planets objectAtIndex:8] position].z,	0.9, 0.7, 0.7, 1.0, 4.0,
		// Aaarde voor planetView
		0.0, 0.0, 0.0,	0.9, 0.9, 1.0, 1.0, 10.0

	};
	
	planetNum = 11;
	
	if (planetPoints) {
		[planetPoints release];
	}
	planetPoints = [[NSMutableArray alloc] init];
	
	for (int i=0; i < planetNum*8; i++) {
		[planetPoints addObject:[NSNumber numberWithFloat:planetPointsTmp[i]]];
		//NSLog(@"%i", i);
	}
}

-(void)buildStarData {

}

-(void)buildMessierData {
	messierNum = 0;
	GLfloat messierPointsTmp[5000];
	SRMessier * aMessier;
	
	for(aMessier in messier) {
		messierPointsTmp[(messierNum * 3)] = aMessier.position.x;
		messierPointsTmp[(messierNum * 3)+1] = aMessier.position.y;
		messierPointsTmp[(messierNum * 3)+2] = aMessier.position.z;
		
		++messierNum;
	}
	
	if (constellationPoints) {
		[constellationPoints release];
	}
	messierPoints = [[NSMutableArray alloc] init];
	
	for (int i=0; i <= (messierNum * 3); i++) {
		[messierPoints addObject:[NSNumber numberWithFloat:messierPointsTmp[i]]];
	}
}

@end
