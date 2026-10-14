workspace "CARE" "Clinical Assistance & Resource Engine C4 model" {
    !identifiers hierarchical

    model {
        user = person "使用者" "長輩、一般使用者或家庭照護成員，透過 LINE 與 CARE 互動。"
        caregiver = person "家庭照護者" "被授權查看或協助管理家人健康紀錄、提醒與定位事件。"
        admin = person "管理者" "維護知識回報、系統設定與測試資料。"

        care = softwareSystem "CARE" "LINE/LIFF 健康資訊、提醒、家庭照護與 AI 輔助服務。" {
            frontend = container "CARE-LIFF 前端" "提供首頁、設定、健康紀錄、家庭、提醒、法務公開頁等介面；/legal/testing 不需登入也不初始化 LIFF。" "React / Vite / Nginx" {
                tags "Frontend"
            }

            backend = container "CARE Backend API" "LINE Webhook、LIFF API、AI/RAG、健康紀錄、用藥、掛號、家庭權限、防走失、看診錄音與媒體處理核心。" "Python / FastAPI" {
                tags "Backend"

                lineWebhook = component "LINE Webhook Router" "驗證 LINE webhook，分流文字、語音、圖片、檔案、postback 與位置事件。" "FastAPI Router"
                liffApi = component "LIFF API / Auth" "處理 LIFF ID token 換發 CARE JWT，提供前端 API。" "FastAPI Router"
                conversation = component "Conversation Agent" "整合意圖判斷、工具呼叫、RAG、查核與 LINE 回覆。" "Python Service"
                mediaProcessor = component "Media Processor" "下載 LINE media，處理圖片、音訊、影片與文件；失敗時回傳可理解錯誤。" "Python Service"
                speech = component "Speech Orchestrator" "華語走 Gemini STT，台語走 Taigi AI Labs STT/TTS，必要時降級 local-asr 或華語 TTS。" "Python Service"
                rag = component "RAG / Knowledge Service" "以 MongoDB Atlas Search、Vector Search、pgvector 與 rerank 支援可信健康問答。" "Python Service"
                health = component "Health Records Service" "血壓、血糖、脈搏、體重、步數、經期等健康紀錄。" "Python Service"
                medication = component "Medication Service" "藥袋辨識、用藥提醒、藥證庫比對、外觀縮圖與安全提示。" "Python Service"
                appointment = component "Appointment Service" "掛號提醒、到診/出發狀態、LINE Flex 卡片互動。" "Python Service"
                family = component "Family RBAC Service" "家庭邀請、角色權限、委任與 SENSITIVE/GENERAL 資料範圍控管。" "Python Service"
                lost = component "Lost Location Service" "防走失事件、限時位置分享與家人到場狀態。" "Python Service"
                clinic = component "Clinic Visit Recorder" "看診錄音、逐字稿、摘要、權限與 TTL 管理。" "Python Service"
                ttsClient = component "TTS Client" "呼叫 care-tts 或 Taigi TTS，產出 LINE 可播放音檔。" "Python Service"
                persistence = component "Persistence Repositories" "封裝 MongoDB、PostgreSQL、Redis 與 TTL 資料存取。" "Python Repository Layer"
            }

            scheduler = container "CARE Scheduler" "背景排程：用藥提醒、掛號提醒、每日摘要、知識或資料同步任務。" "Python Worker"
            tts = container "care-tts" "合成語音回覆、轉檔、保存 LINE 可下載的音檔。" "Python / FastAPI / PyAV"
            n8n = container "CARE-n8n Workflow" "多媒體 workflow 編排；圖片 OCR、文件解析與 local sidecar 呼叫。" "n8n"
            localAsr = container "local-asr" "一般語音或備援語音轉文字；台語主流程不使用本機台語模型。" "FastAPI / faster-whisper"
            localParser = container "local-parser" "PDF、DOCX、XLSX、HTML 等文件文字解析。" "FastAPI"
            mongo = container "MongoDB Atlas" "使用者資料、健康紀錄、對話、知識庫、Vector Search、TTL 暫存。" "MongoDB / Atlas" {
                tags "Database" "ExternalManaged"
            }
            pgvector = container "PostgreSQL pgvector" "RAG 向量檢索與 health article embeddings。" "PostgreSQL / pgvector" {
                tags "Database"
            }
            redis = container "Redis" "快取、節流、短期狀態與任務協調。" "Redis" {
                tags "Database" "Cache"
            }
            ttsStorage = container "TTS Audio PVC" "暫存或保存 LINE 可抓取的 TTS mp3 音檔。" "Kubernetes PVC" {
                tags "Database" "Storage"
            }
        }

        line = softwareSystem "LINE Platform" "Messaging API、LIFF、Rich Menu、LINE media download 與推播。" {
            tags "External"
        }
        gemini = softwareSystem "Google Gemini" "LLM、OCR、圖片分析、語音轉文字、Embedding 與回答生成。" {
            tags "External" "AI"
        }
        taigi = softwareSystem "Taigi AI Labs API" "合作使用的台語 STT/TTS 外部 API。" {
            tags "External" "AI"
        }
        firecrawl = softwareSystem "Firecrawl" "公開網頁搜尋與抓取備援。" {
            tags "External"
        }
        cohere = softwareSystem "Cohere Rerank" "RAG 精排服務，未設定時降級不用。" {
            tags "External" "AI"
        }
        officialSources = softwareSystem "可信健康與政府資料來源" "衛福部、疾管署、食藥署、醫療院所、國際醫療資訊來源。" {
            tags "External"
        }
        kubernetes = softwareSystem "K3s / Traefik / Cloudflare" "承載 CARE 服務、Ingress、TLS、對外路由與維運。" {
            tags "External"
        }

        user -> line "以 LINE 訊息、語音、圖片、位置與 LIFF 開啟 CARE"
        caregiver -> line "接收提醒、查看授權資料、回報到診或防走失狀態"
        admin -> care.frontend "使用管理與知識回報介面" "HTTPS"

        line -> care.frontend "開啟 LIFF / 公開法律頁" "HTTPS"
        line -> care.backend "Webhook 事件、media download、postback" "HTTPS"
        care.backend -> line "回覆訊息、推播 Flex、Rich Menu、TTS audio URL" "HTTPS"
        care.frontend -> care.backend "LIFF API / JWT API" "HTTPS/JSON"

        care.backend -> care.mongo "讀寫使用者、健康、對話、家庭、提醒、TTL 資料" "MongoDB Protocol"
        care.backend -> care.pgvector "向量檢索與 embeddings 查詢" "PostgreSQL Protocol"
        care.backend -> care.redis "快取、鎖、節流、任務狀態" "Redis Protocol"
        care.scheduler -> care.mongo "讀寫提醒與排程狀態" "MongoDB Protocol"
        care.scheduler -> line "推播提醒與摘要" "HTTPS"

        care.backend -> gemini "LLM、OCR、STT、Embedding、RAG 生成" "HTTPS/API"
        care.backend -> taigi "台語 STT/TTS；x-api-key；WAV/JSON" "HTTPS/API"
        care.backend -> care.tts "華語/一般語音合成" "HTTP"
        care.tts -> care.ttsStorage "寫入 mp3 音檔" "Filesystem/PVC"
        care.tts -> line "提供 LINE 下載音檔" "HTTPS via Ingress"

        care.backend -> care.n8n "媒體處理 fallback webhook" "HTTP"
        care.n8n -> care.localAsr "一般音訊/影片轉文字備援" "HTTP"
        care.n8n -> care.localParser "文件解析" "HTTP"
        care.n8n -> gemini "圖片 OCR / 視覺分析" "HTTPS/API"

        care.backend -> firecrawl "公開網頁搜尋或抓取" "HTTPS/API"
        care.backend -> cohere "候選文件 rerank" "HTTPS/API"
        care.scheduler -> officialSources "ETL / 知識庫更新" "HTTPS"
        care.frontend -> kubernetes "由 Ingress 對外服務" "HTTPS"
        care.backend -> kubernetes "部署、服務發現、PVC 與 Secret" "Kubernetes"

        care.frontend -> care.backend.liffApi "登入、讀寫設定與功能 API" "HTTPS/JSON"
        care.backend.lineWebhook -> care.backend.conversation "文字與 postback 對話事件"
        care.backend.lineWebhook -> care.backend.mediaProcessor "圖片、語音、影片、文件事件"
        care.backend.lineWebhook -> care.backend.lost "位置與防走失事件"
        care.backend.liffApi -> care.backend.health "健康紀錄 API"
        care.backend.liffApi -> care.backend.medication "用藥 API"
        care.backend.liffApi -> care.backend.appointment "掛號 API"
        care.backend.liffApi -> care.backend.family "家庭與權限 API"
        care.backend.liffApi -> care.backend.clinic "看診紀錄 API"

        care.backend.conversation -> care.backend.rag "需要可信健康資訊時檢索"
        care.backend.conversation -> care.backend.ttsClient "需要語音回覆時"
        care.backend.mediaProcessor -> care.backend.speech "音訊辨識與語言判定"
        care.backend.mediaProcessor -> care.n8n "圖片 OCR、文件解析或備援媒體流程"
        care.backend.speech -> gemini "華語/一般語音 STT"
        care.backend.speech -> taigi "台語 STT/TTS 外部 API"
        care.backend.speech -> care.localAsr "Taigi/Gemini 失敗時備援"
        care.backend.rag -> care.mongo "Atlas Search / Vector Search"
        care.backend.rag -> care.pgvector "向量檢索"
        care.backend.rag -> cohere "精排"
        care.backend.rag -> gemini "生成與改寫"
        care.backend.health -> care.backend.persistence "保存健康紀錄"
        care.backend.medication -> care.backend.persistence "保存用藥、草稿與提醒"
        care.backend.appointment -> care.backend.persistence "保存掛號提醒與狀態"
        care.backend.family -> care.backend.persistence "保存家庭關係與權限"
        care.backend.lost -> care.backend.persistence "保存防走失事件"
        care.backend.clinic -> care.backend.speech "看診錄音轉文字"
        care.backend.clinic -> care.backend.persistence "逐字稿與摘要 TTL 保存"
        care.backend.persistence -> care.mongo "MongoDB repositories"
        care.backend.persistence -> care.redis "cache / locks"
        care.backend.persistence -> care.pgvector "RAG vector repositories"
        care.backend.ttsClient -> care.tts "一般 TTS"
        care.backend.ttsClient -> taigi "台語 TTS"
    }

    views {
        systemContext care "SystemContext" "CARE 與使用者、LINE、AI、資料來源與部署平台的關係。" {
            include *
            autolayout lr
        }

        container care "Containers" "CARE 主要容器、資料儲存與外部服務。" {
            include *
            autolayout lr
        }

        component care.backend "BackendComponents" "CARE Backend 的主要業務元件。" {
            include *
            autolayout lr
        }

        dynamic care "TaiwaneseSpeechFlow" "台語語音輸入與回覆流程。" {
            user -> line "傳送台語語音"
            line -> care.backend.lineWebhook "Webhook audio event"
            care.backend.lineWebhook -> care.backend.mediaProcessor "下載 LINE 音訊並暫存"
            care.backend.mediaProcessor -> care.backend.speech "解碼 16 kHz mono WAV / 切段"
            care.backend.speech -> taigi "台語 STT stt_best_billing"
            care.backend.speech -> gemini "平行華語/一般 STT"
            care.backend.speech -> care.backend.conversation "選擇逐字稿與 detected_speech_language"
            care.backend.conversation -> care.backend.rag "可信健康資訊檢索"
            care.backend.rag -> gemini "生成回答"
            care.backend.conversation -> care.backend.ttsClient "需要台語語音回覆"
            care.backend.ttsClient -> taigi "台語 TTS"
            care.backend.ttsClient -> care.tts "轉成 LINE 可播放音檔"
            care.tts -> care.ttsStorage "保存 mp3"
            care.backend -> line "回覆文字與音檔 URL"
            line -> user "顯示 Flex / 播放語音"
            autolayout lr
        }

        styles {
            element "Person" {
                shape person
                background #f5efe3
                color #1f2d3d
                fontSize 34
            }

            element "Software System" {
                shape roundedbox
                background #dbeafe
                color #102033
                fontSize 32
            }

            element "External" {
                background #f3f4f6
                color #1f2937
                stroke #9ca3af
            }

            element "Container" {
                shape roundedbox
                background #e0f2fe
                color #102033
                fontSize 30
            }

            element "Component" {
                shape roundedbox
                background #ffffff
                color #102033
                stroke #64748b
                fontSize 28
            }

            element "Frontend" {
                background #dcfce7
                stroke #16a34a
            }

            element "Backend" {
                background #dbeafe
                stroke #2563eb
            }

            element "Database" {
                shape cylinder
                background #fef3c7
                stroke #d97706
            }

            element "Cache" {
                background #ffedd5
                stroke #ea580c
            }

            element "Storage" {
                background #ede9fe
                stroke #7c3aed
            }

            element "AI" {
                background #f3e8ff
                stroke #9333ea
            }

            element "ExternalManaged" {
                stroke #6b7280
            }

            relationship "Relationship" {
                color #334155
                thickness 2
                fontSize 24
            }
        }
    }
}
