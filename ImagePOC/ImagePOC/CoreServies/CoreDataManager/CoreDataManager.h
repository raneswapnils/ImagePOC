//
//  CoreDataManager.h
//  ImagePOC
//
//  Created by Swapnil Rane on 15/07/16.
//  Copyright © 2016 swapnil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/*! Creates Singleton instanse of RSMCoreDataManager class
 
 @return (RSMCoreDataManager*) : instanse of RSMCoreDataManager class
 */
+ (CoreDataManager*)sharedInstance;

/*! This will save data to local database which is available in managed context*/
- (void)saveContext;

/*! This will return application document directory path url
 
 @return (NSURL *) : url object of document directory path
 */
- (NSURL *)applicationDocumentsDirectory;

- (BOOL)isDataAvailableForEntity:(NSString*)entityName;

@end
