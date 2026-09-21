#include "Other/nav_elements.h"

struct tab_element {
    float element_opacity, rect_opacity, text_opacity;
};

bool elements::tab(const char* name, bool boolean)
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(name);
    const ImVec2 label_size = tab_icons->CalcTextSizeA(15.0f, FLT_MAX, 0.0f, name);
    ImVec2 pos = window->DC.CursorPos;

    const ImRect rect(pos, ImVec2(pos.x + 21, pos.y + 24));
    ImGui::ItemSize(ImVec4(rect.Min.x, rect.Min.y, rect.Max.x, rect.Max.y + 5), style.FramePadding.y);
    if (!ImGui::ItemAdd(rect, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(rect, id, &hovered, &held, 0);

    static std::map <ImGuiID, tab_element> anim;
    auto it_anim = anim.find(id);
    if (it_anim == anim.end()) {
        anim.insert({ id, { 0.0f, 0.0f, 0.0f } });
        it_anim = anim.find(id);
    }

    it_anim->second.element_opacity = ImLerp(it_anim->second.element_opacity, (boolean ? 0.04f : hovered ? 0.01f : 0.0f), 0.07f * (1.0f - ImGui::GetIO().DeltaTime));
    it_anim->second.rect_opacity = ImLerp(it_anim->second.rect_opacity, (boolean ? 1.0f : 0.0f), 0.15f * (1.0f - ImGui::GetIO().DeltaTime));
    it_anim->second.text_opacity = ImLerp(it_anim->second.text_opacity, (boolean ? 1.0f : hovered ? 0.5f : 0.3f), 0.07f * (1.0f - ImGui::GetIO().DeltaTime));

    window->DrawList->AddRectFilled(rect.Min, rect.Max, ImColor(1.0f, 1.0f, 1.0f, it_anim->second.element_opacity), 3.0f);
    window->DrawList->AddText(tab_icons, 15.0f, (rect.Min + rect.Max - label_size) / 2, ImColor(1.0f, 1.0f, 1.0f, it_anim->second.text_opacity), name);

    window->DrawList->AddRectFilled(ImVec2(rect.Max.x + 2, rect.Min.y + 4), ImVec2(rect.Max.x + 5, rect.Max.y - 4), ImColor(195 / 255.0f, 143 / 255.0f, 255 / 255.0f, it_anim->second.rect_opacity), 7.0f, ImDrawFlags_RoundCornersLeft);

    return pressed;
}

struct subtab_element {
    float element_opacity, rect_opacity, text_opacity;
};

bool elements::subtab(const char* name, bool boolean)
{
    ImGuiWindow* window = ImGui::GetCurrentWindow();
    if (window->SkipItems)
        return false;

    ImGuiContext& g = *GImGui;
    const ImGuiStyle& style = g.Style;
    const ImGuiID id = window->GetID(name);
    const ImVec2 label_size = ImGui::CalcTextSize(name);
    ImVec2 pos = window->DC.CursorPos;

    const ImRect rect(pos, ImVec2(pos.x + 130, pos.y + 25));
    ImGui::ItemSize(ImVec4(rect.Min.x, rect.Min.y, rect.Max.x, rect.Max.y + 2), style.FramePadding.y);
    if (!ImGui::ItemAdd(rect, id))
        return false;

    bool hovered, held;
    bool pressed = ImGui::ButtonBehavior(rect, id, &hovered, &held, 0);

    static std::map <ImGuiID, subtab_element> anim;
    auto it_anim = anim.find(id);
    if (it_anim == anim.end()) {
        anim.insert({ id, { 0.0f, 0.0f, 0.0f } });
        it_anim = anim.find(id);
    }

    it_anim->second.element_opacity = ImLerp(it_anim->second.element_opacity, (boolean ? 0.04f : 0.0f), 0.09f * (1.0f - ImGui::GetIO().DeltaTime));
    it_anim->second.rect_opacity = ImLerp(it_anim->second.rect_opacity, (boolean ? 1.0f : 0.0f), 0.20f * (1.0f - ImGui::GetIO().DeltaTime));
    it_anim->second.text_opacity = ImLerp(it_anim->second.text_opacity, (boolean ? 1.0f : 0.3f), 0.07f * (1.0f - ImGui::GetIO().DeltaTime));

    window->DrawList->AddRectFilled(rect.Min, rect.Max, ImColor(1.0f, 1.0f, 1.0f, it_anim->second.element_opacity), 3.0f);
    window->DrawList->AddText(ImVec2(rect.Min.x + (130 - label_size.x) / 2, rect.Min.y + (25 - label_size.y) / 2), ImColor(1.0f, 1.0f, 1.0f, it_anim->second.text_opacity), name);


    window->DrawList->AddRectFilled(ImVec2(rect.Min.x, rect.Min.y + 4), ImVec2(rect.Min.x + 3, rect.Max.y - 4), ImColor(195 / 255.0f, 143 / 255.0f, 255 / 255.0f, it_anim->second.rect_opacity), 7.0f, ImDrawFlags_RoundCornersLeft);
    window->DrawList->AddRectFilled(ImVec2(rect.Max.x - 3, rect.Min.y + 4), ImVec2(rect.Max.x, rect.Max.y - 4), ImColor(195 / 255.0f, 143 / 255.0f, 255 / 255.0f, it_anim->second.rect_opacity), 7.0f, ImDrawFlags_RoundCornersRight);


    return pressed;
}
