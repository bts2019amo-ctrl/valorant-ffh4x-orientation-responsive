//
//  KittyMemory.cpp
//
//  Created by MJ (Ruit) on 1/1/19.
//

#include "KittyMemory.hpp"

//#ifdef __ANDROID__
//#include <map>
//#include <dlfcn.h>

//#elif __APPLE__
bool findMSHookMemory(void *dst, const void *src, size_t len);
extern "C" kern_return_t mach_vm_remap(vm_map_t, mach_vm_address_t *, mach_vm_size_t,
                                       mach_vm_offset_t, int, vm_map_t, mach_vm_address_t,
                                       boolean_t, vm_prot_t *, vm_prot_t *, vm_inherit_t);
//#endif

namespace KittyMemory {

int setAddressProtection(const void *address, size_t length, int protection)
{
    uintptr_t pageStart = KT_PAGE_START(address);
    uintptr_t pageLen = KT_PAGE_LEN2(address, length);
    int ret = mprotect(reinterpret_cast<void *>(pageStart), pageLen, protection);
    KITTY_LOGD("mprotect(%p, %zu, %d) = %d", address, length, protection, ret);
    return ret;
}



kern_return_t getPageInfo(void *page_start, vm_region_submap_short_info_64 *info_out)
{
    vm_address_t region = reinterpret_cast<vm_address_t>(page_start);
    vm_size_t region_len = 0;
    mach_msg_type_number_t info_count = VM_REGION_SUBMAP_SHORT_INFO_COUNT_64;
    unsigned int depth = 0;
    return vm_region_recurse_64(mach_task_self(), &region, &region_len,
                                &depth, (vm_region_recurse_info_t)info_out,
                                &info_count);
}

bool memRead(const void *address, void *buffer, size_t len)
{
    KITTY_LOGD("memRead(%p, %p, %zu)", address, buffer, len);
    
    if (!address) {
        KITTY_LOGE("memRead err address (%p) is null", address);
        return false;
    }
    
    if (!buffer) {
        KITTY_LOGE("memRead err buffer (%p) is null", buffer);
        return false;
    }
    
    if (!len) {
        KITTY_LOGE("memRead err invalid len");
        return false;
    }
    
    memcpy(buffer, address, len);
    return true;
}

/*
 refs to
 - https://github.com/asLody/whale/blob/master/whale/src/platform/memory.cc
 - CydiaSubstrate
 */
Memory_Status memWrite(void *address, const void *buffer, size_t len)
{
    KITTY_LOGD("memWrite(%p, %p, %zu)", address, buffer, len);
    
    if (!address) {
        KITTY_LOGE("memWrite err address (%p) is null.", address);
        return KMS_INV_ADDR;
    }
    
    if (!buffer) {
        KITTY_LOGE("memWrite err buffer (%p) is null.", buffer);
        return KMS_INV_BUF;
    }
    
    if (!len) {
        KITTY_LOGE("memWrite err invalid len.");
        return KMS_INV_LEN;
    }
    
    void *page_start = reinterpret_cast<void *>(KT_PAGE_START(address));
    void *page_offset = reinterpret_cast<void *>(KT_PAGE_OFFSET(address));
    size_t page_len = KT_PAGE_LEN2(address, len);
    
    vm_region_submap_short_info_64 page_info;
    if (getPageInfo(page_start, &page_info) != KERN_SUCCESS) {
        KITTY_LOGE("memWrite err failed to get page info of address (%p).", address);
        return KMS_ERR_GET_PAGEINFO;
    }
    
    // already has write perm
    if (page_info.protection & VM_PROT_WRITE)
    {
        memcpy(address, buffer, len);
        return KMS_SUCCESS;
    }
    
    // check for Substrate/ellekit MSHookMemory existance first
    if (findMSHookMemory(address, buffer, len))
        return KMS_SUCCESS;
    
    // create new map, copy our code to it then remap it over target map
    
    void *new_map = mmap(nullptr, page_len, _PROT_RW_, MAP_ANONYMOUS | MAP_PRIVATE, 0, 0);
    if (!new_map) {
        KITTY_LOGE("memWrite err mmap(%zu) failed.", page_len);
        return KMS_ERR_MMAP;
    }
    
    task_t self_task = mach_task_self();
    
    // copy original page content to new
    if (vm_copy(self_task, reinterpret_cast<vm_address_t>(page_start), page_len,
                reinterpret_cast<vm_address_t>(new_map)) != KERN_SUCCESS)
    {
        KITTY_LOGE("memWrite err vm_copy(%p, %zu, %p) failed.", page_start, page_len, new_map);
        munmap(new_map, page_len);
        return KMS_ERR_PROT;
    }
    
    // write patch code to new
    void *dst = reinterpret_cast<void *>(reinterpret_cast<uintptr_t>(new_map) + reinterpret_cast<uintptr_t>(page_offset));
    memcpy(dst, buffer, len);
    
    // original prot on new
    if (mprotect(new_map, page_len, (page_info.protection & (_PROT_RWX_))) == -1)
    {
        KITTY_LOGE("memWrite err failed to set new_map to original protection (new_map: %p, len: %zu, prot: %d).",
                   new_map, page_len, page_info.protection);
        munmap(new_map, page_len);
        return KMS_ERR_PROT;
    }
    
    // remap
    vm_prot_t cur_protection, max_protection;
    mach_vm_address_t mach_vm_page_start = reinterpret_cast<mach_vm_address_t>(page_start);
    if (mach_vm_remap(self_task, &mach_vm_page_start, page_len, 0, VM_FLAGS_OVERWRITE,
                      self_task, reinterpret_cast<mach_vm_address_t>(new_map),
                      TRUE, &cur_protection, &max_protection,
                      page_info.inheritance) != KERN_SUCCESS)
    {
        KITTY_LOGE("memWrite err vm_remap(page: %p, len: %zu, prot: %d) failed.",
                   page_start, page_len, page_info.protection);
        munmap(new_map, page_len);
        return KMS_ERR_REMAP;
    }
    
    munmap(new_map, page_len);
    return KMS_SUCCESS;
}

MemoryFileInfo getBaseInfo()
{
    MemoryFileInfo _info;
    
    const uint32_t imageCount = _dyld_image_count();
    
    for (uint32_t i = 0; i < imageCount; i++)
    {
        const mach_header *hdr = _dyld_get_image_header(i);
        if (!hdr || hdr->filetype != MH_EXECUTE) continue;
        
        // first executable
        _info.index = i;
#ifdef __LP64__
        _info.header = (const mach_header_64*)_dyld_get_image_header(i);
#else
        _info.header = _dyld_get_image_header(i);
#endif
        _info.name = _dyld_get_image_name(i);
        _info.address = _dyld_get_image_vmaddr_slide(i);
        
        break;
    }
    
    return _info;
}

MemoryFileInfo getMemoryFileInfo(const std::string& fileName)
{
    MemoryFileInfo _info;
    
    const uint32_t imageCount = _dyld_image_count();
    
    for (uint32_t i = 0; i < imageCount; i++)
    {
        const char *name = _dyld_get_image_name(i);
        if (!name) continue;
        
        std::string fullpath(name);
        if (!KittyUtils::String::EndsWith(fullpath, fileName))
            continue;
        
        _info.index = i;
#ifdef __LP64__
        _info.header = (const mach_header_64*)_dyld_get_image_header(i);
#else
        _info.header = _dyld_get_image_header(i);
#endif
        _info.name = _dyld_get_image_name(i);
        _info.address = _dyld_get_image_vmaddr_slide(i);
        
        break;
    }
    return _info;
}

uintptr_t getAbsoluteAddress(const char *fileName, uintptr_t address)
{
    MemoryFileInfo info;
    
    if (fileName)
        info = getMemoryFileInfo(fileName);
    else
        info = getBaseInfo();
    
    if (!info.address)
        return 0;
    
    return info.address + address;
}

}
bool findMSHookMemory(void *, const void *, size_t) { return false; }
