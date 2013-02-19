//
//  SectionParsing.m
//  SectionParsing
//
//  Created by Ivan Tsanev on 18/10/2012.
//  Copyright (c) 2012 Ivan Tsanev. All rights reserved.
//


#import "SectionParsing.h"
#import "Section.h"

@interface SectionParsing () <NSXMLParserDelegate, NSFetchedResultsControllerDelegate>{
    NSMutableDictionary * item;
NSString * currentElement;
    NSMutableString * currentTitle, * currentRss;

}

@property (nonatomic) int currentLevel;
@property (nonatomic, retain) Section *section;
@property (nonatomic, strong, readonly) NSArray *Sections;

@property (nonatomic, strong) NSMutableString* currentElementValue;

@end

@implementation SectionParsing

- (id) initSectionParsing {
    self = [super init];
    if(self)
    {
        self.currentLevel = -1;
        self.mutableSections = [[NSMutableArray alloc] init];
    }

    return self;
}

-(NSArray*) Sections
{
    return [self.mutableSections copy];
}




- (void) doParse:(NSData *)data {
    NSXMLParser *nsXmlParser = [[NSXMLParser alloc] initWithData:data];
    
    SectionParsing *parser = [[SectionParsing alloc] initSectionParsing];
    
    [nsXmlParser setDelegate:parser];
    
    BOOL success = [nsXmlParser parse];
    
    if (success) {
        
        self.mutableSections = parser.mutableSections;
        
    } else {
        NSLog(@"Error parsing document!");
    }
    
}










- (void)parser:(NSXMLParser *)Parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary *)attributeDict {
		currentElement = [elementName copy];
    if ([elementName isEqualToString:@"section"]) {
        NSLog(@"section element found – create a new instance of section class...");
        ++self.currentLevel;
        
        if(self.currentLevel == 0)
        {

            item = [[NSMutableDictionary alloc] init];
            currentTitle = [[NSMutableString alloc] init];
            currentRss = [[NSMutableString alloc] init];
        }
        
    }
}


- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string{
    if (!self.currentElementValue) {
        self.currentElementValue = [[NSMutableString alloc] initWithString:string];
    } else {
        [self.currentElementValue appendString:string];
    }
	if ([currentElement isEqualToString:@"title"]) {
		[ currentTitle appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
	} else if ([currentElement isEqualToString:@"rssPath"]) {
		[currentRss appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	}
    NSLog(@"Processing value for : %@", string);
}


- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"sections"]) {
        
        return;
    }
    
    if ([elementName isEqualToString:@"section"]) {
        
        if(self.currentLevel == 0)
        {

        
        }
        
        --self.currentLevel;
        
        
    } else if ([elementName isEqualToString:@"title"]) {
        if(self.currentLevel == 0)
        {

            [item setObject:currentTitle forKey:@"title" ];


        }
        
    }else if ([elementName isEqualToString:@"rssPath"]) {
        if(self.currentLevel == 0)
        {
  
            [item setObject:currentRss forKey:@"rssPath"];
            [self.mutableSections addObject:[item copy]];



        }

    }
    
    self.currentElementValue = nil;

}


- (void)parserDidEndDocument:(NSXMLParser *)
parser {
    
    
    NSLog(@"all done!");
	NSLog(@"mutableSections array has %d items", [_mutableSections count]);
    

}
-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"ERROR: %@", parseError);
}



@end