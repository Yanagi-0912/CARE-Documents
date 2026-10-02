# CARE 功能狀態

狀態僅使用 `Implemented`、`Developing`、`Planned`、`Unknown`。`Implemented` 代表 Repository 已有可辨識的操作流程與程式證據，不等同已完成醫療場域驗證。

| Feature | Status | Evidence / 限制 |
| --- | --- | --- |
| LINE Bot 與多輪對話 | Implemented | `CARE/app/routers/line/webhook.py`、`CARE/app/services/agent/` |
| LIFF 操作介面 | Implemented | `CARE-LIFF/src/pages/` |
| RAG 可信資訊問答 | Implemented | `CARE/app/services/rag/`；含 pgvector 檢索、重排、來源與資料不足處理 |
| 健康傳言查核 | Implemented | `CARE/app/services/rag/claim_verification/` |
| OCR／文件處理 | Implemented | `CARE/app/services/media/`、`CARE-n8n/local_parser/` |
| 一般語音辨識 ASR | Implemented | `CARE/app/services/speech/gemini_stt.py` |
| 台語 STT | Implemented | `CARE/app/services/speech/taigi_client.py`；已有工程基準，仍缺真實場域樣本 |
| 台語 TTS | Implemented | `CARE/app/services/speech/taigi_client.py`、`taigi_text.py`；已有工程基準 |
| 多語介面與回覆 | Developing | 設定與多語 UI 已存在；端到端自然語言理解覆蓋仍需逐語驗證 |
| 血壓／血糖紀錄 | Implemented | 可新增、刪除、查詢；家屬依 SENSITIVE 權限存取 |
| 自訂提醒範圍 | Implemented | 本人或具權限 GUARDIAN 設定，不內建醫療門檻 |
| 超出範圍通知 | Developing | 判定與保存已實作；部署開關預設關閉，啟用後才通知 |
| 經期紀錄 | Implemented | 僅女性本人；PERSONAL，家屬不可存取 |
| LIFF 前景計步 | Implemented | 使用者主動開啟、前景估算；不是背景或醫療級計步 |
| 體重時間序列 | Planned | 目前健康檔案只有單一體重欄位 |
| 獨立趨勢圖／醫療趨勢分析 | Planned | 現有為時間清單及歷史等級 |
| 藥袋掃描與核對 | Implemented | `prescription_ocr_service.py`、LIFF 掃描與草稿核對流程 |
| 藥物資訊與風險提示 | Implemented | 食藥署藥證資料、交互作用與風險規則；不是診斷或完整藥事判定 |
| 用藥提醒 | Implemented | 建立、修改、刪除、服藥確認與逾時政策 |
| 每日健康資訊 | Implemented | 訂閱者於 Asia/Taipei 09:00 每日最多一則；不能個別自訂時間 |
| 一般衛教資訊分享 | Implemented | 分享不含個資的內容及來源 |
| 個人健康資料主動分享 | Planned | 逐筆分享、期限、撤回及轉傳控制未完成 |
| 醫療資源與 GPS 搜尋 | Implemented | 附近院所、科別／類型、營業狀態、撥號與掛號入口 |
| 家庭帳號 | Implemented | 邀請、關係、角色、成員管理與健康摘要 |
| 家庭 RBAC | Implemented | GENERAL／SENSITIVE／PRIVATE／PERSONAL；正式環境模式須另查部署 |
| 防走失定位 | Implemented | 本人授權、合格家屬查看、過期與清除規則 |
| 看診錄音與摘要 | Developing | LINE 流程、同意與台華語轉錄已實作；真實 LINE 與診間品質待驗證 |
| 高齡字級與語音偏好 | Implemented | 設定頁支援字級、語音回覆、語速與音色 |
| 自然語言操作全部模組 | Developing | 問答、查核、院所、用藥及部分家庭工具已支援；健康量測新增與角色修改未完整支援 |

