void CrashApp() {
    NSLog(@"Detected abnormal data packet, the program will exit");
    abort();
}

unsigned int GetHealthColor(float health) {
    if (health > 75.0f) return 0xFF00FF00;
    if (health > 50.0f) return 0xFFFFFF00;
    if (health > 25.0f) return 0xFFFFA500;
    return 0xFFFF0000;
}

void DrawTextEx(const char* text, float x, float y, unsigned int color, float size) {
    ImDrawList* global_draw_list = ImGui::GetBackgroundDrawList();
    ImFont* font = ImGui::GetFont();
    ImVec2 position(x, y);
    global_draw_list->AddText(font, size, position, color, text, nullptr, 0.0f, nullptr);
}


void DrawFillRect(float x, float y, float width, float height, unsigned int color) {
    ImDrawList* global_draw_list = ImGui::GetBackgroundDrawList();
    ImVec2 min(x, y);
    ImVec2 max(x + width, y + height);
    global_draw_list->AddRectFilled(min, max, color, 0.0f, 0);
}

void DrawLine(float start_x, float start_y, float end_x, float end_y, unsigned int color, float thickness) {
    ImDrawList* global_draw_list = ImGui::GetBackgroundDrawList();
    ImVec2 start(start_x, start_y);
    ImVec2 end(end_x, end_y);
    global_draw_list->AddLine(start, end, color, thickness);
}

extern void ReaMemData() { // Viết dữ liệu trong hàm này, nó sẽ chạy liên tục
    [[NSNotificationCenter defaultCenter] addObserverForName:@"CrashAppNotification"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        CrashApp();
    }];

    if (!EnableSwitch) {
        return; // Nếu công tắc chống ban không bật, thoát ngay
    }

    CanvasSize.X = kuan;
    CanvasSize.Y = gao;
    totalEnemies = 0;
    AItotalEnemies = 0;

    DrawTextEx("", 0.0f, 0.0f, 0xFF0000FF, 50.0f);
    if (moudule_base > 0) {
        uintptr_t world = Read<uintptr_t>(GetRealOffset("0x108EF9680"));
        if (IsValidAddress(world)) {
            uintptr_t game_instance = Read<uintptr_t>(world + 0x30);
            if (IsValidAddress(game_instance)) {
                uintptr_t local_player_controller = Read<uintptr_t>(game_instance + 0x2E0);
                if (IsValidAddress(local_player_controller)) {
                    uintptr_t local_player_pawn = Read<uintptr_t>(local_player_controller + 0x2D0);
                    if (IsValidAddress(local_player_pawn)) {
                        int local_team_id = Read<int>(local_player_pawn + 0x480);
                        uintptr_t spectator_camera = Read<uintptr_t>(game_instance + 0x348) + 0x21D0;
                        if (IsValidAddress(spectator_camera)) {
                            global_camera_view.Location = Read<Vector3>(spectator_camera);
                            global_camera_view.Rotation = Read<FRotator>(spectator_camera + 0x18);
                            global_camera_view.FOV = Read<float>(spectator_camera + 0x2C);
                            BuildRotationMatrix(global_camera_view.Rotation);
                            int enemy_count = 0;
                            uintptr_t persistent_level = Read<uintptr_t>(world + 0x70);
                            uintptr_t actors = Read<uintptr_t>(persistent_level + 0x70);
                            uintptr_t actor_cluster = Read<uintptr_t>(actors + 0x198);
                            uintptr_t actor_array = Read<uintptr_t>(actor_cluster + 0x2C8);
                            int max_actors = 20;
                            for (int index = 0; index < max_actors; ++index) {
                                uintptr_t current_actor = Read<uintptr_t>(actor_array + 0x8 * index);
                                if (IsValidAddress(current_actor)) {
                                    uintptr_t actor_player_state = Read<uintptr_t>(current_actor + 0x310);
                                    if (IsValidAddress(actor_player_state) && actor_player_state != local_player_controller) {
                                        uintptr_t actor_pawn = Read<uintptr_t>(actor_player_state + 0x2D0);
                                        if (IsValidAddress(actor_pawn)) {
                                            int actor_team_id = Read<int>(actor_pawn + 0x480);
                                            if (actor_team_id != local_team_id) {
                                                uintptr_t actor_root_component = Read<uintptr_t>(actor_player_state + 0x320);
                                                if (IsValidAddress(actor_root_component)) {
                                                    Vector3 actor_position = Read<Vector3>(actor_root_component + 0x1F0);
                                                    Vector2 actor_screen = ProjectWorldToScreen(actor_position, 30.0f);
                                                    float screen_x = actor_screen.X;
                                                    float screen_y = actor_screen.Y;
                                                    if (screen_x != 0.0f && screen_y != 0.0f && screen_x <= static_cast<float>(kuan) && screen_y <= static_cast<float>(gao)) {
                                                        uintptr_t damage_controller = Read<uintptr_t>(actor_player_state + 0x6B8);
                                                        uintptr_t health_component = Read<uintptr_t>(damage_controller + 0x158);
                                                        uintptr_t health_holder = Read<uintptr_t>(health_component);
                                                        if (IsValidAddress(health_holder)) {
                                                            float current_health = Read<float>(health_holder + 0xD0);
                                                            DrawLine(static_cast<float>(kuan) / 2.0f, 0.0f, screen_x, screen_y - 20.0f, 0xFFFFFFFF, Scalesi);
                                                            enemy_count++;
                                                            uintptr_t actor_base_component = Read<uintptr_t>(current_actor + 0x310) + 0x1E0;
                                                            uintptr_t actor_bone_array = Read<uintptr_t>(current_actor + 0x310 + 0x570);
                                                            Vector3 head_position = GetBoneFTransform(actor_base_component, actor_bone_array, 74);
                                                            Vector2 head_screen_position = ProjectWorldToScreen(head_position, 0.0f);
                                                            Vector3 neck_position = GetBoneFTransform(actor_base_component, actor_bone_array, 73);
                                                            Vector2 neck_screen_position = ProjectWorldToScreen(neck_position, 0.0f);
                                                            Vector3 chest_position = GetBoneFTransform(actor_base_component, actor_bone_array, 72);
                                                            Vector2 chest_screen_position = ProjectWorldToScreen(chest_position, 0.0f);
                                                            DrawLine(head_screen_position.X, head_screen_position.Y, neck_screen_position.X, neck_screen_position.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(neck_screen_position.X, neck_screen_position.Y, chest_screen_position.X, chest_screen_position.Y, 0xFFFFFFFF, Scalesi);
                                                            Vector3 left_shoulder_position = GetBoneFTransform(actor_base_component, actor_bone_array, 70);
                                                            Vector2 left_shoulder_screen = ProjectWorldToScreen(left_shoulder_position, 0.0f);
                                                            Vector3 left_elbow_position = GetBoneFTransform(actor_base_component, actor_bone_array, 69);
                                                            Vector2 left_elbow_screen = ProjectWorldToScreen(left_elbow_position, 0.0f);
                                                            Vector3 left_hand_position = GetBoneFTransform(actor_base_component, actor_bone_array, 68);
                                                            Vector2 left_hand_screen = ProjectWorldToScreen(left_hand_position, 0.0f);
                                                            DrawLine(left_shoulder_screen.X, left_shoulder_screen.Y, left_elbow_screen.X, left_elbow_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(left_elbow_screen.X, left_elbow_screen.Y, left_hand_screen.X, left_hand_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            Vector3 pelvis_position = GetBoneFTransform(actor_base_component, actor_bone_array, 3);
                                                            Vector2 pelvis_screen_position = ProjectWorldToScreen(pelvis_position, 0.0f);
                                                            DrawLine(chest_screen_position.X, chest_screen_position.Y, pelvis_screen_position.X, pelvis_screen_position.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(left_hand_screen.X, left_hand_screen.Y, pelvis_screen_position.X, pelvis_screen_position.Y, 0xFFFFFFFF, Scalesi);
                                                            Vector3 left_thigh_position = GetBoneFTransform(actor_base_component, actor_bone_array, 6);
                                                            Vector2 left_thigh_screen = ProjectWorldToScreen(left_thigh_position, 0.0f);
                                                            DrawLine(pelvis_screen_position.X, pelvis_screen_position.Y, left_thigh_screen.X, left_thigh_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            Vector3 right_knee_position = GetBoneFTransform(actor_base_component, actor_bone_array, 46);
                                                            Vector2 right_knee_screen = ProjectWorldToScreen(right_knee_position, 0.0f);
                                                            Vector3 right_ankle_position = GetBoneFTransform(actor_base_component, actor_bone_array, 45);
                                                            Vector2 right_ankle_screen = ProjectWorldToScreen(right_ankle_position, 0.0f);
                                                            Vector3 right_foot_position = GetBoneFTransform(actor_base_component, actor_bone_array, 44);
                                                            Vector2 right_foot_screen = ProjectWorldToScreen(right_foot_position, 0.0f);
                                                            DrawLine(right_knee_screen.X, right_knee_screen.Y, right_ankle_screen.X, right_ankle_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(right_ankle_screen.X, right_ankle_screen.Y, right_foot_screen.X, right_foot_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(right_foot_screen.X, right_foot_screen.Y, left_thigh_screen.X, left_thigh_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            Vector3 left_knee_position = GetBoneFTransform(actor_base_component, actor_bone_array, 32);
                                                            Vector2 left_knee_screen = ProjectWorldToScreen(left_knee_position, 0.0f);
                                                            Vector3 left_ankle_position = GetBoneFTransform(actor_base_component, actor_bone_array, 31);
                                                            Vector2 left_ankle_screen = ProjectWorldToScreen(left_ankle_position, 0.0f);
                                                            Vector3 left_foot_position = GetBoneFTransform(actor_base_component, actor_bone_array, 30);
                                                            Vector2 left_foot_screen = ProjectWorldToScreen(left_foot_position, 0.0f);
                                                            DrawLine(left_knee_screen.X, left_knee_screen.Y, left_ankle_screen.X, left_ankle_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(left_ankle_screen.X, left_ankle_screen.Y, left_foot_screen.X, left_foot_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawLine(left_foot_screen.X, left_foot_screen.Y, left_thigh_screen.X, left_thigh_screen.Y, 0xFFFFFFFF, Scalesi);
                                                            DrawFillRect(head_screen_position.X - 12.0f, head_screen_position.Y, 6.0f, 60.0f, 0x80000000);
                                                            float health_bar_height = current_health * 0.6f;
                                                            DrawFillRect(head_screen_position.X - 12.0f, head_screen_position.Y, 6.0f, health_bar_height, GetHealthColor(current_health));
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            std::string count_string = std::to_string(enemy_count);
                            DrawTextEx(count_string.c_str(), kuan/2, 10.0f, 0xFF0000FF, 0.0f);
                        }
                    }
                }
            }
        }
    }
}

Vector3 GetComponentVelocity(long Actor) {
    long RootComponent = Read<long>(Actor + GetFieldAddress("0x180"));
    if (!IsValidAddress(RootComponent)) return Vector3{-1.0f, -1.0f, -1.0f};
    return Read<Vector3>(RootComponent + GetFieldAddress("0x188"));
};



static bool isScreenVisible(Vector2 LocationScreen, Vector2 CanvasSize) {
    if (LocationScreen.X > 0 && LocationScreen.X < CanvasSize.X &&
        LocationScreen.Y > 0 && LocationScreen.Y < CanvasSize.Y) return true;
    else return false;
}

static bool GetLineOfSightTo(long Object, Vector3 Coord) {
    if (PlayerController <= 0) return 0;

    int LineTraceData[100] = {0};
    long IDLineOfSight = Read<long>(GetRealOffset(kLineOfSight_1));

    Vector3 SelfLocation = POV.Location;
    long Hit = GetRealOffset(kLineOfSight_2);

    reinterpret_cast<void(*)(long, long, long, long, long)>(GetRealOffset(kLineOfSight_3))((long)&LineTraceData[0], IDLineOfSight, (long)&LineTraceData[40], 1, Character);

    reinterpret_cast<void(*)(long, long)>(GetRealOffset(kLineOfSight_4))((long)&LineTraceData[0], Object);

    int ret = reinterpret_cast<int(*)(long, Vector3*, Vector3*, long, long, long)>(GetRealOffset(kLineOfSight_5))(GWorld, &SelfLocation, &Coord, 3, (long)&LineTraceData[0], Hit);

    return (ret & 0x1) == 0;
}

static void GetViewportSize(int32_t& SizeX, int32_t& SizeY) {
    // Lấy kích thước khung nhìn
    if (!IsValidAddress(PlayerController)) {
        SizeX = 0;
        SizeY = 0;
        return;
    }

    const auto function_address = reinterpret_cast<void*>(GetRealOffset(kGetViewportSize));
    if (function_address) {
        using GetViewportSizeFunc = void(*)(long, int32_t*, int32_t*);
        auto GetViewportSize = reinterpret_cast<GetViewportSizeFunc>(function_address);
        GetViewportSize(reinterpret_cast<long>(PlayerController), &SizeX, &SizeY);
    } else {
        SizeX = 0;
        SizeY = 0;
    }
}

Vector2 ProjectWorldToScreen(Vector3 world_position, float absolute_height) {
    Vector3 local_position = world_position - global_camera_view.Location;
    local_position.Z += absolute_height;
    float depth = local_position.X * global_matrix._31 + local_position.Y * global_matrix._32 + local_position.Z * global_matrix._33;
    float projected_x = local_position.X * global_matrix._11 + local_position.Y * global_matrix._12 + local_position.Z * global_matrix._13;
    if (projected_x >= 0.0f) {
        float projected_y = local_position.X * global_matrix._21 + local_position.Y * global_matrix._22 + local_position.Z * global_matrix._23;
        float fov_angle = global_camera_view.FOV * 0.00872664626f;
        float tan_fov = tanf(fov_angle);
        float screen_x = kuan/2 + (projected_y * (kuan/2 / tan_fov)) / projected_x;
        float screen_y = gao/2 - (depth * (kuan/2 / tan_fov)) / projected_x;
        return Vector2(screen_x, screen_y);
    }
    return Vector2(0.0f, 0.0f);
}

