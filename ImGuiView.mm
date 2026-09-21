// Created by chunmod on 2025/05/12.
// Telegram: @chunmodvn
// Source: SharkIOS Deltaforce
// Description: ImGui view implementation for menu interface

#import "ImGuiView.h"
#import "Tool/hpfont.h"
#import "ImGuiDraw.h"
#include "imgui/fonts.h"

extern void DrawText(std::string text, ImVec2 pos, bool isCentered, int color, bool outline, float fontSize) {
    const char *str = text.c_str();
    ImVec2 vec2 = pos;

    if (isCentered) {
        ImFont* font = ImGui::GetFont();
        font->Scale = 40.f / font->FontSize;

        ImVec2 textSize = font->CalcTextSizeA(fontSize, MAXFLOAT, 0.0f, str);
        vec2.x -= textSize.x * 0.5f;
    }
    if (outline) {
        ImU32 outlineColor = 0xFF000000;
        ImGui::GetBackgroundDrawList()->AddTextX(ImVec2(vec2.x + 1, vec2.y + 1), outlineColor, fontSize, str);
        ImGui::GetBackgroundDrawList()->AddTextX(ImVec2(vec2.x - 1, vec2.y - 1), outlineColor, fontSize, str);
        ImGui::GetBackgroundDrawList()->AddTextX(ImVec2(vec2.x + 1, vec2.y - 1), outlineColor, fontSize, str);
        ImGui::GetBackgroundDrawList()->AddTextX(ImVec2(vec2.x - 1, vec2.y + 1), outlineColor, fontSize, str);
    }
    ImGui::GetBackgroundDrawList()->AddTextX(vec2, color, fontSize, str);
}

@implementation Renderer {
    id<MTLDevice> device;
    id<MTLCommandQueue> _commandQueue;
}

-(instancetype)initWithMetalKitView:(MTKView *)mtkView {
    self = [super init];
    if (self) {
        device = mtkView.device;
        _commandQueue = [device newCommandQueue];
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO(); (void)io;
        ImGui::StyleColorsClassic();

        // Khởi tạo font mặc định
        io.Fonts->AddFontFromMemoryTTF((void *)font_data, font_size, 40, NULL, io.Fonts->GetGlyphRangesChineseFull());
        
      
        ImGui_ImplMetal_Init(device);
    }
    return self;
}

- (void)drawInMTKView:(MTKView*)view {
    ImGuiIO& io = ImGui::GetIO();
    CGFloat framebufferScale = UIScreen.mainScreen.scale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    io.DisplaySize.x = view.currentDrawable.layer.drawableSize.width / framebufferScale;
    io.DisplaySize.y = view.currentDrawable.layer.drawableSize.height / framebufferScale;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    static float clear_color[4] = { 0, 0, 0, 0 };

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clear_color[0], clear_color[1], clear_color[2], clear_color[3]);

        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

        [renderEncoder pushDebugGroup:@"ImGui demo"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        MyMenu();
        if (IsProxyAuthenticated()) {
            ReaMemData();
        }

        ImGui::GetForegroundDrawList()->PushClipRectFullScreen();
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);

        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {}

@end