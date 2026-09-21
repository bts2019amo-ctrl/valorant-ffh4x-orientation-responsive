#ifndef MEMORY_H
#define MEMORY_H

#include <dirent.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <string>
#include "UtfTool.hpp"
using namespace std;

typedef uintptr_t kaddr;

// Function declarations
bool vm_readv(void *address, void *buffer, size_t length);
bool vm_writev(void *address, const void *buffer, size_t length);
bool IsValidAddress(kaddr address);
kaddr get_module_base(std::string name = "");

// Template function for reading any data type
template<typename T>
T Read(void* address) {
    T data{};
    if (vm_readv(address, &data, sizeof(T))) {
        return data;
    }
    return data; // Return default object if read fails
}

template<typename T>
T Read(kaddr address) {
    return Read<T>((void*)address);
}

bool Read_data(kaddr address, size_t length, char* buffer);

// Template function for writing any data type
template<typename T>
bool Write(void* address, const T& data) {
    return vm_writev(address, &data, sizeof(T));
}

template<typename T>
bool Write(kaddr address, const T& data) {
    return Write<T>((void*)address, data);
}

bool Write_data(kaddr address, size_t length, const char* buffer);


// Utility functions
static uintptr_t GetFieldAddress(std::string address) {
    return (uintptr_t)strtoul(address.c_str(), nullptr, 16);
}

static uintptr_t GetRealOffset(std::string address) {
    return (get_module_base("CodeV") + GetFieldAddress(address));
}







#endif // MEMORY_H
