//
//  SectionParsing.h
//  SectionParsing
//
//  Created by Ivan Tsanev on 19/10/2012.
//  Copyright (c) 2012 Ivan Tsanev. All rights reserved.
//
@interface SectionParsing : NSObject

@property (nonatomic, strong) NSMutableArray* mutableSections;
-(id) initSectionParsing;
-(void) doParse:(NSData*) data;

@end

