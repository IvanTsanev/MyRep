
//
//  AppDelegate.m
//  parsing2
//
//  Created by Ivan Tsanev on 19/10/2012.
//  Copyright (c) 2012 Ivan Tsanev. All rights reserved.
//

#import "AppDelegate.h"
#import "SectionParsing.h"
#import "ViewController.h"
#import "CoreData.h"
#import <CoreData/CoreData.h>
#import "SplashViewController.h"
#import "Section.h"
@class SectionParsing;
@interface AppDelegate () <UIApplicationDelegate, NSURLConnectionDelegate,NSFetchedResultsControllerDelegate>{
    NSMutableArray * sections;
@private
    NSManagedObjectContext *managedObjectContext_;
    NSFetchedResultsController *fetchedResultsController_;
}
@property (nonatomic, strong, readonly) NSURLRequest *urlRequest;
@property(  strong, nonatomic) NSConnection *connection;
@property(  strong, nonatomic) NSMutableData *data;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
@implementation AppDelegate
@synthesize managedObjectContext = managedObjectContext_;
@synthesize fetchedResultsController = fetchedResultsController_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    CoreData *managedObjectContext = [[CoreData alloc] initCoreData];
    self.managedObjectContext = managedObjectContext.managedObjectContext;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://m.apps.thesun.co.uk/feed/1_00/sections.xml"]];
    
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:YES];
    [connection start];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SplashViewController* splash = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    self.window.rootViewController = splash;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    _data = [[NSMutableData alloc] init];
}
-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{sections = [[NSMutableArray alloc]init];
    [_data appendData:data];
}


-(void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    SectionParsing *parser = [[SectionParsing alloc] initSectionParsing];
    [parser doParse:_data];
    sections = [NSMutableArray arrayWithArray:parser.mutableSections];
    
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    
    NSArray* allStories = [context executeFetchRequest:request error:NULL];
    for(Section* story in allStories)
    {
        [context deleteObject:story];
    }
    
    [self insertNewObject];
    [self setTabbar:context request:request];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Section"];
    
    [self setTabbar:context request:request];
}

-(void) setTabbar:(NSManagedObjectContext*) context request:(NSFetchRequest*) request
{
    NSError* error;
    NSArray *events = [context executeFetchRequest:request error:&error];
    
    
    UITabBarController* tabBar = [[UITabBarController alloc] init];
    NSMutableArray* viewControllers = [NSMutableArray array];
    
    for (Section *section in events)
    {
        ViewController* sectionViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
        sectionViewController.section = section;
        sectionViewController.managedObjectContext = self.managedObjectContext;
        
        UINavigationController* sectionNavigationController = [[UINavigationController alloc] initWithRootViewController:sectionViewController];
        [viewControllers addObject:sectionNavigationController];
        
    }
    tabBar.viewControllers = viewControllers;
    self.window.rootViewController = tabBar;
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSLog(@"%@", self.managedObjectContext);
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:20];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    
    
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController_;
    
}




- (void)insertNewObject {
    
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
	
	for (NSMutableDictionary *story in sections ) {
        
		NSManagedObject *storiesData = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
		
		[storiesData setValue:[story objectForKey: @"title"] forKey:@"savedTitle"];
		[storiesData setValue:[story objectForKey: @"rssPath"] forKey:@"savedRssPath"];
        
        
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            
            
		}
        
	}
    sections = nil;
    
}

@end
