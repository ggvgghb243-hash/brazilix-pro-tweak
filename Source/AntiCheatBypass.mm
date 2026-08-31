#import <Foundation/Foundation.h>
#if defined(__has_include)
  #if __has_include(<substrate.h>)
    #include <substrate.h>
  #endif
#endif
#import <sys/stat.h>
#import <sys/sysctl.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

#ifndef MSHookFunction
extern "C" void MSHookFunction(void *symbol, void *replace, void **result) __attribute__((weak_import));
#endif

// 1. Hooking stat/lstat to hide tweak and common jailbreak files
static int (*orig_stat)(const char *path, struct stat *buf);
static int my_stat(const char *path, struct stat *buf) {
    if (path == NULL) return orig_stat ? orig_stat(path, buf) : 0;
    NSString *filePath = [NSString stringWithUTF8String:path];
    if ([filePath containsString:@"Brazilix"] || 
        [filePath containsString:@"Fluorite"] || 
        [filePath containsString:@"Cydia"] || 
        [filePath containsString:@"Substrate"] || 
        [filePath containsString:@"Sileo"] || 
        [filePath containsString:@"apt"] || 
        [filePath containsString:@"Tss"]) {
        return -1; // File not found
    }
    return orig_stat ? orig_stat(path, buf) : 0;
}

static int (*orig_lstat)(const char *path, struct stat *buf);
static int my_lstat(const char *path, struct stat *buf) {
    if (path == NULL) return orig_lstat ? orig_lstat(path, buf) : 0;
    NSString *filePath = [NSString stringWithUTF8String:path];
    if ([filePath containsString:@"Brazilix"] || 
        [filePath containsString:@"Fluorite"] || 
        [filePath containsString:@"Cydia"] || 
        [filePath containsString:@"Substrate"] || 
        [filePath containsString:@"Sileo"] || 
        [filePath containsString:@"apt"] || 
        [filePath containsString:@"Tss"]) {
        return -1;
    }
    return orig_lstat ? orig_lstat(path, buf) : 0;
}

// 2. Hooking sysctl to prevent debugger/ptrace detection
static int (*orig_sysctl)(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
static int my_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    int ret = orig_sysctl ? orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen) : 0;
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && oldp) {
        struct kinfo_proc *info = (struct kinfo_proc *)oldp;
        if (info && (info->kp_proc.p_flag & P_TRACED)) {
            info->kp_proc.p_flag ^= P_TRACED; // Remove traced flag
        }
    }
    return ret;
}

// 3. Hooking _dyld_get_image_name to hide our dylib from image list
static const char *(*orig_dyld_get_image_name)(uint32_t image_index);
static const char *my_dyld_get_image_name(uint32_t image_index) {
    const char *name = orig_dyld_get_image_name ? orig_dyld_get_image_name(image_index) : NULL;
    if (name) {
        NSString *imageName = [NSString stringWithUTF8String:name];
        if ([imageName containsString:@"Brazilix"] || [imageName containsString:@"Fluorite"] || [imageName containsString:@"MobileSubstrate"]) {
            return "/usr/lib/libSystem.B.dylib"; // Fake standard lib
        }
    }
    return name;
}

extern "C" void initAntiCheatBypass() {
    if (&MSHookFunction != NULL) {
        MSHookFunction((void *)stat, (void *)my_stat, (void **)&orig_stat);
        MSHookFunction((void *)lstat, (void *)my_lstat, (void **)&orig_lstat);
        MSHookFunction((void *)sysctl, (void *)my_sysctl, (void **)&orig_sysctl);
        MSHookFunction((void *)_dyld_get_image_name, (void *)my_dyld_get_image_name, (void **)&orig_dyld_get_image_name);
    }
}
