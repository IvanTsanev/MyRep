//
//  ArticleParsing.m
//  parsing2
//
//  Created by Ivan Tsanev on 30/01/2013.
//  Copyright (c) 2013 Ivan Tsanev. All rights reserved.
//

#import "ArticleParsing.h"

@class ViewController;


@interface ArticleParsing ()<NSXMLParserDelegate> {
    NSMutableString *nodecontent;
    NSMutableArray __weak *pickerArray;
    NSMutableArray * stories;
    NSMutableString * currentTitle,* currentLink;

    ViewController *viewController;
	NSMutableDictionary * item;
	NSString * currentElement;
    UIAlertView* message;
@private
    NSManagedObjectContext *managedObjectContext_;
}
@property (nonatomic, strong) ViewController *viewController;
@property (nonatomic, weak) NSMutableArray *pickerArray;
@property (nonatomic, strong) NSMutableString *nodecontent;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end

@implementation ArticleParsing

@synthesize pickerArray;



@synthesize stories;
@synthesize nodecontent;
@synthesize viewController;
@synthesize managedObjectContext=managedObjectContext_;
- (ArticleParsing *) initArticleParsing {

    if((self = [super init]))
    {
        stories= [[NSMutableArray alloc] init];

    }
    
    return self;
}




- (void) doparse:(NSData *)receivedData {
    
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:receivedData];
    
    ArticleParsing *parser = [[ArticleParsing alloc] initArticleParsing];
    
    [nsXmlParser setDelegate:parser];
    
    BOOL success = [nsXmlParser parse];
    
    if (success) {

        pickerArray = [NSMutableArray arrayWithArray:parser.stories];
        
        self.stories = parser.stories;
        
    } else {
        NSLog(@"Error parsing document!");
    }
    
    
}











- (void)parser:(NSXMLParser *)Parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict{

	currentElement = [elementName copy];
	if ([elementName isEqualToString:@"item"]) {

		item = [[NSMutableDictionary alloc] init];
		currentTitle = [[NSMutableString alloc] init];
		currentLink = [[NSMutableString alloc] init];
	}
    
}

- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName{

	if ([elementName isEqualToString:@"item"]) {

		[item setObject:currentTitle forKey:@"title"];
		[item setObject:currentLink forKey:@"tol-text:story"];

		[stories addObject:[item copy]];
		NSLog(@"adding story: %@", currentTitle);

	}
	
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
	
    
	if ([currentElement isEqualToString:@"title"]) {
		[currentTitle appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	} else if ([currentElement isEqualToString:@"tol-text:story"]) {
		[currentLink appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}  
}




- (void)parserDidEndDocument:(NSXMLParser *)
parser {
   

    NSLog(@"all done!");
	NSLog(@"stories array has %d items", [stories count]);

    self.stories = stories;

}


















@end
