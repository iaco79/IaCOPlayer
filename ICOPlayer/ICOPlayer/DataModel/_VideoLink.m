// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to VideoLink.m instead.

#import "_VideoLink.h"

const struct VideoLinkAttributes VideoLinkAttributes = {
	.videoDescription = @"videoDescription",
	.videoFavorite = @"videoFavorite",
	.videoIcon = @"videoIcon",
	.videoOrder = @"videoOrder",
	.videoUrl = @"videoUrl",
};

@implementation VideoLinkID
@end

@implementation _VideoLink

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"VideoLink" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"VideoLink";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"VideoLink" inManagedObjectContext:moc_];
}

- (VideoLinkID*)objectID {
	return (VideoLinkID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"videoFavoriteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoFavorite"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"videoOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic videoDescription;

@dynamic videoFavorite;

- (int32_t)videoFavoriteValue {
	NSNumber *result = [self videoFavorite];
	return [result intValue];
}

- (void)setVideoFavoriteValue:(int32_t)value_ {
	[self setVideoFavorite:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVideoFavoriteValue {
	NSNumber *result = [self primitiveVideoFavorite];
	return [result intValue];
}

- (void)setPrimitiveVideoFavoriteValue:(int32_t)value_ {
	[self setPrimitiveVideoFavorite:[NSNumber numberWithInt:value_]];
}

@dynamic videoIcon;

@dynamic videoOrder;

- (int32_t)videoOrderValue {
	NSNumber *result = [self videoOrder];
	return [result intValue];
}

- (void)setVideoOrderValue:(int32_t)value_ {
	[self setVideoOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveVideoOrderValue {
	NSNumber *result = [self primitiveVideoOrder];
	return [result intValue];
}

- (void)setPrimitiveVideoOrderValue:(int32_t)value_ {
	[self setPrimitiveVideoOrder:[NSNumber numberWithInt:value_]];
}

@dynamic videoUrl;

@end

