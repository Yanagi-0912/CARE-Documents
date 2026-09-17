---
# System prepended metadata

title: 系統設計文件(SDD)

---


# 系統設計文件(SDD)

- 專案名稱：CARE
- 撰寫日期：2025/11/23
- 發展者：游承諺、王洪賢、張宸翊、蘇奕勳、蕭丞佑

---

## 版次變更記錄

| 版次 | 變更項目 | 變更日期 |
| --- | ------- | ------- |
| 0.1 | 初版 | 2025/12/25 |
| 0.2 | 流程圖+UI | 2026/02/11 |
| 0.3 | C4 Diagram更新 | 2026/02/17 |
| 0.4 | MVP | 2026/03/03 |
| 0.5 | C4、設計議題、gui更新 | 2026/04/09 |
| 0.6 | 補充前後端介面、諮詢流程圖、gui | 2026/05/10 |
| 0.7 | I3 設計細節 | 2026/05/12 |
| 0.8 | I4 設計細節 | 2026/08/11 |
| 0.8.1 | I5 流程優化 | 2026/08/12 |
| 0.9 | I5 設計細節 | 2026/08/12 |
| 1.0 | I6 協助掛號優化與 I7風險警示 | 2026/09/12 |
| 1.1 | 補充 I7 日常健康、用藥安全、主動照護與家庭安全設計 | 2026/09/17 |
---

## 目錄

1. [系統模型與架構 (System Model / System Architecture)](#section1)
2. [介面需求與設計 (Interface Requirement and Design)](#section2)
3. [流程設計 (Process Design)](#section3)
4. [使用者畫面設計 (User Interface Design)](#section4)
5. [資料設計 (Data Design)](#section5)
6. [類別圖設計 (Class Diagram)](#section6)
7. [實作方案 (Implementation Languages and Platforms)](#section7)
8. [設計議題 (Design Issue)](#section8)

---

## <span id="section1"> 1. 系統模型與架構 (System Model / System Architecture)</span>
### [C4Model](https://hackmd.io/7q4shvxLTwi7pk62yLSLOA)

### MVP
```mermaid
flowchart TB

    %% ========== Client Layer ==========
    subgraph Client Layer
        user([使用者])
        lineUI[LINE Messaging UI]
    end

    %% ========== Backend Layer ==========
    subgraph Backend Layer
        webhook[Webhook Controller]
        service[AI Service Logic]
    end

    %% ========== External Service ==========
    subgraph External Service
        gemini[Gemini API]
    end

    %% Flow
    user --> lineUI
    lineUI --> webhook
    webhook --> service
    service --> gemini
    gemini --> service
    service --> webhook
    webhook --> lineUI
    lineUI --> user
```

### Iteration 2

```mermaid
flowchart TB

    %% ===================== Client =====================
    subgraph Client_Layer
        user([使用者])
        lineUI[LINE Messaging UI]
    end

    %% ===================== Backend =====================
    subgraph Backend_Layer_FastAPI
        webhook[Webhook Router]

        subgraph Media_Processing
            stt[Speech-to-Text]
            videoParser[Video / Audio Parser]
        end

        subgraph MCP_Layer
            rag[RAG Engine]
            embed[Embedding Model]
            vectordb[(Vector Database)]
        end

        service[AI Orchestration Service]
    end

    %% ===================== External AI =====================
    subgraph External_AI_Service
        gemini[Gemini API]
    end

    %% ===================== Flow =====================

    user --> lineUI
    lineUI --> webhook

    %% 文字
    webhook --> service

    %% 語音
    webhook --> stt
    stt --> service

    %% 影音
    webhook --> videoParser
    videoParser --> service

    %% RAG
    service --> embed
    embed --> vectordb
    vectordb --> rag
    rag --> service

    %% AI
    service --> gemini
    gemini --> service

    service --> webhook
    webhook --> lineUI
    lineUI --> user
```

---

### Iteration 3

```mermaid
flowchart TB

    User[LINE 使用者]
    LINE[LINE App / LIFF]

    subgraph K8S[Kubernetes Cluster]
        direction TB

        subgraph Gateway[Kong Gateway]
            Kong[Kong Proxy]
        end

        subgraph Frontend[Frontend Namespace]
            LiffPod[LIFF React Pod]
            LiffSvc[LIFF Service]
        end

        subgraph Backend[Backend Namespace]
            ApiPod[FastAPI Pod]
            ApiSvc[FastAPI Service]
        end

        subgraph Workflow[Workflow Namespace]
            N8nPod[n8n Pod]
            N8nSvc[n8n Service]
        end

        subgraph Storage[Persistent Storage]
            PVC1[(n8n PVC)]
        end

        N8nPod --- PVC1

        LiffSvc --> LiffPod
        ApiSvc --> ApiPod
        N8nSvc --> N8nPod

        Kong --> LiffSvc
        Kong --> ApiSvc
        Kong --> N8nSvc
    end

    User --> LINE
    LINE --> Kong
```

## <span id="section2">2. 介面需求與設計 (Interface Requirement and Design)</span>

# fastAPI後端介面

## 使用者認證相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| liffLogin | auth module | LIFF 登入頁 | POST `/api/auth/liff/login` | `id_token` | `access_token`, `token_type`, `expires_in`, `line_user_id` | 前端送出 LIFF `id_token`，後端驗證後簽發系統 JWT token |

## 個人資料相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| getUserProfile | profile module | 個人資料頁 | GET `/api/profiles/me` |  Authorization Bearer token | 使用者個人健康資料（profile） | 取得指定使用者個人資料；僅允許查看自己的資料 |
| upsertUserProfile | profile module | 個人資料編輯頁 | PUT `/api/profiles/me/update` | body:`UserProfileData` + Authorization Bearer token | `{updated }` | 更新/寫入指定使用者個人健康資料；僅允許修改自己的資料 |

## 家庭功能相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| get_my_tree | family_tree_service | 家族樹頁面 | GET `/api/family/me` | `Header: Authorization (Bearer Token)` | `family_tree` | 取得指定使用者家族樹；若不存在則初始化後回傳 |
| create_invite | family_tree_service | 家族樹頁面邀請按鈕 | POST `/api/family/invites` | `Header: Authorization (Bearer Token)` | `invite_token`, `expires_at` | 建立家族邀請連結供分享 |
| verify_invite | family_tree_service | 邀請連結 | GET `/api/family/invites/verify/{code}` | `code: str` | `inviter_display_name`, `expires_at` | 驗證邀請碼是否有效並回傳邀請人名稱與過期時間。 |
| accept_invite | family_tree_service | 接受邀請按鈕 | POST `/api/family/invites/accept` | `Header: Authorization (Bearer Token)`, `Body: AcceptInviteRequest (code: str)` | `status: ["joined", "already_member"]` | 將邀請人與被邀請人分別加入對方的家庭成員。 |
| set_relationship | family_tree_service | 設定關係按鈕 | POST `/api/family/relationship` | `Header: Authorization (Bearer Token)`, `Body: SetRelationshipRequest (code: str)` | `FamilyTree` | 設定該成員的的關係。 |


## 紀錄對話相關 


| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| getRawConsultations | consultation module | 諮詢紀錄頁 / 除錯查詢頁 | GET `/api/consultations/me/messages/raw` | Authorization Bearer token | `ConsultationViewResponse.messages` | 取得目前登入使用者 Redis 內尚未過期的原始對話紀錄 |
| getMemberRawConsultations | consultation module | LIFF 家庭頁 / 家人諮詢紀錄頁 | GET `/api/consultations/{userId}/messages/raw` | Authorization Bearer token, path 參數 `userId` | `ConsultationViewResponse.messages` | 取得指定家庭成員 Redis 內尚未過期的原始對話紀錄。請求者須為本人，或 `userId` 在請求者的家庭族譜內，否則回 403 |


## 摘要相關

| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| summarizeConsultations | consultation module | 諮詢紀錄頁 / 手動摘要流程 | POST `/api/consultations/me/summary/generate` | Authorization Bearer token, `target_date`, `force` | `ConsultationSummary` | 讀取 Redis 暫存對話，呼叫 Gemini 產生摘要，並寫入 MongoDB |
| getMySummaryHistory | consultation module | 摘要歷史頁 | GET `/api/consultations/me/allsummaries` | Authorization Bearer token | `ConsultationSummary[]` | 取得目前登入使用者所有 MongoDB 摘要紀錄，依日期由新到舊排序 |
| getMyLatestSummary | consultation module | 摘要歷史頁 | GET `/api/consultations/me/summary/latest` | Authorization Bearer token | `ConsultationSummary` | 取得目前登入使用者最新一筆摘要|
| getMySummaryDownloadToken | consultation module | 摘要下載流程 | GET `/api/consultations/me/summary/downloadtoken` | Authorization Bearer token | `downloadToken`, `expiresIn` | 產生短效下載 token，供前端下載摘要 JSON 使用 |
| downloadMySummaryHistory | consultation module | 摘要下載流程 | GET `/api/consultations/me/summary/download` | query: `downloadToken` | JSON 檔案 | 使用短效 downloadToken 下載目前使用者所有諮詢摘要紀錄 |
| getMemberSummaryHistory | consultation module | LIFF 家庭頁 / 家人諮詢紀錄頁 | GET `/api/consultations/{userId}/allsummaries` | Authorization Bearer token, path 參數 `userId` | `list[ConsultationSummary]` | 取得指定家庭成員在 MongoDB 的所有諮詢摘要，依日期由新到舊排序。請求者須為本人，或 `userId` 在請求者的家庭族譜內，否則回 403 |

## 系統與Webhook相關（補充）
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| root | system module | 監控/測試 | GET `/` | 無 | `{ message }` | 檢查 API 啟動狀態 |
| healthCheck | system module | 監控/測試 | GET `/health` | 無 | `{ status }` | 健康檢查 |
| lineWebhookCallback | line module | LINE Platform | POST `/line/callback` | Header: `X-Line-Signature` + webhook body | `"OK"` | 接收 LINE webhook 事件並處理，異常時仍盡量回傳 200 OK 避免重試 |


## 家庭功能與照顧對象相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| get_my_tree | family_tree_service | 家族樹頁面 | GET `/api/family/me` | `Header: Authorization (Bearer Token)` | `family_tree` | 取得指定使用者家族樹；若不存在則初始化後回傳 |
| create_invite | family_tree_service | 家族樹頁面邀請按鈕 | POST `/api/family/invites` | `Header: Authorization (Bearer Token)` | `invite_token`, `expires_at` | 建立家族邀請連結供分享 |
| verify_invite | family_tree_service | 邀請連結 | GET `/api/family/invites/verify/{code}` | `code: str` | `inviter_display_name`, `expires_at` | 驗證邀請碼是否有效並回傳邀請人名稱與過期時間。 |
| accept_invite | family_tree_service | 接受邀請按鈕 | POST `/api/family/invites/accept` | `Header: Authorization (Bearer Token)`, `Body: AcceptInviteRequest (code: str)` | `status: ["joined", "already_member"]` | 將邀請人與被邀請人分別加入對方的家庭成員。 |
| set_relationship | family_tree_service | 設定關係按鈕 | POST `/api/family/relationship` | `Header: Authorization (Bearer Token)`, `Body: SetRelationshipRequest` | `FamilyTree` | 設定該成員的關係。 |
| set_care_recipient | family_tree_service | 設定照顧對象按鈕 | POST `/api/family/care-recipient` | `Header: Authorization (Bearer Token)`, `Body: SetCareRecipientRequest` | `FamilyTree` | 設定家族樹內特定成員是否為照顧對象標籤 (`is_care_recipient`)。 |

## 用藥提醒管理相關 
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| create_reminders | medication_service | 用藥設定頁 | POST `/api/medications/reminders` | `Header: Authorization`, `Body: CreateMedicationReminderRequest (user_id, slots, start_date, end_date)` | `List[MedicationReminder]` | 為自己或被照顧家屬勾選時段 (早/中/晚/睡前) 建立用藥提醒。 |
| get_reminders | medication_service | 用藥列表頁 | GET `/api/medications/reminders` | `Header: Authorization`, `Query: target_user_id?` | `List[MedicationReminder]` | 查詢自己或特定家庭成員的所有用藥提醒設定。 |
| update_reminder | medication_service | 用藥編輯頁 | PUT `/api/medications/reminders/{reminder_id}` | `Header: Authorization`, `Body: UpdateMedicationReminderRequest` | `MedicationReminder` | 修改指定用藥提醒的時間、起訖日期或開關狀態。 |
| delete_reminder | medication_service | 用藥編輯頁 | DELETE `/api/medications/reminders/{reminder_id}` | `Header: Authorization`, `Path: reminder_id` | `{"ok": true}` | 刪除指定的用藥提醒設定。 |
| confirm_medication | medication_service | LINE Flex Card 按鈕 | POST `/api/medications/confirm/{log_id}` | `Header: Authorization`, `Path: log_id` | `MedicationLog` | 用藥者確認已用藥，更新日誌狀態為 `taken` 並紀錄服藥時間。 |

## 掛號提醒相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| list_reminders | appointment_service | 掛號提醒列表頁 | GET `/api/appointments/reminders` | `Header: Authorization (Bearer Token)`, `Query: target_user_id?: str, scope?: "upcoming" \| "past", limit?: int (1–50，預設 20), cursor?: str, include_past?: bool` | 帶 `scope`：`{ items: AppointmentReminderResponse[], next_cursor, total_count }`；不帶：`AppointmentReminderResponse[]` | 取得本人或家人的掛號提醒。`upcoming` 為未取消且當日未結束的門診，由早到晚、不分頁；`past` 為當日已結束或已取消的門診，由新到舊、以 cursor 分頁。查詢家人需具備 GENERAL 讀取權 |
| create_reminder | appointment_service | 新增掛號表單 | POST `/api/appointments/reminders` | `Header: Authorization (Bearer Token)`, `Body: CreateAppointmentReminderRequest (user_id, appointment_at, hospital_name, department, facility_id?, hospital_address?, hospital_phone?, doctor_name?, serial_number?, note?)` | `AppointmentReminderResponse` | 為本人或家人建立掛號提醒。`appointment_at` 須為帶時區的 ISO 8601；同一就診者同一時間只能有一筆未取消的掛號。為家人建立需具備 GENERAL 寫入權 |
| update_reminder | appointment_service | 編輯掛號表單 | PUT `/api/appointments/reminders/{reminder_id}` | `Header: Authorization (Bearer Token)`, `Path: reminder_id: str`, `Body: UpdateAppointmentReminderRequest（部分更新）` | `AppointmentReminderResponse` | 部分更新掛號提醒：未帶的欄位不動，帶 null 的欄位清空。修改門診時間會重置狀態並重新排定推播；已到診或已取消的掛號不可改時間 |
| delete_reminder | appointment_service | 刪除這筆紀錄按鈕 | DELETE `/api/appointments/reminders/{reminder_id}` | `Header: Authorization (Bearer Token)`, `Path: reminder_id: str` | `{ ok: bool }` | 刪除單筆掛號提醒，尚未發出的推播一併停止 |
| delete_past_reminders | appointment_service | 刪除全部歷史紀錄按鈕 | DELETE `/api/appointments/reminders` | `Header: Authorization (Bearer Token)`, `Query: scope: "past"（必填）, target_user_id?: str（僅可為本人）` | `{ deleted: int }` | 一次刪除本人所有過去（當日已結束或已取消）的掛號紀錄，即將到來的門診不受影響。僅限本人操作 |
| depart | appointment_service | 「我已出發」按鈕（LIFF / LINE 卡片） | POST `/api/appointments/reminders/{reminder_id}/depart` | `Header: Authorization (Bearer Token)`, `Path: reminder_id: str` | `AppointmentReminderResponse` | 回報已出發（scheduled → departed），僅限門診當天。本人或具 GENERAL 寫入權的家屬可代按，重複按冪等 |
| attend | appointment_service | 「我已到診」按鈕（LIFF / LINE 卡片） | POST `/api/appointments/reminders/{reminder_id}/attend` | `Header: Authorization (Bearer Token)`, `Path: reminder_id: str` | `AppointmentReminderResponse` | 回報已到診（scheduled／departed → attended），並停止該次門診所有後續推播。僅限門診當天，重複按冪等 |
| cancel | appointment_service | 取消這次門診按鈕 | POST `/api/appointments/reminders/{reminder_id}/cancel` | `Header: Authorization (Bearer Token)`, `Path: reminder_id: str` | `AppointmentReminderResponse` | 取消門診（scheduled／departed → cancelled）：保留紀錄、停止所有推播、不發通知。不限門診當天，重複按冪等 |

## 掛號提醒管理相關 
# vite前端介面

## 登入相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| LIFF 登入 | CARE 後端 | LIFF 前端 | POST `/api/auth/liff/login` | `Body: { id_token: str }`（LIFF ID Token），不需驗證 | `{ access_token, token_type, expires_in, line_user_id }` | 以 LIFF ID Token 換取後端存取憑證 | 非 2xx：拋出「LIFF 後端登入失敗：{status}」 |

## 個人資料相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 更新個人健康資料 | CARE 後端 | LIFF 前端 | PUT `/api/profiles/me/update` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)`, `Body: UpsertPersonalHealthPayload (name, gender, height, weight, age, chronic_history, major_illness_history, surgery_history, health_consultations)` | 後端回傳 JSON | 新增或更新本人的個人健康資料 | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「個人資料儲存失敗：{status} - {text?}」 |
| 取得個人健康資料 | CARE 後端 | LIFF 前端 | GET `/api/profiles/me/` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | 後端回傳 JSON | 取得本人的個人健康資料 | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「取得個人資料失敗：{status} - {text?}」 |

## 家庭功能相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 取得族譜 | CARE 後端 | LIFF 前端 | GET `/api/family-tree/me` | `Query: user_id: str`（目前前端未附帶 Bearer Token） | `GetFamilyTreeResponse` | 取得使用者的族譜 | 非 2xx：拋出「取得族譜失敗：{status}」 |
| 建立家庭邀請 | CARE 後端 | LIFF 前端 | POST `/api/family-tree/invite` | `Body: { inviter_id: str }`（目前前端未附帶 Bearer Token） | `SendInvitationResponse` | 建立邀請家人加入族譜的邀請 | 非 2xx：拋出「建立邀請失敗：{status}」 |

## 摘要相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 取得所有諮詢摘要 | CARE 後端 | LIFF 前端 | GET `/api/consultations/me/allsummaries` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | 後端回傳 JSON | 取得本人所有的諮詢摘要 | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「取得諮詢摘要清單失敗：${res.status}」 |
| 取得摘要下載 Token | CARE 後端 | LIFF 前端 | GET `/api/consultations/me/summary/downloadtoken` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | JWT token | 取得下載諮詢摘要所需的 token | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「取得摘要下載token失敗：${res.status}」 |
| 下載諮詢摘要 | CARE 後端 | LIFF 前端 | GET `/api/consultations/me/summary/download` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)`, `Query: downloadToken: str` | JWT token | 以下載 token 下載諮詢摘要 | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「取得摘要下載token失敗：${res.status}」 |
| 取得我的諮詢紀錄 | CARE 後端 | LIFF 前端 | GET `/api/consultations/me/messages/raw` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | 後端回傳 JSON | 取得本人的原始對話訊息 | 無 token：拋出「缺少登入憑證，請先重新登入」；非 2xx：拋出「取得原始對話訊息失敗：${res.status}」 |
| 產生諮詢摘要 | CARE 後端 | LIFF 前端 | POST `/api/consultations/me/summary/generate` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | 後端回傳 JSON | 產生本人的諮詢摘要 | 無 token：拋出「缺少登入憑證，請先重新登入」；422：日期格式不合法；429：AI 額度已達上限，請稍後再試；502：AI 服務異常；其他非 2xx：拋出「產生諮詢摘要失敗：${res.status}」 |
## 掛號提醒相關


| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 查詢掛號提醒清單 | CARE 後端 | LIFF 前端 | GET `/api/appointments/reminders` | `Query: scope（upcoming 或 past）, target_user_id?（查家人時才帶）`；scope=past 時另帶 `limit=20, cursor?（上一頁的 next_cursor）` | `{ items: AppointmentReminder[], next_cursor: str \| null, total_count: int }` | upcoming：沒有取消且當日還沒結束的門診，由早到晚、不分頁；past：當日已結束或已取消的門診，由新到舊、一頁 20 筆；total_count 是整個分區的筆數 | 共通處理；400：分頁位置無效；403：沒有讀取權；「載入更多」失敗只以提示告知，已載入的紀錄保留 |
| 新增掛號提醒 | CARE 後端 | LIFF 前端 | POST `/api/appointments/reminders` | `Body: { user_id, appointment_at, facility_id?, hospital_name, hospital_address?, hospital_phone?, department, doctor_name?, serial_number?, note? }` | `AppointmentReminder` | 為本人或家人建立一筆掛號提醒，後端排定門診前 1 小時、門診時間、門診後 30 分鐘三則推播 | 共通處理；400：時間已過、缺 offset、欄位過長；403：替家人建立但沒有寫入權；409：同一時間已有一筆未取消的掛號（前端重抓清單） |
| 修改掛號提醒 | CARE 後端 | LIFF 前端 | PUT `/api/appointments/reminders/{reminder_id}` | `Body: UpdateAppointmentRequest`（只帶有變動的欄位；沒帶＝不動、帶 null＝清空） | `AppointmentReminder` | 修改一筆掛號；改了門診時間會重新排定推播。已到診的前端只開放修改備註 | 共通處理；400：時間已過、欄位不合法；403；404：已被刪除；409：已到診或已取消的改時間、改到已被佔用的時間 |
| 刪除這筆紀錄 | CARE 後端 | LIFF 前端 | DELETE `/api/appointments/reminders/{reminder_id}` | 無 | `{ ok: true }` | 整筆刪除，無法復原 | 共通處理；403；404：已被刪除（前端重抓清單） |
| 刪除全部歷史紀錄 | CARE 後端 | LIFF 前端 | DELETE `/api/appointments/reminders?scope=past` | `Query: scope=past`（不帶 target_user_id，只刪本人的） | `{ deleted: int }` | 一次刪除本人所有「過去」的紀錄（當日已結束或已取消），即將到來的不受影響；只有本人可以操作 | 共通處理；400：scope 不是 past；403：帶了別人的 id（前端不會帶）；後端不是交易，失敗時可能刪到一半，前端一律重抓清單，重送也安全 |
| 回報已出發 | CARE 後端 | LIFF 前端 | POST `/api/appointments/reminders/{reminder_id}/depart` | 無 Body | `AppointmentReminder` | 本人或有寫入權的家屬代按，與 LINE 卡片上的按鈕是同一個後端方法；重複按回 200 並保留第一位回報者 | 共通處理；403：沒有寫入權；404；409：不是門診當天、當天已結束、已取消（前端重抓清單） |
| 回報已到診 | CARE 後端 | LIFF 前端 | POST `/api/appointments/reminders/{reminder_id}/attend` | 無 Body | `AppointmentReminder` | 回報到診後，這次門診還沒發的推播全部停止；重複按回 200 | 共通處理；403；404；409：不是門診當天、當天已結束、已取消（前端重抓清單） |
| 取消這次門診 | CARE 後端 | LIFF 前端 | POST `/api/appointments/reminders/{reminder_id}/cancel` | 無 Body | `AppointmentReminder`（status 為 cancelled、notify_at 為空陣列） | 保留紀錄、停止所有推播、不發任何通知；取消後移到「過去的門診」；重複按回 200 並保留第一位取消者 | 共通處理；403：沒有寫入權；404；409：已到診、當天已結束（前端重抓清單） |

## 醫療院所相關
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 依 id 查詢院所 | CARE 後端 | LIFF 前端 | GET `/api/medical/facilities/{facility_id}` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | `MedicalFacility`（`distance_meters` 一律 null） | 編輯掛號、再掛一次、點選常去的醫院時，依 facility_id 取回科別清單與門診時段 | 401：導向登入頁；503：拋出「醫療院所查詢暫時不可用，請稍後再試」；其他非 2xx：拋出「查詢院所失敗：{status}」。前端不重試，只當作這次查不到、不顯示門診時段 |

## 家庭功能相關（既有介面新增欄位）
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 | 錯誤處理 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- | -------- |
| 取得族譜（新增嚴格權限欄位） | CARE 後端 | LIFF 前端 | GET `/api/family/me` | `Header: Authorization (Bearer Token，取自 CARE_AUTH_TOKEN)` | `GetFamilyTreeResponse`；`family_members[]` 新增 `my_strict_permissions: { general, sensitive, private }`，形狀與 `my_permissions` 相同 | 純角色權限（含委任），不受影響模式影響。前端只用它判斷掛號的新增、修改、取消、刪除與回報按鈕要不要顯示；其他功能仍看 `my_permissions` | 沿用既有處理；欄位缺席時一律視為沒有權限（不顯示掛號寫入按鈕） |
 
    
# n8n workflow相關介面
## 多媒體處理
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| multimediaProcessWebhook | n8n workflow | CARE Backend / Postman / 外部 client | POST `/webhook/multimedia-process` | multipart `file` | 文字內容或錯誤 JSON | n8n 對外入口，接收音訊、影片、圖片、文件，依副檔名分流處理 |
| geminiImageAnalyze | Google Gemini node | n8n workflow | n8n credential / Gemini API | binary `file`, OCR prompt | `content.parts[0].text` | 圖片 OCR，要求 Gemini 回傳 JSON 格式文字辨識結果 |
| n8nListWorkflows | n8n Admin API | 開發者 / Postman | GET `/api/v1/workflows` | API key / n8n auth | workflows list | 查詢 n8n workflows 清單 |
| n8nGetWorkflowDetails | n8n Admin API | 開發者 / Postman | GET `/api/v1/workflows/{workflow_id}` | `workflow_id`, API key / n8n auth | workflow detail | 查詢指定 workflow 詳細設定 |
| n8nListWorkflowExecutions | n8n Admin API | 開發者 / Postman | GET `/api/v1/workflows/{workflow_id}/executions` | `workflow_id`, API key / n8n auth | execution list | 查詢指定 workflow 的執行紀錄 |     
## ASR功能
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |    
| asrTranscribe | local-asr | n8n `HTTP Request` node | POST `http://local-asr:8200/transcribe` | multipart `file`, optional `language`, `task` | `text`, `language`, `duration`, `segments`, `model`, `backend` | 音訊/影片檔轉文字；短音訊可走 Breeze，長音訊或指定時走 faster-whisper |
| asrHealth | local-asr | 開發者 / health check | GET `http://localhost:8200/health` | 無 | `ok`, `backend`, `model`, `long_audio_backend`, `long_audio_threshold_seconds` | 檢查 ASR 服務狀態與目前模型設定 |
## 文件解析
| 介面名稱 | 介面提供者 | 介面使用者 | 連結方式 | 輸入資料 | 輸出資料 | 介面描述 |
| -------- | ---------- | ---------- | -------- | -------- | -------- | -------- |
| parserParse | local-parser | n8n `HTTP Request` node | POST `http://local-parser:8100/parse` | multipart `file`, optional `include_metadata`, `source` | `filename`, `text`, `char_count`, optional `metadata` | 解析文件類檔案文字內容 |
| parserHealth | local-parser | 開發者 / health check | GET `http://localhost:8100/health` | 無 | `ok` | 檢查 Parser 服務是否存活 |
| parserSupportedTypes | local-parser | 開發者 / client | GET `http://localhost:8100/supported-types` | 無 | `extensions` | 查詢 Parser 支援的副檔名 |
   
    
    
## <span id="section3">3. 流程設計 (Process Design)</span>
### 使用者流程

#### 登入流程
   ![login](https://hackmd.io/_uploads/BycuI35yzx.png)

    
#### 醫院資源定位流程
![GPS_Search_Activity.drawio](https://hackmd.io/_uploads/Syv0F71K-g.png =450x)

#### 協助掛號流程
![Hospital_Register_Activity.drawio](https://hackmd.io/_uploads/H1mkqQktbl.png =450x)

#### 多媒體資訊處理流程
![Multimedia_Preprocess_Activity.drawio](https://hackmd.io/_uploads/r1N3MZ9P-x.png =450x)

#### 事實查核與RAG流程
![rag_knowledge_build.drawio](https://hackmd.io/_uploads/SylZ5X1YWe.png =450x)

#### 台語語音辨識與生成流程
![Taiwanese_Speech_Medical_Flow.drawio](https://hackmd.io/_uploads/HkPE5QJY-g.png =450x)

#### MCP Server管理不同任務之流程
```mermaid
flowchart TD
  Client[Client / CARE Backend / Postman] -->|POST /webhook/multimedia-process<br/>multipart file| N8N[n8n]

  subgraph Docker Compose
    N8N --> Workflow[Multimedia Process Workflow]
    ASR[local-asr<br/>FastAPI :8200]
    Parser[local-parser<br/>FastAPI :8100]
  end

  Workflow --> Extract[Code<br/>解析檔名與副檔名]
  Extract --> Switch{Switch<br/>依副檔名分類}

  Switch -->|mp3 / wav / m4a / flac / ogg / opus| ASRReq[HTTP Request<br/>POST local-asr:8200/transcribe]
  Switch -->|mp4 / mov / avi / mkv / webm| ASRReq

  Switch -->|jpg / jpeg / png / gif / bmp / tiff / webp / svg| Gemini[Gemini Image Analyze<br/>OCR]
  Gemini --> ParseOCR[Code<br/>整理 OCR JSON]

  Switch -->|txt / md / csv / json / pdf / docx / xlsx / pptx / html / htm| ParserReq[HTTP Request<br/>POST local-parser:8100/parse]

  Switch -->|其他格式| Unsupported[Respond 415<br/>UNSUPPORTED_FILE_TYPE]

  ASRReq --> Respond[Respond to Webhook<br/>回傳 text]
  ParseOCR --> Respond
  ParserReq --> Respond
```
#### ASR 台語處理流程
```mermaid
flowchart TD
  Req[POST /transcribe] --> Duration[ffprobe 取得音訊長度]
  Duration --> Decision{ASR_BACKEND == faster-whisper<br/>或音訊長度 > threshold?}

  Decision -->|是| FW[faster-whisper<br/>model: WHISPER_MODEL]
  Decision -->|否| Breeze[Breeze ASR<br/>model: ASR_MODEL_ID]

  FW --> Result[回傳 text / segments / backend / model]
  Breeze --> Result
```
    
#### 使用者對話紀錄儲存流程:
![User Interaction History-2026-06-16-133002](https://hackmd.io/_uploads/ByJeWRAbGg.png)

#### 使用者摘要產生流程:
![MOHW CDC TFDA RAG Platform-2026-06-16-133007](https://hackmd.io/_uploads/B1AAbR0Zfg.png)

#### medical service主流程
    
```mermaid
flowchart TD
    Start(["使用者發送訊息"]) --> CheckMsgType{"訊息類型"}

    CheckMsgType -->|文字訊息| TextHandler["LineMessageHandler"]
    CheckMsgType -->|GPS 位置| LocationHandler["LineLocationHandler"]
    CheckMsgType -->|查看詳情| PostbackHandler["LineFacilityDetailHandler"]

    TextHandler --> Agent["AI Agent / LangGraph"]
    LocationHandler --> SaveLoc["儲存使用者位置"]
    SaveLoc --> Agent

    Agent --> ToolDecision{"AI 判斷意圖"}
    ToolDecision -->|院所名稱| LookupMedicalFacility["lookup_medical_facility"]
    ToolDecision -->|附近院所| FindNearbyHospital["find_nearby_hospitals"]
    ToolDecision -->|附近＋科別| ToolDept["findearby_facilities_by_department"]
    ToolDecision -->|需要位置| ToolReqLoc["要求使用者分享位置"]
    PostbackHandler --> Detail["取得院所詳細資料"]
```
     
#### lookup_medical_facility流程 
    
```mermaid
    flowchart TD

    ToolLookup["ToolLookup"] --> NameQuery["名稱關鍵字處理"]
    NameQuery --> Regex["模糊條件篩選"]
    Regex --> Search50k["50km 內搜尋"]

    Search50k --> HasResult{"有結果？"}
    HasResult -->|有| Sort["名稱相似度＋距離排序"]
    HasResult -->|無| Nationwide["放寬至全國搜尋"]
    Nationwide --> Sort

    Sort --> NameCount{"結果數量"}
    NameCount -->|0| NoName["查無此院所"]
    NameCount -->|1| Detail["單一院所詳情"]
    NameCount -->|多筆| Carousel["院所列表"]
```
    
#### 醫療院所名稱搜尋(lookup_medical_facility中的"模糊條件篩選"節點)流程:
    
```mermaid
flowchart TB
        InKeyword["輸入搜尋關鍵字"]
        DetectCity["偵測地區前綴"]
        CheckCity{"是否包含地區？"}
        SetCity["分離地區與名稱"]
        KeepKeyword["保留原始關鍵字"]
        CheckGeneric{"是否為地區＋純類別？"}
        ClearName["改以地區＋類別搜尋"]
        Normalize["名稱正規化"]
        Alias["醫院別名比對"]
        CheckAlias{"找到常用別名(如台大、奇美)？"}
        UseAlias["使用對應正式名稱"]
        UseNormalized["使用正規化名稱"]
        BuildQuery["建立搜尋條件"]
        Search["交由 MongoDB 搜尋"]
        InKeyword --> DetectCity
        DetectCity --> CheckCity
    
        CheckCity -->|有| SetCity
        CheckCity -->|無| KeepKeyword

        SetCity --> CheckGeneric
        CheckGeneric -->|是| ClearName
        CheckGeneric -->|否| Normalize

        KeepKeyword --> Normalize
        ClearName --> BuildQuery

        Normalize --> Alias
        Alias --> CheckAlias

        CheckAlias -->|有| UseAlias
        CheckAlias -->|無| UseNormalized

        UseAlias --> BuildQuery
        UseNormalized --> BuildQuery
        BuildQuery --> Search

```
並針對常見院所(台大、奇美、馬偕醫院...)與離島地區僅有醫院、衛生所做特別的對照表，確保常見的大醫院不會因為簡稱而沒有被搜尋到、離島雖然較缺少醫療院所但仍可以搜尋到
    
#### find_nearby_hospitals流程
    
```mermaid
flowchart TD
    ToolNearby["搜尋附近醫療院所"] --> ResolveType["院所類型解析 (醫院 / 診所 / 藥局)"]

    ResolveType --> TypeValid{"類型解析成功？"}
    TypeValid -->|否| TypeFail["回傳無法解析類型提示"]
    TypeValid -->|是/未指定| OpenNow{"是否要求看診中？"}

    OpenNow -->|是| FilterOpen["篩選看診狀態與急診院所"]
    OpenNow -->|否| ResolveTier["決定搜尋距離 (5km ➔ 50km)"]

    FilterOpen --> HasOpen{"有開診院所？"}
    HasOpen -->|有| ResolveTier
    HasOpen -->|無| Fallback["退回一般結果 (標註目前均未開診)"]

    Fallback --> ResolveTier
    ResolveTier --> NearbyCount{"是否有結果？"}

    NearbyCount -->|無| CheckPharmacy{"是否為藥局？"}
    CheckPharmacy -->|是| PharmacyNone["回傳查無附近藥局提示"]
    CheckPharmacy -->|否| FacilityNone["回傳查無附近醫療院所"]

    NearbyCount -->|有| NearbyCarousel["生成附近院所列表卡片 (含距離與看診狀態)"]

```
    
#### findearby_facilities_by_department流程
    
```mermaid
flowchart TD
    ToolDept["ToolDept"] --> Dept["科別解析"]
    Dept --> Combine["科別＋院所類型條件"]
    Combine --> OpenNow{"是否要求看診中？"}
    OpenNow -->|是| FilterOpen["篩選看診狀態"]
    OpenNow -->|否| ResolveTier["決定搜尋距離"]

    FilterOpen --> HasOpen{"有開診院所？"}
    HasOpen -->|有| ResolveTier
    HasOpen -->|無| Fallback["退回一般結果"]

    Fallback --> ResolveTier
    ResolveTier --> NearbyCount{"是否有結果？"}

    NearbyCount -->|無| NoNearby["查無附近醫療院所"]
    NearbyCount -->|有| NearbyCarousel["附近院所列表"]
```
    
```mermaid
flowchart TD
    U["使用者訊息：我肚子痛要掛哪一科"] --> EMG{"是否判定為緊急？"}
    EMG -->|是| EMCARD["回傳紅色緊急Flex Message"]
    EMG -->|否| AGENT{"是否詢問就診科別？"}
    AGENT -->|否| RAG["衛教回答（RAG）"]
    
    AGENT -->|是| vector["向量比對，分數居中時由 LLM 決選"]
    vector -->NORM{"是否比對到對照表症狀條目？"}
    NORM -->|否| FB["保底建議<br/>家醫科、內科、不分科"]
    NORM -->|是| BROAD{"候選科別是否超過 5 個？"}
    BROAD -->|是| FB
    BROAD -->|否| PED["成人移除兒科候選"]
    PED --> LEFT{"是否仍有候選科別？"}
    LEFT -->|否| FB
    LEFT -->|是| SUG["建議卡<br/>候選科別與醫院來源標註"]
    SUG --> REPLY["LINE 回覆與「搜尋附近」按鈕"]
    FB --> REPLY

```
    

#### 家庭功能邀請者流程 (Sender Journey)
```mermaid
flowchart TD
    A([Family 頁面]) --> B[點擊邀請按鈕]
    B --> C[按鈕變 Loading]
    C --> D["POST /family-tree/invites\n(後端從 JWT 辨識人)"]
    D -->|失敗| F["Toast 顯示錯誤訊息(3秒消失)"]
    D -->|成功| E["取得 invite_token組合 URL: /join?code=..."]
    E --> G["LIFF shareTargetPicker發送 Flex Message"]
    G -->|成功| H["Toast: 邀請已送出！"]
    G -->|取消| I([結束])
    F --> I
    H --> I
```

#### 家庭功能被邀請者流程 (Receiver Journey)
```mermaid
flowchart TD
    A([點擊 LINE 邀請連結]) --> B{是否已登入?}
    
    B -->|否| C["saveRedirectUrl(當前網址)存入 sessionStorage"]
    C --> D[導向 /login]
    D --> E[登入成功]
    E --> F["consumeRedirectUrl()導向回 /join?code=..."]
    
    B -->|是| G["GET /family-tree/invites/verify/{code}"]
    F --> G
    
    G -->|200 成功| H["顯示預覽卡片『XXX 邀請您加入家族』"]
    G -->|410 已失效/過期| I["頁面顯示『連結已失效』+ 回首頁按鈕"]
    G -->|404 不存在| I
    
    H -->|點擊「確認加入」| J["POST /family-tree/invites/accept"]
    H -->|取消| K([導向首頁])
    
    J -->|joined| L["顯示成功，1.5秒後跳轉 /family"]
    J -->|already_member| M["頁面顯示『已是家族成員』+ 回首頁按鈕"]
    J -->|失敗| N[Toast 顯示錯誤]
    
    L --> K
    M --> K
```
    
#### 用藥提醒與通報流程
```mermaid
flowchart TD
    A([到達服藥預定時間 T+0min]) --> B[查詢生效中的用藥提醒設定]
    B --> C[建立單日用藥日誌]
    C --> D[push_flex 推播首刷用藥提醒卡片]
    D --> E{用藥者是否點擊按鈕?}
    
    E -->|是| F[Webhook 接收 postback]
    F --> G[更新狀態為已用藥 taken]
    G --> H[reply_flex 替換卡片為已完成用藥停用狀態]
    
    E -->|否 逾時20分鐘| I[T+20min push_flex 推播溫馨催促卡片]
    I --> J{用藥者是否點擊按鈕?}
    
    J -->|是| F
    J -->|否 逾時30分鐘| K[T+30min push_flex 推播家屬關心提醒卡片]
    K --> L[更新日誌狀態為逾時未用藥 missed]
```
#### 掛號提醒流程
```mermaid
flowchart TD
    A["新增掛號"]
    R["再掛一次或改約<br/>帶入醫院、科別、醫師"]
    S1["選擇醫院"]
    S2["選擇科別與時間"]
    B{"同一時間是否已有掛號？"}
    S3["填寫醫師、看診號、備註"]
    S4["確認"]
    C["已排定"]
    D{"門診前是否變更？"}
    D2{"變更類型"}
    X["已取消<br/>停止推播，不發送通知"]
    DEL["刪除紀錄"]
    P["過去的門診"]
    NEXT["進入提醒流程"]

    A --> S1 --> S2
    R --> S2
    S2 --> B
    B -- 是 --> S2
    B -- 否 --> S3 --> S4 --> C
    C --> D
    D -- 否 --> NEXT
    D -- 是 --> D2
    D2 -- 修改時間 --> C
    D2 -- 取消門診 --> X --> P
    D2 -- 刪除紀錄 --> DEL

```
#### 掛號通報流程    
```mermaid
flowchart TD
    C["已排定"]
    E["門診前 1 小時<br/>推播提醒本人與家屬"]
    F{"是否回報出發？"}
    G["已出發"]
    H["門診時間<br/>推播提醒本人與家屬"]
    I{"是否回報到診？"}
    K["門診後 30 分鐘<br/>推播通知家屬"]
    L{"當日結束前是否回報到診？"}
    J["已到診<br/>停止後續推播"]
    M["未到診"]
    N["需要處理<br/>門診後 7 日內置頂顯示"]
    R["改約<br/>進入建立流程"]
    DEL["刪除紀錄"]
    P["過去的門診"]

    C --> E --> F
    F -- 是 --> G --> H
    F -- 否 --> H
    H --> I
    I -- 是 --> J
    I -- 否 --> K --> L
    L -- 是 --> J
    L -- 否 --> M --> N
    N -- 改約 --> R
    N -- 刪除 --> DEL
    N -- 超過 7 日 --> P
    J --> P
   
```
    
#### 危險、緊急情況警示流程圖    
```mermaid
flowchart TD
    U["使用者傳送訊息"] --> LLM["LLM 急迫度判斷"]
    LLM --> T{"是否在 4 秒內成功回傳？"}
    T -->|否| AGENT["進入一般 Agent 流程"]
    T -->|是| H{"是否正在發生？<br/>happening_now"}
    H -->|否| AGENT["進入一般 Agent 流程"]
    H -->|是| C{"是否需要立即處置？<br/>needs_immediate_care"}
    C -->|否| AGENT["進入一般 Agent 流程"]
    C -->|是| YES["判定為緊急與產生判定原因"]

    YES --> RED["略過 Agent，產生紅色緊急Flex Message"]
    RED --> REPLY["回覆當事人紅卡"]
    RED -.-> REC["背景查詢家屬收件人"]
    REC --> R1{"是否有合格收件人？"}
    R1 -->|否| STOP["不通報家屬"]
    R1 -->|是| PREF{"收件人是否開啟家人通知？"}
    PREF -->|否| SKIP["略過該收件人"]
    PREF -->|是| FLEX{"家屬通報卡是否推播成功？"}
    FLEX -->|否| TEXT["改以純文字推播"]
    

```
---
    
### 資料庫建置與更新流程
    
#### 醫療院所資料庫建置流程
    
```mermaid
graph TD
    %% 定義節點樣式
    classDef source fill:#e3f2fd,stroke:#1e88e5,stroke-width:2px;
    classDef process fill:#fff3e0,stroke:#fb8c00,stroke-width:2px;
    classDef clean fill:#e8f5e9,stroke:#43a047,stroke-width:2px;
    classDef ai fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
    classDef db fill:#ffebee,stroke:#e53935,stroke-width:2px;
    classDef trigger fill:#eceff1,stroke:#546e7a,stroke-width:2px,stroke-dasharray: 5 5;

    %% 觸發機制
    Trigger((排程觸發<br/>GitHub Actions<br/>每日 08:00)):::trigger --> Main(main_pipeline.py<br/>管線協調中心):::process

    %% 資料來源擷取
    Main --> API[scraper_api.py<br/>政府公開 JSON API]:::source
    Main --> TFC[scraper_tfc.py<br/>TFC 動態網頁爬蟲]:::source

    %% 資料清洗步驟 (utils.py)
    API --> CleanCore{utils.py<br/>資料洗淨中心}:::clean
    TFC --> CleanCore
    
    subgraph DataCleaning["核心清洗步驟 (Data Cleaning)"]
        CleanCore --> C1["1、正規表達式<br/>拔除 HTML 標籤"]:::clean
        C1 --> C2["2、特殊字元轉換<br/>處理引號與空白"]:::clean
        C2 --> C3["3、多餘空白壓縮<br/>連續換行轉單一空白"]:::clean
        C3 --> C4["4、HTML Unescape<br/>還原實體字元"]:::clean
    end

    %% 處理與向量化
    C4 --> Chunk[Text Chunking<br/>文字切片 500字/塊]:::process
    Chunk --> Gemini[Google Gemini API<br/>Text Embedding 模型]:::ai
    
    %% 狀態判斷與儲存
    Gemini --> DB[(MongoDB<br/>health_articles_chunks)]:::db
    
    %% 增量更新機制
    DB -.-> |比對 URL/標題| Check{是否已存在?}:::process
    Check -.->|是| Skip[Early Stopping<br/>提早結束該來源爬取]:::process
    Check -.->|否| Insert[寫入全新切片與 768維向量]:::db
```
    
## <span id="section4">4. 使用者畫面設計 (User Interface Design)</span>
### rich menu



### Flex Message設計
    
#### 分享位置並搜尋附近醫療院所

![767482754_921952094316419_6874145323855566474_n](https://hackmd.io/_uploads/rkMm3PtUMx.jpg)
![769412113_2864343973898599_3029382718876464699_n](https://hackmd.io/_uploads/rJM72wt8fl.jpg)


 
#### 搜尋到多筆醫療院所
列出至多3間院所的簡略資訊，包含院所名稱、地址、營業狀態、距離，並可點擊 "撥打電話"與"前往地圖"按鈕
    
![搜尋醫院候選清單](https://hackmd.io/_uploads/HJdEPvtLzg.jpg)
![搜尋醫院候選清單2](https://hackmd.io/_uploads/S1O4PDFLzl.jpg)

#### 搜尋單一醫療院所
顯示詳細門診時間與看診科別，其中門診時間使用深黃色背景突顯當天的看診時段，並用診所常見的門診表格式，讓高齡長輩一目了然。診療科別使用兩種顏色交替顯示，讓長輩方便閱讀並舒緩眼睛疲勞。    
![單一院所](https://hackmd.io/_uploads/Hy5XPwtIfl.jpg)
![單一院所2](https://hackmd.io/_uploads/r1qmDvFIMe.jpg)

#### 日常健康紀錄與趨勢（Iteration 7 規劃）

* 提供血壓、血糖及體重等健康指標的新增與歷史紀錄查詢。
* 趨勢畫面可選擇指標與日期範圍，並以圖表搭配數值清單呈現。
* 輸入欄位應顯示單位、合理範圍與格式錯誤提示，避免誤植數值。

#### 用藥提醒與藥袋辨識

* 用藥提醒以 LINE Flex Message 顯示藥名、預定時間及「已用藥」按鈕。
* 藥袋掃描支援拍照與圖片上傳，辨識結果須先由使用者確認，再進行風險評估。
* 用藥風險與注意事項應使用清楚的警示層級，並顯示「資訊僅供參考，應諮詢醫師或藥師」。

#### 每日健康資訊與分享（Iteration 7 規劃）

* 健康資訊卡片應顯示標題、摘要、來源名稱、原始連結及分享按鈕。
* 分享功能支援 LINE 聯絡人與已授權家庭成員，送出前須由使用者確認分享對象。

### 全域使用者體驗與無障礙設計

* 多國語言支援範圍包含介面文字、自然語言理解、文字回覆、語音辨識及語音生成，不得僅翻譯最終回答。
* 高齡友善介面應提供可調整字體、足夠的文字與背景對比、明確按鈕標示及精簡的操作步驟。
* 主要功能應可透過文字或語音自然語言操作，複雜選單僅作為替代操作方式。
* 台語互動應維持輸入辨識、回答內容及語音輸出的語言一致性。
---

## <span id="section5">5. 資料設計 (Data Design)</span>
### 5.1 檔案結構
* FastApi

* liff


### 5.2 資料結構與Schema
---
健康資訊Schema
| **欄位名稱 (Field)** | **型態 (Type)** | **說明 (Description)** | 
| ----- | ----- | ----- | 
| **`_id`** | `ObjectId` | MongoDB 自動生成的唯一識別碼，內含建立時間戳記，可用來反推最新資料。 | 
| **`source_name`** | `String` | 資料來源機構名稱（例：`"食藥署闢謠專區"`），方便未來提供 LLM 檢索時進行來源過濾。 | 
| **`url`** | `String / null` | 文章的原始網址。若來源未提供則為 `null`。未來在 LINE 回覆時可附上此連結以增加可信度。 | 
| **`original_title`** | `String` | 文章的完整原始標題。 | 
| **`chunk_content`** | `String` | 經過清洗與切片後的純文字內容。長度通常控制在 500 字以內，是 LLM 進行語意搜尋 (Semantic Search) 的核心依據。 | 
| **`chunk_index`** | `Integer` | 當前切片屬於原文章的第幾段（例如：`1`）。 | 
| **`total_chunks`** | `Integer` | 原文章總共被切成的段落數。若 `chunk_index == total_chunks` 代表為文章末段。 | 
| **`embedding`** | `Array[Float]` | 長度為 3072 的浮點數陣列。由 Gemini Embedding 模型轉換而成的向量特徵，用於向量資料庫比對。 | 
| **`uploaded_at`** | `Float` | 寫入 MongoDB 時的 Unix Timestamp（時間戳記），用於管理與追蹤資料更新進度。 |
    
醫療院所schema
| **欄位名稱 (Field)** | **型態 (Type)** | **說明 (Description)** |
| -------------------- | --------------- | ---------------------- |
| **`id`** | `String / null` | 院所唯一識別碼，作為primary key。 |
| **`name`** | `String` | 院所名稱。 |
| **`latitude`** | `Float` | 院所緯度座標。 |
| **`longitude`** | `Float` | 院所經度座標。 |
| **`address`** | `String` | 院所完整地址。 |
| **`phone`** | `String / null` | 院所聯絡電話。 |
| **`type`** | `String` | 院所類型，例如：`"醫院"`、`"診所"`、`"藥局"`。 |
| **`clinic_time`** | `Object / null` | 院所營業／門診時間。Key 為星期英文小寫（`monday ~ sunday`），Value 為 `ClinicDaySchedule`。 |
| **`clinic_time.<day>`** | `ClinicDaySchedule` | 單一天的營業／門診時間表。包含 `isClosed` 與 `slots`。 |
| **`ClinicDaySchedule.isClosed`** | `Boolean` | 當天是否公休。`true` 表示公休。 |
| **`ClinicDaySchedule.slots`** | `Array[ClinicTimeSlot]` | 當天的營業／門診時段清單，由一個或多個 `ClinicTimeSlot` 組成；公休時為空陣列。 |
| **`ClinicTimeSlot.open`** | `String` | 單一時段的開始時間，例如：`"08:00"`。 |
| **`ClinicTimeSlot.close`** | `String` | 單一時段的結束時間，例如：`"17:30"`。 |
| **`departments`** | `Array[String] / null` | 院所診療科別 |
| **`notes`** | `String / null` | 院所補充註記|
| **`distance_meters`** | `Float / null` | 院所距離使用者的直線距離（公尺），由 PostGIS 計算後填入。 |

家庭功能Schema
| 欄位名稱 (Field) | 資料型別 (Type) | 說明 (Description) | 範例值 (Example) |
| :--- | :--- | :--- | :--- |
| `_id` | ObjectId | 系統自動生成的唯一識別碼 | `ObjectId("6a0c2d68c8a4beb285bdba7f")` |
| `user_id` | String | 綁定的使用者 ID (如 LINE User ID) | `"U816f60cf1480bab4c9d30d46ce6474e4"` |
| `created_at` | Date | 資料建立的 UTC 時間 | `2026-05-19T09:29:12.126+00:00` |
| `family_members` | Array[Object] | 家庭成員的詳細資料陣列 | `[ { ... }, { ... } ]` |
| ↳ `[0]/[1]/[2]...` | Object | 成員的物件資料 (至多4個屬性) | {user_id:"Udb2c09a8f110ed32fc78ec9722ae1134 "relationship_type:null display_name:null picture_url:null}
| `updated_at` | Date | 資料最後更新的 UTC 時間 | `2026-07-29T13:43:02.460+00:00` |
***
    
## <span id="section6">6. 類別圖設計 (Class Diagram)</span>
#### CARE-data
```mermaid
classDiagram
    %% 定義模組 (Modules)
    class MainPipeline {
        <<Controller>>
        +chunk_text(text, chunk_size, overlap) List
        +get_embedding(text) List
        +upload_to_mongodb(articles, collection) Integer
        +job()
    }

    class Utils {
        <<Utility>>
        +clean_html(raw_html) String
    }

    class ScraperAPI {
        <<Module>>
        +get_api_articles(test_mode) List~Article~
    }

    class ScraperTFC {
        <<Module>>
        +get_tfc_articles(test_mode, start_page) List~Article~
    }

    %% 定義資料結構 (Data Schemas)
    class Article {
        <<Data Dictionary>>
        +title : String
        +content : String
        +url : String
        +source : String
    }

    class MongoDocument {
        <<Database Schema>>
        +_id : ObjectId
        +source_name : String
        +url : String
        +original_title : String
        +chunk_content : String
        +chunk_index : Integer
        +total_chunks : Integer
        +embedding : Array~Float~
        +uploaded_at : Float
    }

    %% 模組依賴關係 (Dependencies)
    MainPipeline --> ScraperAPI : 呼叫 (Call)
    MainPipeline --> ScraperTFC : 呼叫 (Call)
    ScraperAPI ..> Utils : 依賴 (Dependency)
    ScraperTFC ..> Utils : 依賴 (Dependency)
    
    %% 資料流動關係 (Data Flow)
    ScraperAPI ..> Article : 產出 (Yields)
    ScraperTFC ..> Article : 產出 (Yields)
    MainPipeline ..> Article : 接收 (Consumes)
    MainPipeline ..> MongoDocument : 轉換寫入 (Transforms to)

```
---

## <span id="section7">7. 實作方案 (Implementation Languages and Platforms)</span>


### 1.前端: LIFF(vite+React+Typescript)
---
#### 登入
* 用戶到達的第一個頁面
* 直接呼叫liff.init()跳轉到line帳號登入
* 登入成功後自動跳轉到首頁並向後端發送POST/liff/login
* 登入失敗會跳轉回登入頁
---
#### 首頁
* 顯示大部分供使用者使用的功能
---
#### 組件
* Header
* Footer
---
#### 個人健康
* 透過liff取得user頭像和LINE暱稱
* 透過CARE資料庫取得健康資料
* 提供血壓、血糖及體重紀錄的新增、查詢與趨勢圖表
---
#### 個人諮詢紀錄
* 可選擇摘要與對話顯示
* 摘要會取得mongoDB中該user每一筆摘要，並提供下拉式選單可供瀏覽
* 儲存對話紀錄(JSON)，點擊按鈕後前往外部連結並下載
---
#### 設定頁面
* 調整個人偏好設定（語言、字體大小）
* 設定每日健康資訊的主題、推播時間與啟用狀態
---
#### 家庭介面
* 顯示有建立關係的成員及其健康狀態
* 掛號提醒
* 同一家庭群組的成員可以點擊成員卡片互相查看對話紀錄與摘要
* 健康資訊分享須依 GENERAL、SENSITIVE、PRIVATE 權限控制可見範圍
* 防走失定位須由家屬提出請求，並取得受照護者的明確同意；位置資料採限時授權

#### 用藥安全
* 上傳或拍攝藥袋圖片，顯示 OCR 原始文字及結構化藥品資訊
* 使用者確認辨識內容後，才進行用藥注意事項與風險評估
* 風險結果附上資料來源與就醫／諮詢藥師提醒，不作為診斷或處方依據
---
### 2.後端(FastApi)
---
#### 驗證
* 收到前端發送POST/liff/login後返回TOKEN
* 使用JWT驗證
---
#### 使用者
* ID使用LINE ID
* 取得、更新資料需要驗證
* 健康指標紀錄依使用者 ID 儲存，家庭成員代填或查詢時須驗證 SENSITIVE 權限
---
#### 家庭功能
* 建立關係
  * 邀請者建立連結並發送給被邀請者
  * 被邀請者點擊連結與邀請者建立關係

| 角色 | GENERAL | SENSITIVE | PRIVATE |
|---|---|---|---|
| `OWNER` | 讀 + 寫 | 讀 + 寫 | 讀 + 寫 |
| `GUARDIAN` | 讀 + 寫 | 讀 + 寫 | 讀 |
| `CAREGIVER` | 讀 + 寫 | 讀 | — |
| `MEMBER` | 讀 | — | — |
    
* 資訊定義
    
| 分類 | 資源 | 實際欄位 |
|---|---|---|
| `GENERAL` | 用藥提醒、藥品、身分欄位 | 吃藥時間、藥名、外觀、劑量、`name`、`picture_url` |
| `SENSITIVE` | 健康檔案、藥品適應症 | 年齡、性別、身高體重、慢性病、重大疾病史、手術史、`indication` |
| `PRIVATE` | 對話摘要、原始對話 | 與 LINE 機器人的健康諮詢內容 |
    
[技術文件](https://hackmd.io/@NTOU-CARE/S11OiCwdMl)   
    
---
#### 多媒體處理
* 音檔、影片檔(local-asr)
    * 目前使用 breeze asr 26 + faster_whisper 的 hybrid 模式
    * 30秒內使用 breeze asr 26，否則使用 faster_whisper
* 圖片
    * 目前使用Gemeni 2.5 faster
* 文件
    * 使用python完成
---
#### 對話紀錄
* 將對話紀錄存到redis，並建立一天的TTL
* redis端根據userId建立collection並儲存
* 不紀錄位置訊息
---
#### 產生摘要
* 使用scheduler搭配lifespan定時產生摘要
* 尋找當天的對話紀錄並傳給gemini產生摘要
* 摘要最多存20筆，新的摘要會將最舊的摘要擠掉
---
#### RAG
* 回覆內容應附上來源名稱與原始連結，供使用者追溯與查證
* 檢索結果不足或可信度未達門檻時，不生成推測性醫療回答，並明確告知資料不足
* 每日健康資訊僅可使用已納入可信知識庫且保留來源欄位的內容
---    
#### 台語
* 與 Taigi Ai Lab 合作，使用對方提供之 api key
---
### 3.資料庫
---
#### LIFF使用者資料
---    
#### 健康相關資料(vector database)
* 三大核心
    * ETL 模服務解耦：將即時 LINE Bot 與耗時的資料管線分開。
    * 雲端 Serverless 自動化：採用 GitHub Actions 每日定時爬蟲，零維護成本且保護實驗室 IP。
    * 智慧防護與增量更新：內建 Early Stopping 提早結束機制與 Rate-Limit Backoff 退避演算法，確保高穩定性。
---
#### 醫療院所資料
* 包含院所名稱、地址、電話、註記等等
* 目前將醫療院所包裝於flex message內
---
### 4. CI/CD
---
#### 測試
* 使用 Github action 做自動測試
    * 前端:playwright
    * 後端:pytest
    * CI:SonarQube Cloud
---
#### 部署
* 容器化部署
    * docker + Kubernetes k3s
* 反向代理
    * Traefik
* ArgoCD(待定)
---

    ## <span id="section8">8. 設計議題 (Design Issue)</span>
AI模型的記憶問題

### 議題1:資料表schema:
- 議題內容：如何建立高效率、合理、符合正規化的資料表
- 可能解決方案1：建立多個表格，如media_file、session_cache資料表參照users、clinic_time參照medical_facilities
- 可能解決方案2：將參照的資料表與被參照的合在一個大表格
- 最後解決方案與理由：方案2，一次取得所有資料，效率較高，且在目前測試階段較方便閱讀、維護

### 議題2:Service架構:
之前討論那個event handler、orchestrator等等，誰可以來補充一下

### 議題3:醫療院所結果提供的連結
- 議題內容：要連結到google map還是該院所網址
- 可能解決方案1：
- 可能解決方案2：
- 最後解決方案與理由：

### 議題4:後端部署方式
- 議題內容：決定fast api後端、liff、n8n等等的部署方式，簡化每次開啟測試流程與提升服務的穩定、可靠性
- 可能解決方案1：使用實驗室的VM、系上伺服器
- 可能解決方案2：維持原狀，在本機測試
- 可能解決方案3：部署到雲端(render、aws等等)
- 最後解決方案與理由：方案1，跟學長姐連絡後，學長姐提供實驗室電腦做為後端，並使用ssh、tigerVNC遠程操作，省去目前階段不斷開啟眾多服務並修改webhook url的麻煩。
