//
//  CoreDataAppDelegate.h
//  CoreData
//
//

#import <CoreData/CoreData.h>

@interface CoreData : NSObject{
    
    
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}


@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;
- (CoreData *) initCoreData;
- (NSManagedObjectContext *) managedObjectContext;

@end

