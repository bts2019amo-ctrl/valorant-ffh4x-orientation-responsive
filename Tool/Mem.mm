#include "Tool/Mem.h"

bool vm_readv(void *address, void *buffer, size_t length) {
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)address, length, (vm_address_t)buffer, &size);
    if (error != KERN_SUCCESS || size != length)
        return false;
    return true;
}

bool vm_writev(void *address, const void *buffer, size_t length) {
    kern_return_t error = vm_write(mach_task_self(), (vm_address_t)address, (vm_address_t)buffer, (mach_msg_type_number_t)length);
    return (error == KERN_SUCCESS);
}

bool Write_data(kaddr address, size_t length, const char* buffer) {
    return vm_writev((void*)address, buffer, length);
}

kaddr get_module_base(std::string name) {
    if (name.empty())
        return (uintptr_t)_dyld_get_image_vmaddr_slide(0);
    
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        std::string path = (const char *)_dyld_get_image_name(i);
        if (path.find(name) != path.npos) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}


bool IsValidAddress(kaddr address) {
    return address != 0;
}


