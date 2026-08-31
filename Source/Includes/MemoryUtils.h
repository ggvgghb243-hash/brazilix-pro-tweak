#pragma once
#if defined(__has_include)
  #if __has_include(<substrate.h>)
    #include <substrate.h>
  #endif
#endif
#include <mach-o/dyld.h>
#include <Foundation/Foundation.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <mach/mach_traps.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>
#include <string>

// Safe MSHookFunction fallback
#ifndef MSHookFunction
extern "C" void MSHookFunction(void *symbol, void *replace, void **result) __attribute__((weak_import));
#endif

// thanks to shmoo for the usefull stuff under this comment.
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define HOOK(offset, ptr, orig) if (&MSHookFunction != NULL) { MSHookFunction((void *)getRealOffset(offset), (void *)ptr, (void **)&orig); }
#define HOOK_NO_ORIG(offset, ptr) if (&MSHookFunction != NULL) { MSHookFunction((void *)getRealOffset(offset), (void *)ptr, NULL); }

// Note to not prepend an underscore to the symbol. See Notes on the Apple manpage (https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man3/dlsym.3.html)
#define HOOKSYM(sym, ptr, org) if (&MSHookFunction != NULL) { MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, (void **)&org); }
#define HOOKSYM_NO_ORIG(sym, ptr)  if (&MSHookFunction != NULL) { MSHookFunction((void*)dlsym((void *)RTLD_DEFAULT, sym), (void *)ptr, NULL); }
#define getSym(symName) dlsym((void *)RTLD_DEFAULT, symName)

// Convert hex color to UIColor, usage: For the color #BD0000 you'd use: UIColorFromHex(0xBD0000)
#define UIColorFromHex(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1.0]

inline bool getType(unsigned int data) {
    int a = data & 0xffff8000;
    int b = a + 0x00008000;
    int c = b & 0xffff7fff;
    return c;
}

struct MemoryFileInfo {
    uint32_t index;
    const struct mach_header *header;
    const char *name;
    long long address;
};

inline MemoryFileInfo getBaseInfo() {
    MemoryFileInfo _info = {0, NULL, NULL, 0};
    std::string applicationsPath = "/private/var/containers/Bundle/Application";
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        std::string fullpath(name);
        if (strncmp(fullpath.c_str(), applicationsPath.c_str(), applicationsPath.size()) == 0)
        {
            _info.index = i;
            _info.header = _dyld_get_image_header(i);
            _info.name = _dyld_get_image_name(i);
            _info.address = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return _info;
}

inline MemoryFileInfo getMemoryFileInfo(const std::string& fileName) {
    MemoryFileInfo _info = {0, NULL, NULL, 0};
    const uint32_t imageCount = _dyld_image_count();
    for (uint32_t i = 0; i < imageCount; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name)
            continue;
        std::string fullpath(name);
        if (fullpath.length() < fileName.length() || fullpath.compare(fullpath.length() - fileName.length(), fileName.length(), fileName) != 0)
            continue;
        _info.index = i;
        _info.header = _dyld_get_image_header(i);
        _info.name = _dyld_get_image_name(i);
        _info.address = _dyld_get_image_vmaddr_slide(i);
        break;
    }
    return _info;
}

inline uintptr_t getAbsoluteAddress(const char *fileName, uintptr_t address) {
    MemoryFileInfo info;
    if (fileName)
        info = getMemoryFileInfo(fileName);
    else
        info = getBaseInfo();
    if (info.address == 0)
        return 0;
    return info.address + address;
}

inline uint64_t getRealOffset(uint64_t offset){
    return getAbsoluteAddress("UnityFramework", offset);
}

inline uint64_t getRealOffsetNULL(uint64_t offset){
    return getAbsoluteAddress(NULL, offset);
}

inline bool vm_unity(long long offset, unsigned int data) {
    const char *fileName = "UnityFramework";
    uintptr_t address = getAbsoluteAddress(fileName, offset);
    if (address == 0)
        return false;

    kern_return_t err;
    mach_port_t port = mach_task_self();

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) {
        return false;
    }

    if (getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }

    if (err != KERN_SUCCESS) {
        return false;
    }

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        return false;
    }

    return true;
}

inline bool vm(long long offset, unsigned int data) {
    const char *fileName = NULL;
    uintptr_t address = getAbsoluteAddress(fileName, offset);
    if (address == 0)
        return false;

    kern_return_t err;
    mach_port_t port = mach_task_self();

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) {
        return false;
    }

    if (getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }

    if (err != KERN_SUCCESS) {
        return false;
    }

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        return false;
    }

    return true;
}

inline bool vm_anogs(long long offset, unsigned int data) {
    const char *fileName = "anogs";
    uintptr_t address = getAbsoluteAddress(fileName, offset);
    if (address == 0)
        return false;

    kern_return_t err;
    mach_port_t port = mach_task_self();

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (err != KERN_SUCCESS) {
        return false;
    }

    if (getType(data)) {
        data = CFSwapInt32(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    } else {
        data = (unsigned short)data;
        data = CFSwapInt16(data);
        err = vm_write(port, (mach_vm_address_t)address, (vm_offset_t)&data, sizeof(data));
    }

    if (err != KERN_SUCCESS) {
        return false;
    }

    err = vm_protect(port, (mach_vm_address_t)address, sizeof(data), false, VM_PROT_READ | VM_PROT_EXECUTE);
    if (err != KERN_SUCCESS) {
        return false;
    }

    return true;
}
