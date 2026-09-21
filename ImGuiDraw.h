// Created by chunmod on 2025/05/12.
// Telegram: @chunmodvn
// Source: SharkIOS Deltaforce
// Description: ImGui drawing interface header file

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "Tool/Mem.h"
#include "Tool/office.hpp"
extern void ReaMemData();

extern void MyMenu();
extern bool IsProxyAuthenticated();

NS_ASSUME_NONNULL_BEGIN

// Kiểm tra xem chuỗi str có chứa chuỗi con substr không
static bool isContain(std::string str, const char* check) {
    size_t found = str.find(check);
    return (found != std::string::npos);
}

template<typename ... Args>
static std::string string_format(const std::string& format, Args ... args) {
    size_t size = 1 + snprintf(nullptr, 0, format.c_str(), args ...); // Tính độ dài chuỗi sau khi định dạng
    char bytes[size]; // Lưu trữ chuỗi đã định dạng
    snprintf(bytes, size, format.c_str(), args ...); // Định dạng chuỗi và lưu vào bytes
    return std::string(bytes); // Chuyển bytes thành string và trả về
}

// Đọc thông tin ký tự
static void getUTF8(UTF8 * buf, unsigned long namepy) {
    UTF16 buf16[16] = { 0 };
    vm_readv((void *)namepy, buf16, 28);
    UTF16 *pTempUTF16 = buf16;
    UTF8 *pTempUTF8 = buf;
    UTF8 *pUTF8End = pTempUTF8 + 32;
    while (pTempUTF16 < pTempUTF16 + 28) {
        if (*pTempUTF16 <= 0x007F && pTempUTF8 + 1 < pUTF8End) {
            *pTempUTF8++ = (UTF8) *pTempUTF16;
        } else if (*pTempUTF16 >= 0x0080 && *pTempUTF16 <= 0x07FF && pTempUTF8 + 2 < pUTF8End) {
            *pTempUTF8++ = (*pTempUTF16 >> 6) | 0xC0;
            *pTempUTF8++ = (*pTempUTF16 & 0x3F) | 0x80;
        } else if (*pTempUTF16 >= 0x0800 && *pTempUTF16 <= 0xFFFF && pTempUTF8 + 3 < pUTF8End) {
            *pTempUTF8++ = (*pTempUTF16 >> 12) | 0xE0;
            *pTempUTF8++ = ((*pTempUTF16 >> 6) & 0x3F) | 0x80;
            *pTempUTF8++ = (*pTempUTF16 & 0x3F) | 0x80;
        } else {
            break;
        }
        pTempUTF16++;
    }
}

struct Vector2 {
    float X;
    float Y;

    Vector2() {
        this->X = 0;
        this->Y = 0;
    }
    Vector2(float x, float y) {
        this->X = x;
        this->Y = y;
    }

    static Vector2 Zero() {
        return Vector2(0.0f, 0.0f);
    }

    static float Distance(Vector2 a, Vector2 b) {
        Vector2 vector = Vector2(a.X - b.X, a.Y - b.Y);
        return sqrt((vector.X * vector.X) + (vector.Y * vector.Y));
    }

    bool operator!=(const Vector2 &src) const {
        return (src.X != X) || (src.Y != Y);
    }
    Vector2 operator+(const Vector2 &v) const {
        return Vector2(X + v.X, Y + v.Y);
    }
    Vector2 operator-(const Vector2 &v) const {
        return Vector2(X - v.X, Y - v.Y);
    }
    Vector2 operator/(const float A) {
        return Vector2(this->X / A, this->Y / A);
    }
    Vector2 &operator+=(const Vector2 &v) {
        X += v.X;
        Y += v.Y;
        return *this;
    }
    Vector2 &operator-=(const Vector2 &v) {
        X -= v.X;
        Y -= v.Y;
        return *this;
    }
    float Size() {
        return sqrt((this->X * this->X) + (this->Y * this->Y));
    }
};

struct Vector3 {
    float X;
    float Y;
    float Z;

    Vector3() {
        this->X = 0;
        this->Y = 0;
        this->Z = 0;
    }

    Vector3(float x, float y, float z) {
        this->X = x;
        this->Y = y;
        this->Z = z;
    }

    float Size() const {
        return sqrt(X * X + Y * Y + Z * Z);
    }

    Vector3 Normalize() const {
        float length = Size();
        if (length != 0.0f) {
            return Vector3(X / length, Y / length, Z / length);
        } else {
            return Vector3(0.0f, 0.0f, 0.0f);
        }
    }

    Vector3 operator+(const Vector3 &v) const {
        return Vector3(X + v.X, Y + v.Y, Z + v.Z);
    }

    Vector3 operator-(const Vector3 &v) const {
        return Vector3(X - v.X, Y - v.Y, Z - v.Z);
    }

    bool operator==(const Vector3 &v) const {
        return X == v.X && Y == v.Y && Z == v.Z;
    }

    bool operator!=(const Vector3 &v) const {
        return !(*this == v);
    }

    Vector3 operator-=(const Vector3 &A) {
        this->X -= A.X;
        this->Y -= A.Y;
        this->Z -= A.Z;
        return *this;
    }

    Vector3 operator-=(const float A) {
        this->X -= A;
        this->Y -= A;
        this->Z -= A;
        return *this;
    }

    Vector3 operator/(const float A) const {
        return Vector3(this->X / A, this->Y / A, this->Z / A);
    }

    Vector3 operator*(float a) const {
        return Vector3(X * a, Y * a, Z * a);
    }

    static Vector3 Zero() {
        return Vector3(0.0f, 0.0f, 0.0f);
    }

    static float Dot(Vector3 a, Vector3 b) {
        return a.X * b.X + a.Y * b.Y + a.Z * b.Z;
    }

    static float Distance(Vector3 a, Vector3 b) {
        Vector3 vector = Vector3(a.X - b.X, a.Y - b.Y, a.Z - b.Z);
        return sqrt(vector.X * vector.X + vector.Y * vector.Y + vector.Z * vector.Z);
    }
};


struct FRotator {
    float Pitch;
    float Yaw;
    float Roll;
    inline FRotator() : Pitch(0.0f), Yaw(0.0f), Roll(0.0f) {}
    inline FRotator(float pitch, float yaw, float roll) : Pitch(pitch), Yaw(yaw), Roll(roll) {}
    inline FRotator operator+(const FRotator &A) {
        return FRotator(this->Pitch + A.Pitch, this->Yaw + A.Yaw, this->Roll + A.Roll);
    }
    inline FRotator operator-(const FRotator &A) {
        return FRotator(this->Pitch - A.Pitch, this->Yaw - A.Yaw, this->Roll - A.Roll);
    }
    inline FRotator operator*(const FRotator &A) {
        return FRotator(this->Pitch * A.Pitch, this->Yaw * A.Yaw, this->Roll * A.Roll);
    }
    inline FRotator operator*(const float A) {
        return FRotator(this->Pitch * A, this->Yaw * A, this->Roll * A);
    }
    inline FRotator operator/(const FRotator &A) {
        return FRotator(this->Pitch / A.Pitch, this->Yaw / A.Yaw, this->Roll / A.Roll);
    }
    inline FRotator operator/(const float A) {
        return FRotator(this->Pitch / A, this->Yaw / A, this->Roll / A);
    }
    inline float Size() {
        return sqrt((this->Pitch * this->Pitch) + (this->Yaw * this->Yaw) + (this->Roll * this->Roll));
    }
    static Vector3 Vector3ToRotation(Vector3 v1) {
        Vector3 V = Vector3(0, 0, 0);
        V.Y = atan2(v1.Y, v1.X);
        V.X = atan2(v1.Z, sqrt(v1.X * v1.X + v1.Y * v1.Y));
        V.Z = 0;
        return V;
    }
};

struct MinimalViewInfo {
    Vector3 Location;
    Vector3 LocationLocalSpace;
    FRotator Rotation;
    char ViewTag[0xC];
    float FOV;
};

struct Vector4 {
    float x;
    float y;
    float z;
    float w;
};

struct D3DXMATRIX {
    float _11, _12, _13, _14;
    float _21, _22, _23, _24;
    float _31, _32, _33, _34;
    float _41, _42, _43, _44;
};

static D3DXMATRIX global_matrix;

struct FTransform {
    Vector4 rot;
    Vector3 translation;
    Vector3 scale;
    D3DXMATRIX ToMatrixWithScale() {
        D3DXMATRIX m;
        m._41 = translation.X;
        m._42 = translation.Y;
        m._43 = translation.Z;

        float x2 = rot.x + rot.x;
        float y2 = rot.y + rot.y;
        float z2 = rot.z + rot.z;

        float xx2 = rot.x * x2;
        float yy2 = rot.y * y2;
        float zz2 = rot.z * z2;
        m._11 = (1.0f - (yy2 + zz2)) * scale.X;
        m._22 = (1.0f - (xx2 + zz2)) * scale.Y;
        m._33 = (1.0f - (xx2 + yy2)) * scale.Z;

        float yz2 = rot.y * z2;
        float wx2 = rot.w * x2;
        m._32 = (yz2 - wx2) * scale.Z;
        m._23 = (yz2 + wx2) * scale.Y;

        float xy2 = rot.x * y2;
        float wz2 = rot.w * z2;
        m._21 = (xy2 - wz2) * scale.Y;
        m._12 = (xy2 + wz2) * scale.X;

        float xz2 = rot.x * z2;
        float wy2 = rot.w * y2;
        m._31 = (xz2 + wy2) * scale.Z;
        m._13 = (xz2 - wy2) * scale.X;

        m._14 = 0.0f;
        m._24 = 0.0f;
        m._34 = 0.0f;
        m._44 = 1.0f;

        return m;
    }
    static D3DXMATRIX MatrixMultiplication(D3DXMATRIX pM1, D3DXMATRIX pM2) {
        D3DXMATRIX pOut;
        pOut._11 = pM1._11 * pM2._11 + pM1._12 * pM2._21 + pM1._13 * pM2._31 + pM1._14 * pM2._41;
        pOut._12 = pM1._11 * pM2._12 + pM1._12 * pM2._22 + pM1._13 * pM2._32 + pM1._14 * pM2._42;
        pOut._13 = pM1._11 * pM2._13 + pM1._12 * pM2._23 + pM1._13 * pM2._33 + pM1._14 * pM2._43;
        pOut._14 = pM1._11 * pM2._14 + pM1._12 * pM2._24 + pM1._13 * pM2._34 + pM1._14 * pM2._44;
        pOut._21 = pM1._21 * pM2._11 + pM1._22 * pM2._21 + pM1._23 * pM2._31 + pM1._24 * pM2._41;
        pOut._22 = pM1._21 * pM2._12 + pM1._22 * pM2._22 + pM1._23 * pM2._32 + pM1._24 * pM2._42;
        pOut._23 = pM1._21 * pM2._13 + pM1._22 * pM2._23 + pM1._23 * pM2._33 + pM1._24 * pM2._43;
        pOut._24 = pM1._21 * pM2._14 + pM1._22 * pM2._24 + pM1._23 * pM2._34 + pM1._24 * pM2._44;
        pOut._31 = pM1._31 * pM2._11 + pM1._32 * pM2._21 + pM1._33 * pM2._31 + pM1._34 * pM2._41;
        pOut._32 = pM1._31 * pM2._12 + pM1._32 * pM2._22 + pM1._33 * pM2._32 + pM1._34 * pM2._42;
        pOut._33 = pM1._31 * pM2._13 + pM1._32 * pM2._23 + pM1._33 * pM2._33 + pM1._34 * pM2._43;
        pOut._34 = pM1._31 * pM2._14 + pM1._32 * pM2._24 + pM1._33 * pM2._34 + pM1._34 * pM2._44;
        pOut._41 = pM1._41 * pM2._11 + pM1._42 * pM2._21 + pM1._43 * pM2._31 + pM1._44 * pM2._41;
        pOut._42 = pM1._41 * pM2._12 + pM1._42 * pM2._22 + pM1._43 * pM2._32 + pM1._44 * pM2._42;
        pOut._43 = pM1._41 * pM2._13 + pM1._42 * pM2._23 + pM1._43 * pM2._33 + pM1._44 * pM2._43;
        pOut._44 = pM1._41 * pM2._14 + pM1._42 * pM2._24 + pM1._43 * pM2._34 + pM1._44 * pM2._44;

        return pOut;
    }
};
struct CameraViewInfo {
    Vector3 Location;
    FRotator Rotation;
    float FOV;
};

static CameraViewInfo global_camera_view;

static FTransform ReadFTransform(uintptr_t address) {
    FTransform transform;
    transform.rot.x = Read<float>(address);
    transform.rot.y = Read<float>(address + 0x4);
    transform.rot.z = Read<float>(address + 0x8);
    transform.rot.w = Read<float>(address + 0xC);
    transform.translation.X = Read<float>(address + 0x10);
    transform.translation.Y = Read<float>(address + 0x14);
    transform.translation.Z = Read<float>(address + 0x18);
    transform.scale.X = Read<float>(address + 0x20);
    transform.scale.Y = Read<float>(address + 0x24);
    transform.scale.Z = Read<float>(address + 0x28);
    return transform;
}

static Vector3 GetBoneFTransform(uintptr_t root_component, uintptr_t bone_array, int bone_id) {
    FTransform bone_transform = ReadFTransform(bone_array + 0x30 * bone_id);
    FTransform component_transform = ReadFTransform(root_component);
    D3DXMATRIX Matrix = FTransform::MatrixMultiplication(bone_transform.ToMatrixWithScale(), component_transform.ToMatrixWithScale());
    return Vector3(Matrix._41, Matrix._42, Matrix._43);
}

static void BuildRotationMatrix(FRotator rotation) {
    float pitch_rad = rotation.Pitch * 0.0174532925f;
    float yaw_rad = rotation.Yaw * 0.0174532925f;
    float roll_rad = rotation.Roll * 0.0174532925f;
    float sin_pitch = sinf(pitch_rad);
    float cos_pitch = cosf(pitch_rad);
    float sin_yaw = sinf(yaw_rad);
    float cos_yaw = cosf(yaw_rad);
    float sin_roll = sinf(roll_rad);
    float cos_roll = cosf(roll_rad);
    global_matrix._11 = cos_pitch * cos_yaw;
    global_matrix._12 = cos_pitch * sin_yaw;
    global_matrix._13 = sin_pitch;
    global_matrix._14 = 0.0f;
    global_matrix._21 = (sin_roll * sin_pitch * cos_yaw) - (cos_roll * sin_yaw);
    global_matrix._22 = (sin_roll * sin_pitch * sin_yaw) + (cos_roll * cos_yaw);
    global_matrix._23 = -sin_roll * cos_pitch;
    global_matrix._24 = 0.0f;
    global_matrix._31 = -((cos_roll * sin_pitch * cos_yaw) + (sin_roll * sin_yaw));
    global_matrix._32 = (cos_yaw * sin_roll) - (cos_roll * sin_pitch * sin_yaw);
    global_matrix._33 = cos_roll * cos_pitch;
    global_matrix._34 = 0.0f;
    global_matrix._41 = 0.0f;
    global_matrix._42 = 0.0f;
    global_matrix._43 = 0.0f;
    global_matrix._44 = 1.0f;
}

static Vector3 GetRelativeLocation(long actor) {
    return Read<Vector3>(Read<long>(actor + GetFieldAddress(KGetActorLocation)) + GetFieldAddress(KGetActorRocation));
}

static bool GetInsideFov(Vector2 PlayerBone, float FovRadius) {
    Vector2 Cenpoint;
    Cenpoint.X = PlayerBone.X - kuan / 2;
    Cenpoint.Y = PlayerBone.Y - gao / 2;
    return Cenpoint.X * Cenpoint.X + Cenpoint.Y * Cenpoint.Y <= FovRadius * FovRadius;
}

static int GetCenterOffsetForVector(Vector2 point) {
    return sqrt(pow(point.X - kuan / 2, 2) + pow(point.Y - gao / 2, 2));
}

static FRotator Clamp(FRotator r) {
    if (r.Yaw > 180.f)
        r.Yaw -= 360.f;
    else if (r.Yaw < -180.f)
        r.Yaw += 360.f;

    if (r.Pitch > 180.f)
        r.Pitch -= 360.f;
    else if (r.Pitch < -180.f)
        r.Pitch += 360.f;

    if (r.Pitch < -89.f)
        r.Pitch = -89.f;
    else if (r.Pitch > 89.f)
        r.Pitch = 89.f;

    r.Roll = 0.f;

    return r;
}

static FRotator ToRotator(Vector3 aimPos, Vector3 target) {
    Vector3 rotation = aimPos - target;
    float hyp = sqrt(rotation.X * rotation.X + rotation.Y * rotation.Y);
    FRotator newViewAngle = FRotator();
    newViewAngle.Pitch = -atan(rotation.Z / hyp) * (180.f / M_PI);
    newViewAngle.Yaw = atan(rotation.Y / rotation.X) * (180.f / M_PI);
    newViewAngle.Roll = 0.f;

    if (rotation.X >= 0.f)
        newViewAngle.Yaw += 180.0f;

    return newViewAngle;
}

static int BoneColos(bool b1, bool b2, bool isAi) {
    if (isAi) return b1 || b2 ? Colour_Green : Colour_White;
    else return b1 || b2 ? Colour_Green : Colour_Red;
}

NS_ASSUME_NONNULL_END