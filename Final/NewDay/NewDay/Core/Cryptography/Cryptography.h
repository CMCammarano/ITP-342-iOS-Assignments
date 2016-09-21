//
//  Cryptography.h
//  NewDay
//
//  Created by Colin Cammarano on 5/2/16.
//  Copyright © 2016 Colin Cammarano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>

@interface NSData (AES256)

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

@end