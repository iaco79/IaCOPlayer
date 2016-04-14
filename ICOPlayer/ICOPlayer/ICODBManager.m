//
//  ICODBManager.m
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "VideoLink.h"
#import "ICODBManager.h"


#define kICODBPath @"icodb.sqlite"
#define kICODBModel @"ICODataModel"


@implementation ICODBManager




@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


+(ICODBManager*)  sharedInstance
{
    
    static ICODBManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[ICODBManager alloc] init];
        
    });
    return sharedManager;
    
    
}


-(id)init
{
    self = [super init];
    
    
    return self;
    
}




#pragma mark - common Core Data helper methods


- (BOOL) deleteObject :(NSManagedObject*) object
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    [managedObjectContext deleteObject:object];
    return YES;
}


-(NSArray *) executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    [context performBlockAndWait:^{
        
        NSError *error = nil;
        
        results = [context executeFetchRequest:request error:&error];
        
        
    }];
    return results;
}

-(id) executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    [request setFetchLimit:1];
    
    NSArray *results = [self executeFetchRequest:request inContext:context];
    if ([results count] == 0)
    {
        return nil;
    }
    return [results objectAtIndex:0];
}

-(NSEntityDescription*) entityForClass :(Class) entityClass
{
    
    NSEntityDescription* entity=nil;
    NSManagedObjectContext* context = self.managedObjectContext;
    
    if ([entityClass respondsToSelector:@selector(entityInManagedObjectContext:)])
    {
        entity = [entityClass performSelector:@selector(entityInManagedObjectContext:) withObject:context];
        
    }
    
    return entity;
    
}
-(id)  findFirst :(Class)entityClass
{
    NSManagedObjectContext* context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [self entityForClass:entityClass];
    
    [fetchRequest setEntity:entity];
    
    return [self executeFetchRequestAndReturnFirstObject:fetchRequest inContext: context];
    
    
}


-(NSFetchRequest *) requestAll:
(NSEntityDescription*) entity
                      inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setFetchBatchSize:(20)];
    
    
    return fetchRequest;
}




-(NSFetchRequest *) requestAllSortedBy:
(NSEntityDescription*) entity
                              SortedBy:(NSString *)sortTerm
                             ascending:(BOOL)ascending
                             inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setFetchBatchSize:(20)];
    
    NSMutableArray* sortDescriptors = [[NSMutableArray alloc] init];
    NSArray* sortKeys = [sortTerm componentsSeparatedByString:@","];
    for (NSString* sortKey in sortKeys)
    {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
        [sortDescriptors addObject:sortDescriptor];
    }
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    return fetchRequest;
}



- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}



-(NSArray *) findAll: (Class) entityClass
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription* entity = [self entityForClass:entityClass];
    
    NSFetchRequest *request = [self requestAll: entity inContext: context];
    return [self executeFetchRequest:request inContext:context];
}


-(NSArray *) findAllSortedBy: (Class) entityClass
                    sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSEntityDescription* entity = [self entityForClass:entityClass];
    
    NSFetchRequest *request = [self requestAllSortedBy: entity SortedBy: sortTerm ascending:ascending inContext: context];
    return [self executeFetchRequest:request inContext:context];
}

-(NSArray *) findAllWithPredicate: (Class) entityClass withPredicate: (NSPredicate *)searchTerm
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [self entityForClass:entityClass];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate: searchTerm];
    
    return [self executeFetchRequest:fetchRequest inContext:context];
    
}

- (id) createEntity: (NSEntityDescription*) entity inContext: (NSManagedObjectContext *)context
{
    NSString* entityname = entity.name;
    
    
    return [NSEntityDescription insertNewObjectForEntityForName: entityname inManagedObjectContext:context];
    
    
}

- (id) createObject : (Class) entityClass
{
    NSEntityDescription* entity = [self entityForClass:entityClass];
    NSManagedObjectContext *context = self.managedObjectContext;
    NSManagedObject *newEntity = [self createEntity: entity inContext: context];
    
    return newEntity;
}




#pragma mark - Core Data stack

/**
 * Returns the managed object context
 * If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}


/**
 * Returns the managed object model
 * If the model doesn't already exist, it is created from the DB model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    
    NSBundle* bundle  = [NSBundle mainBundle];
    
    
    NSURL *modelURL = [bundle URLForResource:kICODBModel withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 * Returns the persistent store coordinator 
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kICODBPath];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //   abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
