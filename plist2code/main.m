//
//  main.m
//  plist2code
//
//  Created by Matthias Bartelmeß on 12.12.11.
//  Copyright (c) 2011 fourplusone. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString * serializeObject (NSObject * object);
NSString * serializeArray (NSArray * array);
NSString * serializeDict (NSDictionary * dict);
NSString * serializeString (NSString * string);
NSString * serializeData (NSData * data);
NSString * serializeNumber (NSNumber * number);
NSString * serializeDate (NSDate * date);

NSString * serializeObject (NSObject * object){
    NSString * res = nil;
    
    if ([object isKindOfClass:[NSArray class]]) {
        res = serializeArray((NSArray *)object);
        
    }else if ([object isKindOfClass:[NSDictionary class]]) {
        res = serializeDict((NSDictionary *)object);
        
    }else if ([object isKindOfClass:[NSNumber class]]) {
        res = serializeNumber((NSNumber *)object);
        
    }else if ([object isKindOfClass:[NSString class]]) {
        res = serializeString((NSString *)object);
        
    }else if ([object isKindOfClass:[NSData class]]) {
        res = serializeData((NSData *)object);
        
    }else if ([object isKindOfClass:[NSDate class]]) {
        res = serializeDate((NSDate *)object);
        
    }
    return res;
}

NSString * serializeArray (NSArray * array)
{
    NSMutableString * res = [[NSMutableString alloc] initWithString:@"[NSArray arrayWithObjects:"];
    
    for (NSObject * object in array) {
        [res appendFormat:@"%@,", serializeObject(object)];
    }
    
    [res appendString:@"nil]"];
    return res;
}


NSString * serializeDict (NSDictionary * dict)
{
    
//    [NSDictionary dictionaryWithObjectsAndKeys:<#(id), ...#>, nil]
    NSMutableString * res = [[NSMutableString alloc] initWithString:@"[NSDictionary dictionaryWithObjectsAndKeys:"];

    
    for (NSObject * key in [dict keyEnumerator]) {
        [res appendFormat:@"%@,%@,", serializeObject(key), serializeObject([dict objectForKey:key])];
    }
    [res appendString:@"nil]"];

    return res;
}



NSString * serializeString (NSString * string)
{
    //[NSString stringWithUTF8String:(const char *)]

    NSMutableString * res = [[NSMutableString alloc] initWithString:@"[NSString stringWithUTF8String:\""];
    const char * utf = [string UTF8String];
    long len =strlen(utf);
    for (long i = 0; i < len; i++) {
        char c =  utf[i];
        [res appendFormat:@"\\x%02x", c];
        
    }
    [res appendString:@"\"]"];
    return res;
}

NSString * serializeData (NSData * data)
{
    //[NSData dataWithBytes:<#(const void *)#> length:<#(NSUInteger)#>]

    NSUInteger l = [data length];
    const char * bytes = [data bytes];
    NSMutableString * res = [[NSMutableString alloc] initWithString:@"[NSData dataWithBytes:\""];
    
    for (long i = 0; i < l; i++) {
        char c =  bytes[i];
        [res appendFormat:@"\\x%02x", c];
    }
    [res appendFormat:@"\" length:%ld]", l];
    return res;
    
}

NSString * serializeNumber (NSNumber * number)
{
    /*
     "c"	=>	"char",
     "i"	=>	"int",
     "s"	=>	"short",
     "l"	=>	"long",
     "q"	=>	"long long",
     "C"	=>	"unsigned char",
     "I"	=>	"unsigned int",
     "S"	=>	"unsigned short",
     "L"	=>	"unsigned long",
     "Q"	=>	"unsigned long long",
     "f"	=>	"float",
     "d"	=>	"double"
     */
    
    const char * objcType = [number objCType];
    NSString * res;
    if(objcType[0] == 'c'){
        res =[NSString stringWithFormat:@"[NSNumber numberWithChar:(char)%hhi", [number charValue]];
    }else if(objcType[0] == 'i'){
        res =[NSString stringWithFormat:@"[NSNumber numberWithInt:(int)%i", [number intValue]];
    }else if(objcType[0] == 's'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithShort:(short)%hi", [number shortValue]];
    }else if(objcType[0] == 'l'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithLong:(char)%ld", [number longValue]];
    }else if(objcType[0] == 'q'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithLongLong:(long long)%lld", [number longLongValue]];
    }else if(objcType[0] == 'C'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedChar:(unsigned char)%hhdu", [number unsignedCharValue]];
    }else if(objcType[0] == 'I'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedInt:(unsigned int)%iu", [number unsignedIntValue]];
    }else if(objcType[0] == 'S'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedShort:(unsigned short)%hiu", [number unsignedShortValue]];
    }else if(objcType[0] == 'L'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedLong:(unsigned long)%ldu", [number unsignedLongValue]];
    }else if(objcType[0] == 'Q'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedLongLong:(unsigned long long)%lldu", [number unsignedLongLongValue]];
    }else if(objcType[0] == 'f'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedFloat:(float)%f  ", [number floatValue]];
    }else if(objcType[0] == 'd'){
        res = [NSString stringWithFormat:@"[NSNumber numberWithUnsignedDouble:(double)%f", [number doubleValue]];
    } 

    return res;
}

NSString * serializeDate (NSDate * date)
{
    NSTimeInterval interval = [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"[NSDate dateWithTimeIntervalSince1970:%f]", interval];
}

int main (int argc, const char * argv[])
{
    int ret = 0;
    @autoreleasepool {
        
        if (argc == 2) {
            NSString * filename = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
            NSData * plistData = [NSData dataWithContentsOfFile:filename];
            
            id result  = [NSPropertyListSerialization propertyListFromData:plistData
                                                          mutabilityOption:NSPropertyListImmutable 
                                                                    format:NULL
                                                          errorDescription:NULL];
            printf("%s",[serializeObject(result) UTF8String]);
        }else{
            fprintf(stderr, "usage: plist2code filename\n");
            ret = -1;
        }

    }
    return ret;
}

