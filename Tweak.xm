#import <Foundation/Foundation.h>

void LoginOnlyStart(void);

%ctor {
    @autoreleasepool {
        LoginOnlyStart();
    }
}
