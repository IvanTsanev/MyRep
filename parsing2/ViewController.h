//
//  ViewController.h
//  parsing2
//
//  Created by Ivan Tsanev on 22/10/2012.
//  Copyright (c) 2012 Ivan Tsanev. All rights reserved.
//

@class Section;
@class SectionParsing;
@interface ViewController : UIViewController {

}

@property (nonatomic, strong) Section* section;
@property (nonatomic, strong) SectionParsing* sec;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
