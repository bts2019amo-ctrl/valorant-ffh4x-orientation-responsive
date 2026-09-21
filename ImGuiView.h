// Created by chunmod on 2025/05/12.
// Telegram: @chunmodvn
// Source: SharkIOS Deltaforce
// Description: ImGui view header file for menu interface



#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#include "imgui/imgui_impl_metal.h"
#include "imgui/imgui.h"
#include <functional>
#define kuan [UIScreen mainScreen].bounds.size.width
#define gao [UIScreen mainScreen].bounds.size.height
#ifndef IM_PI
#define IM_PI 3.14159265358979323846f
#endif
#define RAD2DEG(x) ((float)(x) * (float)(180.f / IM_PI))
#define DEG2RAD(x) ((float)(x) * (float)(IM_PI / 180.f))

@interface Renderer : NSObject<MTKViewDelegate>
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKView *mtkView;
-(instancetype)initWithMetalKitView:(MTKView *)mtkView;
@end

@interface sdkafowanbnonowaf : MTKView
extern sdkafowanbnonowaf * Global_DrawView;
extern Renderer *g_renderer;
@end

#pragma mark - Imgui Colors ===
#define Colour_Red 0xFF0000FF
#define Colour_Green 0xFF00FF00
#define Colour_Pink 0xFFCBC0FF
#define Colour_Blue 0xFFFF0000
#define Colour_LightBlue 0xFFFACE87
#define Colour_Cyan 0xFFFFFF00
#define Colour_Emerald 0xFFAAFF7F
#define Colour_GrassGreen 0xFF00FC7C
#define Colour_Orange 0xFF00A5FF
#define Colour_DarkOrange 0xFF0066FF
#define Colour_Peach 0xFFB9DAFF
#define Colour_Coral 0xFF507FFF
#define Colour_Purple 0xFFEE677A
#define Colour_SlateGray 0xFF908070
#define Colour_White 0xFFFFFFFF
#define Colour_Black 0xFF000000
#define Colour_Lime 0xFFADFF2F
#define Colour_Yellow 0xFF00FFFF
#define Colour_TransparentRed 0x800000FF
#define Colour_TransparentOrange 0x8000A5FF
#define Colour_TransparentLime 0x80ADFF2F
#define Colour_TransparentGreen 0x8000FF00
#define Colour_TransparentSlateGray 0x80908070

extern void DrawText(std::string text, ImVec2 pos, bool isCentered, int color, bool outline, float fontSize);

static void DrawLine2(ImVec2 startPoint, ImVec2 endPoint, int color, float thickness = 0.05) {
    ImGui::GetBackgroundDrawList()->AddLine(startPoint, endPoint, color, thickness);
}

static void DrawRectangle(ImVec2 topLeft, ImVec2 bottomRight, int color, float thickness = 0.05f) {
    ImVec2 bottomLeft = ImVec2(topLeft.x, bottomRight.y);
    ImVec2 topRight = ImVec2(bottomRight.x, topLeft.y);

    DrawLine2(topLeft, ImVec2(bottomRight.x, topLeft.y), color, thickness); // Cạnh trên
    DrawLine2(bottomLeft, ImVec2(bottomRight.x, bottomLeft.y), color, thickness); // Cạnh dưới
    DrawLine2(topLeft, bottomLeft, color, thickness); // Cạnh trái
    DrawLine2(topRight, bottomRight, color, thickness); // Cạnh phải
}

static void DrawCircle(ImVec2 center, float radius, int color, int numSegments, float thickness = 0.5) {
    ImGui::GetBackgroundDrawList()->AddCircle(center, radius, color, numSegments, thickness);
}

static void DrawCircularHealthBar(const ImVec2& center, float radius, float thickness, float healthPercentage, ImU32 borderColor, ImU32 backgroundColor, ImU32 highlightColor) {
    float startAngle = IM_PI * 1.5f;
    float endAngle = startAngle + IM_PI * 2.0f * healthPercentage;

    ImU32 healthBarColor;
    if (healthPercentage < 0.3f) {
        healthBarColor = ImColor(255, 0, 0, 255); // Màu đỏ khi máu thấp
    } else if (healthPercentage < 0.7f) {
        healthBarColor = ImColor(255, 165, 0, 255); // Màu vàng khi máu trung bình
    } else {
        healthBarColor = ImColor(255, 255, 255, 255); // Màu trắng khi máu cao
    }

    ImGui::GetBackgroundDrawList()->AddCircleFilled(center, radius, backgroundColor, 64);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius + thickness / 2, startAngle, startAngle + IM_PI * 2.0f, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(borderColor, false, thickness + 2.0f);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius, startAngle, endAngle, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(healthBarColor, false, thickness);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius + thickness / 2 + 1, startAngle, startAngle + IM_PI * 1.0f, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(highlightColor, false, 1.5f);
}

static void ZRDrawCircularHealthBar(const ImVec2& center, float radius, float thickness, float healthPercentage, ImU32 borderColor, ImU32 backgroundColor, ImU32 highlightColor) {
    float startAngle = IM_PI * 1.5f;
    float endAngle = startAngle + IM_PI * 2.0f * healthPercentage;

    ImU32 healthBarColor;
    if (healthPercentage < 0.3f) {
        healthBarColor = Colour_TransparentRed; // Màu đỏ trong suốt khi máu rất thấp
    } else if (healthPercentage < 0.7f) {
        healthBarColor = Colour_TransparentOrange; // Màu cam trong suốt khi máu trung bình
    } else {
        healthBarColor = Colour_TransparentGreen; // Màu xanh trong suốt khi máu cao
    }

    ImGui::GetBackgroundDrawList()->AddCircleFilled(center, radius, backgroundColor, 64);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius + thickness / 2, startAngle, startAngle + IM_PI * 2.0f, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(borderColor, false, thickness + 2.0f);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius, startAngle, endAngle, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(healthBarColor, false, thickness);
    ImGui::GetBackgroundDrawList()->PathArcTo(center, radius + thickness / 2 + 1, startAngle, startAngle + IM_PI * 1.0f, 64);
    ImGui::GetBackgroundDrawList()->PathStroke(highlightColor, false, 1.5f);
}



