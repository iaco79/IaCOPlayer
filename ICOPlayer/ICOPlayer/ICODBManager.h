//
//  ICODBManager.h
//  ICOPlayer
//
//  Created by Othon Cruz on 4/11/16.
//  Copyright © 2016 Othon Cruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ICODBManager : NSObject


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(ICODBManager*)  sharedInstance;


/**
 * create instance of the managed object class
 */
- (id)   createObject : (Class) entityClass;

/**
 * delete instance of the managed object
 */

- (BOOL) deleteObject :(NSManagedObject*) object;

/**
 *  find first occurence of the managed object class
 */
- (id)  findFirst :(Class)entityClass;

/**
 * find all occureences of the the managed object class
 */
-(NSArray *) findAll: (Class) entityClass;


-(NSArray *) findAllSortedBy: (Class) entityClass
                    sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending;


-(NSArray *) findAllWithPredicate: (Class) entityClass withPredicate: (NSPredicate *)searchTerm;

/**
 * Save the current context
 */
- (void)saveContext;





@end
