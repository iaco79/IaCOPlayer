// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoLink.h instead.

#import <CoreData/CoreData.h>

extern const struct VideoLinkAttributes {
	__unsafe_unretained NSString *videoDescription;
	__unsafe_unretained NSString *videoFavorite;
	__unsafe_unretained NSString *videoIcon;
	__unsafe_unretained NSString *videoOrder;
	__unsafe_unretained NSString *videoUrl;
} VideoLinkAttributes;

@interface VideoLinkID : NSManagedObjectID {}
@end

@interface _VideoLink : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) VideoLinkID* objectID;

@property (nonatomic, strong) NSString* videoDescription;

//- (BOOL)validateVideoDescription:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* videoFavorite;

@property (atomic) int32_t videoFavoriteValue;
- (int32_t)videoFavoriteValue;
- (void)setVideoFavoriteValue:(int32_t)value_;

//- (BOOL)validateVideoFavorite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* videoIcon;

//- (BOOL)validateVideoIcon:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* videoOrder;

@property (atomic) int32_t videoOrderValue;
- (int32_t)videoOrderValue;
- (void)setVideoOrderValue:(int32_t)value_;

//- (BOOL)validateVideoOrder:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* videoUrl;

//- (BOOL)validateVideoUrl:(id*)value_ error:(NSError**)error_;

@end

@interface _VideoLink (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveVideoDescription;
- (void)setPrimitiveVideoDescription:(NSString*)value;

- (NSNumber*)primitiveVideoFavorite;
- (void)setPrimitiveVideoFavorite:(NSNumber*)value;

- (int32_t)primitiveVideoFavoriteValue;
- (void)setPrimitiveVideoFavoriteValue:(int32_t)value_;

- (NSString*)primitiveVideoIcon;
- (void)setPrimitiveVideoIcon:(NSString*)value;

- (NSNumber*)primitiveVideoOrder;
- (void)setPrimitiveVideoOrder:(NSNumber*)value;

- (int32_t)primitiveVideoOrderValue;
- (void)setPrimitiveVideoOrderValue:(int32_t)value_;

- (NSString*)primitiveVideoUrl;
- (void)setPrimitiveVideoUrl:(NSString*)value;

@end
