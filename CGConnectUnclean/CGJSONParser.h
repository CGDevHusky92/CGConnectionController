

#import <Foundation/Foundation.h>

@interface CGJSONParser : NSObject

typedef enum {
    CGJSONParserErrorIncorrectType = 1 //this is returned when the expected type does not match in the JSON Object
} CGJSONParserError;

- (instancetype)initWithClass:(Class)classObj;
- (void)addArrayClassMap:(NSString *)propertyName class:(Class)classID;
- (id)process:(id)JSONObject error:(NSError**)error;
- (NSArray *)propertyKeys;
+ (instancetype)JSONParserWithClass:(Class)classType;
+ (NSString *)convertToJsonName:(NSString *)propName;
+ (void)setLoose:(BOOL)loose;
+ (void)setAutoConvertBOOLs:(BOOL)box;

@end

@interface NSObject (CGJSONParser)

+ (CGJSONParser *)jsonMapper;
+ (id)objectWithParser:(id)jsonObj;
+ (id)objectWithParser:(id)jsonObj error:(NSError **)error;

- (void)updateObjectWithJSONObject:(id)jsonObj;
- (void)updateObjectWithJSONObject:(id)jsonObj error:(NSError **)error;

@end
