//
//  ViewController.m
//  parsing2
//
//  Created by Ivan Tsanev on 22/10/2012.
//  Copyright (c) 2012 Ivan Tsanev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Story.h"
#import "ViewController.h"
#import "Section.h"
#import "ArticleParsing.h"
#import <CoreData/CoreData.h>
#import "ArticleCell.h"
#define CELL_MARGIN 10.0f
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 10.0f
#import <QuartzCore/QuartzCore.h>
@class CoreData;
@class AppDelegate;
@class ArticleParsing;
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableData *receivedData;
    NSMutableArray *filteredListItems;
    NSMutableArray * stories;
    NSString *path;
    BOOL parsing;
    ArticleParsing *articleParsing;
    IBOutlet UITableView *tableview;
    CoreData *coredata;
@private
    NSManagedObjectContext *managedObjectContext_;
    NSFetchedResultsController *fetchedResultsController_;
}

@property (nonatomic, strong) ArticleParsing *articleParsing;
@property (nonatomic, retain) NSMutableArray *filteredListItems;
@property (nonatomic, strong) NSString *rss;
@property (nonatomic, strong) NSMutableArray* sortedStories;
@property BOOL parsing;

- (void)parseXMLFileAtURL:(NSString *)URL;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation ViewController
@synthesize parsing;
@synthesize articleParsing;
@synthesize filteredListItems;

@synthesize managedObjectContext=managedObjectContext_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sortedStories = [NSMutableArray array];
    }
    return self;
    
}

-(void) setSection:(Section *)section
{
    self.title = section.savedTitle;
    [self setrss:section];
    
    _section = section;
}

-(void) setrss:(Section *)rss{
    self.rss = rss.savedRssPath;
    
}

- (void)parseXMLFileAtURL:(NSString *)URL{
    
	parsing = true;
	stories = [[NSMutableArray alloc] init];
	receivedData = [[NSMutableData alloc] init];
    
    NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10] delegate:self];
    [urlConnection start];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{stories = [[NSMutableArray alloc]init];
    [receivedData appendData:data];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ArticleParsing *parser = [[ArticleParsing alloc] initArticleParsing];
    [parser doparse:receivedData];
    
    stories = [NSMutableArray arrayWithArray:parser.stories];
    if([stories count] > 0)
    {
        [self.sortedStories removeAllObjects];
        
        NSManagedObjectContext *context = self.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:context];
        
        for(Story* currentStory in self.section.stories)
        {
            [self.section removeStoriesObject:currentStory];
        }
        
        int currentIndex = 0;
        for(NSDictionary* storyDict in stories)
        {
            Story* story = [[Story alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
            story.savedTitle = [storyDict objectForKey:@"title"];
            story.savedLink = [storyDict objectForKey:@"tol-text:story"];
            story.index = [NSNumber numberWithInt:currentIndex];
            ++currentIndex;
            
            [self.section addStoriesObject:story];
            
            [self.sortedStories addObject:story];
        }
        
        [context save:NULL];
    }
    
    parsing = false;
    
    [tableview reloadData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.sortedStories removeAllObjects];
    
    [self.sortedStories addObjectsFromArray:[self.section.stories allObjects]];
    
    [self.sortedStories sortUsingComparator:^NSComparisonResult(id first, id second) {
        Story* firstStory = (Story*)first;
        Story* secondStory = (Story*)second;
        
        int firstStoryIndex = [firstStory.index intValue];
        int secondStoryIndex = [secondStory.index intValue];
        
        if(firstStoryIndex > secondStoryIndex)
        {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    
    [tableview reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [self.filteredListItems count];
    }
	else{
        return [self.sortedStories count];
    }
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    Story* story = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        story = [self.filteredListItems objectAtIndex:indexPath.row];
    }
    else
    {
        story = (Story*) [self.sortedStories objectAtIndex:indexPath.row];
    }
    
    NSString *cellValue = [NSString stringWithFormat:@"%@ %@ ", [story savedTitle], [story savedLink] ];
    NSString *text = cellValue ;
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = MAX(size.height, 44.0f);
    
    return height + (CELL_CONTENT_MARGIN * 2);
    
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UILabel *label = nil;
    ArticleCell *cell = (ArticleCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    
    if (cell == nil) {
        cell = [[ArticleCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"Cell"];
        
        
        
        
    }
    
    
    
    Story* story = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        story = [self.filteredListItems objectAtIndex:indexPath.row];
    }
    else
    {
        story = (Story*) [self.sortedStories objectAtIndex:indexPath.row];
    }
    
    NSString *cellValue = [NSString stringWithFormat:@"%@ %@ ", [story savedTitle], [story savedLink]];
    
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [cellValue sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    if (!label)
        label = cell.label;
    
    [label setText:cellValue];
    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(size.height, 44.0f))];
    
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableview.dataSource = self;
	tableview.delegate = self;
    
    [self parseXMLFileAtURL:self.section.savedRssPath];
}

@end
