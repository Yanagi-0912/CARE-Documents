# Iteration 7 未定義項目與程式現況

本清單以目前儲存庫中的後端、LIFF 前端與部署設定為依據。判定中的「已定義」代表程式已有明確資料模型、權限或操作流程，不代表正式環境已完成部署或驗收。

狀態定義：

- **已定義**：原缺口已有完整且可執行的程式行為。
- **部分定義**：已有部分實作，但原缺口仍有未涵蓋範圍。
- **未定義**：找不到對應資料模型、API 或操作流程。
- **無法由程式確認**：需要正式環境設定或資料才能判斷。

## 核心規格現況

| 編號 | 狀態 | 目前程式定義 | 仍待補項目 |
| --- | --- | --- | --- |
| A-02 | 部分定義 | 藥袋辨識已有「掃描 → 草稿 → 使用者核對／修改 → 提交」流程，草稿有期限且只能由建立者讀取。 | 沒有以自然語言新增血壓／血糖紀錄的工具，也沒有個別健康資訊分享確認流程。 |
| A-03 | 已定義 | 可設定或清除親屬稱謂、設定照顧對象標籤、撤銷邀請及雙向移除成員；移除時同步撤銷雙方委任並留下稽核紀錄。 | 無。 |
| A-04 | 已定義 | 走失求救由 LINE 對話觸發；本人透過 LIFF 授權並每 20 秒上傳位置。只有 `elder_lost` 合格收件人可查看，enforced 時為 GUARDIAN／CAREGIVER，shadow 時為族譜成員。位置 3 分鐘未更新視為過期、2 小時自動結束、24 小時後清除；支援軌跡、家屬回報正在前往及結束事件。 | 正式環境的瀏覽器定位授權結果仍由使用者裝置決定。 |
| A-05 | 已定義 | 設定頁可調整語言、字級、語音回覆、語速及音色；設定同時保存於資料庫與本機，登入後以資料庫值同步其他裝置。代理更新健康檔案不能修改 `settings`。 | 無。 |
| A-06 | 已定義 | 一般用藥逾時通知使用 `medication_missed` 政策；enforced 時通知 GUARDIAN／CAREGIVER，shadow 時保留族譜成員。本人可關閉用藥提醒，家屬可各自關閉家庭通知。每日醫療消息預設 09:00（台北時間）發送給所有啟用訂閱的使用者，每人每日最多一則。 | 發送時間目前是全域環境設定，不是每位使用者可自訂。 |
| A-07 | 部分定義 | RBAC 已登記用藥提醒、藥品、掛號提醒、健康檔案、對話摘要／原文、血壓血糖量測、健康提醒範圍、經期及步數；未登記欄位跨使用者時採 fail-closed。經期新增 PERSONAL 分類，僅本人可讀寫。 | 「家庭安全照護」若要包含上述資源以外的新資料，仍須逐項新增分類與操作規則。 |
| A-08 | 部分定義 | 血壓血糖量測、提醒範圍及步數為 SENSITIVE；本人可管理，GUARDIAN 可代記量測／設定範圍，GUARDIAN 與 CAREGIVER 可讀，MEMBER 不可存取。經期為 PERSONAL，只限女性本人。健康新端點在 shadow 也不放寬；已具前景計步、歷史等級與超限推播。 | 尚無體重時間序列 API；LIFF 目前呈現量測清單，未找到獨立的趨勢圖或趨勢分析流程。 |
| A-09 | 未定義 | 目前的 `share_care` 僅分享 CARE 加好友／邀請卡，不會分享健康資料。 | 逐筆健康資訊分享的資料模型、接收對象、授權、傳遞、撤回、期限及轉傳控制皆未實作。 |
| A-10 | 部分定義 | 原始藥袋圖片只送入辨識服務，程式未將圖片保存；結構化辨識結果存於建立者專屬的短期草稿。提交後的藥品依 GENERAL／SENSITIVE 欄位規則供家屬讀取。 | OCR 草稿未納入家庭 RBAC；沒有可跨使用者讀取的「完整風險報告」資源與分類。 |
| A-11 | 已定義 | 高風險用藥使用 `high_risk_drug_alert`，對話中的緊急事件使用 `emergency_detected`；兩者在 enforced 時皆通知 GUARDIAN／CAREGIVER。低風險用藥只通知本人，通知不會增加資料讀取權。 | 新增其他風險種類時仍須另行登記通知政策。 |
| A-12 | 部分定義 | 委任資料模型、有效期限、查詢服務、撤銷 API、權限提升與稽核皆已存在；移除成員時會自動撤銷委任。 | 新委任建立受 `FAMILY_DELEGATION_ACTIVATION_ENABLED=false` 關閉，且沒有終端使用者核可流程；有效委任查詢尚未公開為 API，LIFF 也沒有委任管理畫面。 |
| A-13 | 無法由程式完整確認 | 程式與 Helm 預設 `FAMILY_RBAC_ENFORCED=true`；每位資料擁有者仍以 `rbac_migration_state` 個別區分 shadow／enforced，角色全數指派後可遷移為 enforced。 | 儲存庫無法回答正式環境實際開關值，以及資料庫中各擁有者目前的遷移狀態。 |

## 其他待補項目現況

| 項目 | 狀態 | 目前程式定義與缺口 |
| --- | --- | --- |
| 個人化藥物交互作用 | 部分定義 | 新增藥品後會與使用者既有藥品檢查成分重複、抗膽鹼疊加、西藥類別配對及中西藥交互作用；沒有自動調整處方功能。 |
| 逐欄權限與自訂角色 | 未定義 | 目前只有固定的 OWNER、GUARDIAN、CAREGIVER、MEMBER 矩陣及固定欄位分類，沒有使用者自訂角色或逐欄授權介面。 |
| 既有委任前端管理 | 部分定義 | 後端有撤銷端點與內部查詢服務，但沒有查詢 API、LIFF 清單或撤銷確認畫面。 |
| 語言支援範圍 | 已定義 | 文字與介面支援繁中、英文、印尼文、越南文、泰文、日文；台語選項使用繁中介面，語音走台語 STT／TTS。 |
| 自然語言操作範圍 | 部分定義 | 目前工具涵蓋醫療問答、查核、院所搜尋、用藥問答／狀態／服藥回報、家庭成員查詢及 CARE 分享；沒有自然語言新增健康量測、修改家庭角色或分享健康資料。 |
| 健康提醒範圍 | 已定義 | 系統不內建醫療門檻；本人或 GUARDIAN 設定血壓與血糖上下限，歷史等級不因後續修改而重算。 |
| 經期紀錄 | 已定義 | 僅女性本人可操作，資料分類為 PERSONAL；異常通知只給本人且避免在鎖定畫面暴露敏感字詞與數字。 |
| LIFF 計步 | 已定義 | 僅前景估算，每 30 秒同步累計值，背景暫停、跨台北午夜換工作階段；不宣稱背景計步。 |

## 主要程式依據

- [Iteration 7 健康紀錄模組技術文件](<./Iteration%207健康紀錄模組技術文件.md>)
- [健康量測 API](../CARE/app/routers/users/health.py)與[家庭授權分類](../CARE/app/models/family_authorization.py)
- [家庭成員 API](../CARE/app/routers/users/family_tree.py)、[家庭服務](../CARE/app/services/family/family_tree_service.py)與[委任服務](../CARE/app/services/family/family_delegation_service.py)
- [走失定位 API](../CARE/app/routers/users/lost.py)與[定位服務](../CARE/app/services/lost/lost_location_service.py)
- [使用者設定模型](../CARE/app/models/user.py)與[LIFF 設定頁](../CARE-LIFF/src/pages/Settings/index.tsx)
- [用藥排程](../CARE/app/services/medication/medication_scheduler.py)與[每日醫療消息排程](../CARE/app/services/medical_news/push_scheduler.py)
- [藥袋草稿模型](../CARE/app/models/prescription.py)與[藥袋掃描服務](../CARE/app/services/medication/prescription_scan_service.py)
- [對話緊急通報](../CARE/app/services/safety/emergency_alert_service.py)與[用藥風險通報](../CARE/app/services/safety/safety_alert_service.py)
- [Agent 工具清單](../CARE/app/tools/registry.py)與[部署設定](../CARE-infra/helm/care/values.yaml)

原始需求來源：[Iteration 7使用案例(Use Case).md](./Iteration%207使用案例(Use%20Case).md)
