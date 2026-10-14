# CARE Structurizr C4

本資料夾的 `structurizrC4.dsl` 是 CARE 目前架構的 Structurizr DSL，包含：

- `SystemContext`：CARE 與使用者、LINE、Google Gemini、Taigi AI Labs、資料來源與部署平台的關係。
- `Containers`：CARE-LIFF、Backend、Scheduler、TTS、n8n、local-asr、local-parser、MongoDB、pgvector、Redis、TTS PVC。
- `BackendComponents`：Backend 內部主要元件，例如 Webhook、LIFF API、Conversation Agent、Media Processor、Speech Orchestrator、RAG、健康紀錄、用藥、掛號、家庭權限、防走失、看診錄音。
- `TaiwaneseSpeechFlow`：台語語音輸入與回覆流程，明確標示 Taigi AI Labs 外部 API。

## 使用方式

若本機有 Structurizr CLI：

```bash
structurizr validate -workspace structurizrC4.dsl
```

若使用 Structurizr Lite，可將本資料夾掛載為 workspace 目錄後開啟瀏覽器檢視。

```bash
docker run --rm -it -p 8080:8080 -v "%cd%":/usr/local/structurizr structurizr/lite
```

Windows PowerShell 若在本資料夾執行：

```powershell
docker run --rm -it -p 8080:8080 -v "${PWD}:/usr/local/structurizr" structurizr/lite
```

