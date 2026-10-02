# CARE 2026 四項競賽投稿文件製作 Spec

## 1. 任務目標

根據 CARE 專案目前已有的設計文件、系統功能、技術架構與既有參賽資料，製作以下四項競賽所需要的投稿文件。

競賽：

1. 2026 全國智慧健康照護創新創業競賽
2. 智策AI：2026 AI創新實戰大賽
3. 第五屆青春靚點子學生創業挑戰賽
4. 2026 全國大專院校產學創新實作競賽

本任務不是重新設計 CARE，而是依照各競賽官方要求，將既有 CARE 內容重新選材、編排與撰寫。

---

# 2. CARE 專案定位

專案名稱：

**CARE – Clinical Assistance & Resource Engine**

CARE 是以 LINE 為主要入口的高齡友善健康與醫療資訊智慧助理。

主要使用者：

- 高齡者
- 家庭照顧者
- 不熟悉複雜數位服務的使用者
- 有多語言／台語互動需求的使用者

核心目標：

> 降低一般使用者，尤其是高齡者取得、理解及管理健康與醫療資訊的門檻，並透過 AI、RAG、多媒體處理與家庭帳號連結提供日常健康協助。

CARE 不應被描述成醫療診斷系統，也不可宣稱可以取代醫師或醫療專業人員。

---

# 3. 現有主要功能

撰寫文件時只能使用已經存在、正在開發或專案已有明確規劃的功能，不得自行發明功能。

## 3.1 AI 與 RAG

- LINE 多輪 AI 對話
- 上下文對話
- Retrieval-Augmented Generation
- 可信健康／醫療資訊來源
- AI 生成內容標示
- 資料不足時避免自行拼湊答案
- 回覆品質與幻覺抑制機制
- Golden QA
- Cosine Similarity
- LLM-as-a-Judge 等評估方法

## 3.2 多媒體與語音

- 圖片 OCR
- 藥袋文字辨識
- PDF / DOCX 等文件文字處理
- 語音辨識 ASR
- TTS 語音生成
- 多國語言
- 台語語音互動

台語流程概念：

使用者台語語音
→ ASR
→ 語言處理
→ RAG / 系統規則
→ 回覆生成
→ 台語 TTS

## 3.3 日常健康

撰寫競賽文件時須依下列狀態描述，不得將同一模組概括成全部完成：

| 功能 | 狀態 | 可使用的事實描述 |
|---|---|---|
| 血壓／血糖紀錄 | Implemented | 可新增、刪除並查詢歷史；GUARDIAN 可代記，CAREGIVER 只讀，MEMBER 無權；每筆保存實際記錄者與當時等級 |
| 使用者自訂提醒範圍 | Implemented | 系統不內建醫療門檻，由本人或 GUARDIAN 依專業建議設定血壓／血糖上下限 |
| 超出範圍警示 | Implemented，但部署開關預設關閉 | 等級照常判定與保存；開關啟用後通知本人及合格照顧者，具 6 小時補記限制與 30 分鐘節流 |
| 經期紀錄 | Implemented | 僅女性本人可操作，分類為 PERSONAL，任何家屬與受委任者均不可存取 |
| LIFF 前景計步 | Implemented | 使用者明確啟動後只在頁面前景估算，每 30 秒同步；不可描述成背景計步或醫療級穿戴裝置數據 |
| 體重時間序列 | Planned | 健康檔案有單一體重欄位，但尚無體重歷史 API，不得寫成已有體重紀錄趨勢 |
| 獨立趨勢圖／趨勢分析 | Planned | 現有畫面提供時間清單與歷史等級，不得宣稱已有獨立圖表或醫療趨勢分析 |
| 用藥提醒 | Implemented | 依設定時間提醒；一般逾時家屬通知與高風險用藥通知採各自政策 |
| 每日健康資訊 | Implemented | 啟用訂閱者於全域 Asia/Taipei 09:00 每日最多一則；目前不能由每位使用者自訂時間 |
| 一般衛教資訊分享 | Implemented | 可分享不含個人資料的健康／衛教內容及來源 |
| 個人健康資料主動分享 | Planned | 逐筆分享、期限、撤回與轉傳控制尚未完成 |

## 3.4 醫療資源與用藥安全

- 藥袋掃描
- 藥物資訊辨識
- 用藥風險提醒
- 健康資訊查詢
- 醫療資源查詢
- GPS 附近醫療資源
- 對話風險警示

## 3.5 家庭帳號

- 家庭帳號連結
- 權限管理
- 依 GENERAL／SENSITIVE／PRIVATE／PERSONAL 分類控制資料存取
- 家庭健康摘要：合格家屬可查看最新血壓、血糖等級與今日步數
- 個人健康資料主動分享仍為規劃功能，不得與既有家庭讀取權混為一談
- 用藥／健康提醒
- 防走失定位相關功能

## 3.6 使用者體驗

- LINE 作為主要入口
- 自然語言為主要操作方式
- 多國語言支援
- 語音互動
- 高齡友善介面
- 字體大小等高齡設定
- 台語支援

---

# 4. 現有技術架構

目前主要技術：

- FastAPI
- LINE Messaging API
- LIFF
- React
- TypeScript
- RAG
- Vector Database
- OCR
- ASR
- TTS
- Docker
- n8n

AI / 語音模型可能包含：

- Gemini
- TAIDE / Gemma-3-TAIDE-12B-Chat
- Breeze-ASR
- Taigi AI 相關 API

資料來源可能包含：

- 衛生福利部
- 疾病管制署
- 食藥署
- 台灣事實查核相關資料
- 官方衛教資料
- 藥品仿單
- 健保／醫療資源公開資料

若 Repository 或現有設計文件與本 Spec 不一致，以**最新專案文件及實際程式碼**為準。

健康紀錄功能應優先核對 SRD 0.6、[Iteration 7 健康紀錄模組技術文件](<./Iteration%207健康紀錄模組技術文件.md>)、SDD 1.3 與 family-rbac 的 Iteration 7 擴充；舊版文件中的「體重紀錄／趨勢圖已完成」不得繼續引用。

不得把「規劃中」功能寫成「已完成」。

---

# 5. 共通撰寫原則

四個競賽使用相同 CARE 專案，但不得直接複製同一份文件。

必須依照各競賽評審目的重新安排內容。

共同原則：

1. 不捏造數據。
2. 不捏造使用者測試結果。
3. 不捏造醫療成效。
4. 不捏造合作醫院、政府或企業。
5. 不捏造營收。
6. 不把規劃中的功能描述成已完成。
7. 無資料的地方使用 `[待補資料]`。
8. 技術名稱必須與 Repository / Design Document 一致。
9. 使用繁體中文。
10. 避免過度行銷與 AI 式浮誇文字。
11. 使用大學生專題團隊可以自然寫出的正式語氣。
12. 優先使用具體事實，而不是「革命性」、「顛覆性」、「領先業界」等形容詞。

---

# 6. Competition 01
# 全國智慧健康照護創新創業競賽

## 投稿定位

以：

**高齡健康照護產品**

作為主要定位。

預計參加：

**創業實作組**

## 核心敘事

問題：

高齡者在取得、理解及管理健康／醫療資訊時存在數位落差與資訊理解門檻。

↓

CARE：

利用使用者熟悉的 LINE 作為入口。

↓

提供：

AI 健康資訊查詢  
＋藥袋辨識  
＋用藥安全  
＋健康紀錄  
＋語音／台語  
＋家庭照護

↓

價值：

降低高齡使用者使用智慧健康服務的門檻。

## 文件重點

內容優先順序：

1. 健康照護問題
2. 使用者需求
3. CARE 解決方案
4. 使用流程
5. 產品功能
6. 高齡友善設計
7. 技術如何支持需求
8. 系統完成度
9. 社會價值
10. 市場與商業化可能性

技術架構不是主角。

不要把大量篇幅放在模型名稱。

## Output

建立：

`competitions/smart-health/`

至少包含：

`README.md`

說明：

- 官方競賽名稱
- 投稿組別
- 截止時間
- 官方要求
- 必交文件
- 頁數限制
- 評分方式
- 尚缺資料

以及：

`proposal.md`

依照官方格式建立完整投稿內容。

如果官方提供 Word / PDF 格式，內容章節必須完全遵照官方格式。

---

# 7. Competition 02
# 智策AI：2026 AI創新實戰大賽

## 投稿定位

CARE 在本競賽定位為：

**高齡健康照護場景的可信多模態 AI 助理系統**

## 核心重點

這場競賽必須突出 AI 技術。

主要呈現：

### RAG Pipeline

User Query

→ Query Processing

→ Retrieval

→ Trusted Knowledge Base

→ Context Construction

→ LLM

→ Response

→ Evaluation / Hallucination Control

### Multimodal Pipeline

文字  
圖片  
語音  
文件

↓

Input Processing

↓

OCR / ASR

↓

CARE AI

↓

RAG

↓

Response

↓

Text / TTS

### AI Reliability

說明：

- 可信資料來源
- Retrieval
- Evidence
- 回覆生成
- 資料不足處理
- AI 生成標示
- Golden QA
- Similarity
- LLM-as-a-Judge

## 文件重點

優先順序：

1. AI 技術與創新
2. AI Architecture
3. RAG
4. Multimodal AI
5. Reliability / Hallucination Control
6. 健康照護應用
7. 產業價值
8. 商用可能性

不要把它寫成一般 LINE Bot。

LINE 是 Interface，不是核心創新。

## Output

建立：

`competitions/ai-innovation/`

包含：

`README.md`

整理官方規則。

`team-and-motivation.md`

控制在官方要求的團隊介紹／參賽動機篇幅。

`proposal.md`

控制在官方要求的提案篇幅。

內容必須特別強調 AI 技術。

---

# 8. Competition 03
# 青春靚點子學生創業挑戰賽

## 投稿定位

CARE 在這場定位為：

**AI × 高齡健康科技新創服務**

## 核心問題

這份文件主要回答：

> CARE 如果成為產品，誰會使用？誰可能付費？為什麼市場需要它？

## Target User

主要：

- 高齡者
- 家庭照顧者

可能合作客戶：

- 長照機構
- 健康服務業者
- 醫療相關單位
- 政府／地方健康服務

以上合作對象若尚未合作，只能描述為「潛在市場／未來合作方向」。

不得寫成已有合作。

## Business Model

可以分析：

### B2C

家庭健康管理服務。

### B2B2C

與照護／健康服務機構合作，由機構提供給使用者。

### SaaS

提供健康照護相關組織 AI 助理能力。

### Government / Public Health

未來與地方政府、社區照護、公共健康服務合作。

以上屬商業模式假設，不得偽裝成現有營收模式。

## 文件重點

優先順序：

1. Problem
2. Target User
3. Solution
4. Value Proposition
5. Market
6. Competitive Advantage
7. Business Model
8. Go-to-Market
9. Team
10. Future Growth

技術只需要證明：

**我們做得到。**

不需要花大量篇幅介紹 FastAPI、Docker 或模型細節。

## Output

建立：

`competitions/startup-challenge/`

包含：

`README.md`

以及官方要求的所有報名文件草稿。

若需要 Pitch：

建立：

`pitch-outline.md`

內容包含：

1. Opening
2. Problem
3. User
4. Solution
5. Demo
6. Market
7. Business Model
8. Advantage
9. Team
10. Vision

---

# 9. Competition 04
# 全國大專院校產學創新實作競賽

## 投稿組別

**人工智慧及其應用組**

## 投稿定位

CARE 在這場應定位為：

**可實際運作的 AI 軟體工程專題**

核心不是創業，而是：

> 我們發現問題 → 設計系統 → 實作 → 測試 → 系統可以運作。

## 文件重點

優先順序：

1. Problem
2. System Requirements
3. System Architecture
4. AI Architecture
5. RAG
6. Multimodal Processing
7. Backend
8. LINE / LIFF
9. Database
10. Implementation
11. Demo
12. Evaluation
13. Results
14. Future Work

## 必須清楚區分

Implemented

與

Planned

功能。

## 建議加入圖

若已有資料，整理：

- System Architecture Diagram
- RAG Flow
- Multimodal Flow
- User Flow
- Deployment Architecture
- Screenshots

若不存在，不得自行假設。

使用：

`[待補架構圖]`

等 Placeholder。

## Output

建立：

`competitions/ncue-innovation/`

包含：

`README.md`

`abstract.md`

`project-description.md`

如果決賽需要海報，再建立：

`poster-outline.md`

---

# 10. 建立共用資料

建立：

`competitions/common/`

其中包含：

## `project-facts.md`

只記錄已確認的 CARE 事實。

例如：

- 專案名稱
- 團隊
- 指導教授
- 技術
- 功能
- 已完成功能
- 開發中功能
- 規劃功能
- 資料來源
- AI Models
- Deployment

四場比賽的內容都必須以這份資料為基準。

---

## `feature-status.md`

建立：

| Feature | Status | Evidence |
|---|---|---|
| LINE Bot | Implemented / Developing / Planned | |
| RAG | | |
| OCR | | |
| ASR | | |
| TTS | | |
| Medication | | |
| Blood Pressure / Glucose Record | | |
| User-defined Alert Threshold | | |
| Health Alert Notification | | |
| Menstrual Record (PERSONAL) | | |
| LIFF Foreground Step Count | | |
| Weight Time Series | | |
| Independent Trend Chart | | |
| Personal Health Data Sharing | | |
| Family Account | | |
| GPS | | |
| Multilingual | | |

Status 僅允許：

- Implemented
- Developing
- Planned
- Unknown

若無法從 Repository 或文件確認：

使用 `Unknown`。

---

## `competition-matrix.md`

建立四場競賽比較表：

| 項目 | 智慧健康 | AI實戰 | 青春靚點子 | 彰師大 |
|---|---|---|---|---|
| 定位 | 健康產品 | AI系統 | Startup | 工程專題 |
| Problem | | | | |
| AI | | | | |
| RAG | | | | |
| Healthcare | | | | |
| UX | | | | |
| Business | | | | |
| Implementation | | | | |

並標記各項內容的重要程度。

---

# 11. Agent 執行順序

請按照以下順序工作。

## Phase 1 — Competition Requirements

先閱讀四場官方網站及下載的官方簡章。

不要直接開始寫文章。

整理：

- Eligibility
- Deadline
- Required Documents
- Format
- Page Limit
- Evaluation Criteria
- Presentation Requirement
- Demo Requirement
- Required Signatures
- Required Attachments

輸出至各競賽 README。

---

## Phase 2 — CARE Audit

閱讀：

- README
- Design Document
- Repository
- API
- Existing competition documents
- Architecture documents

建立：

`common/project-facts.md`

與：

`common/feature-status.md`

---

## Phase 3 — Gap Analysis

比較：

Competition Requirement

vs.

Existing CARE Material

列出：

### 已有

可以直接使用的內容。

### 需要修改

已有但需要依競賽重新描述。

### 缺少

必須由團隊補充。

禁止自行補造缺少資料。

---

## Phase 4 — Draft

按照截止時間：

1. 青春靚點子
2. 智慧健康照護
3. AI 創新實戰
4. 彰師大產學創新

依序產生草稿。

---

## Phase 5 — Consistency Check

完成後檢查四份文件。

必須確保：

- CARE 定義一致
- 團隊資料一致
- 技術名稱一致
- 功能狀態一致
- 商業數據一致
- 系統架構一致

但：

**敘事角度不得完全相同。**

---

# 12. 禁止事項

Agent 不得：

- 自行創造市場數據
- 自行創造問卷結果
- 自行創造醫療成效
- 自行創造 Accuracy
- 自行創造使用人數
- 自行創造營收
- 自行創造合作單位
- 自行宣稱通過醫療認證
- 自行宣稱符合醫療器材法規
- 自行宣稱 AI 可以診斷疾病
- 將 Planned Feature 寫成 Implemented
- 為了讓文章好看而編造事實

資訊不足時：

`[待補：XXXXX]`

---

# 13. 最終目錄

預期 Repository：

```text
competitions/
│
├─ common/
│  ├─ project-facts.md
│  ├─ feature-status.md
│  └─ competition-matrix.md
│
├─ startup-challenge/
│  ├─ README.md
│  ├─ proposal.md
│  └─ pitch-outline.md
│
├─ smart-health/
│  ├─ README.md
│  └─ proposal.md
│
├─ ai-innovation/
│  ├─ README.md
│  ├─ team-and-motivation.md
│  └─ proposal.md
│
└─ ncue-innovation/
   ├─ README.md
   ├─ abstract.md
   ├─ project-description.md
   └─ poster-outline.md
```

---

# 14. Definition of Done

本任務完成的條件：

- [ ] 四場官方規則皆已整理
- [ ] 每場必交文件已確認
- [ ] 頁數／字數限制已確認
- [ ] 截止時間已確認
- [ ] project-facts.md 完成
- [ ] feature-status.md 完成
- [ ] competition-matrix.md 完成
- [ ] 青春靚點子投稿草稿完成
- [ ] 智慧健康照護投稿草稿完成
- [ ] AI 創新實戰投稿草稿完成
- [ ] 彰師大作品說明完成
- [ ] 所有未知資訊使用 `[待補]`
- [ ] 沒有捏造資料
- [ ] 四份文件事實一致
- [ ] 四份文件針對不同評審目的重新編排
- [ ] 所有文件使用繁體中文
