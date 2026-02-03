# n8n MCP Server

> AI ajanlarının n8n workflow otomasyon platformu ile etkileşim kurmasını sağlayan kapsamlı Model Context Protocol sunucusu.

---

## 🎯 Genel Bakış

n8n MCP, AI ajanlarına n8n workflow otomasyon platformunun tüm yeteneklerini sunar. Node keşfi, workflow oluşturma, validasyon, test etme ve yönetim işlemlerini programatik olarak gerçekleştirmeyi sağlar. Özellikle AI Agent workflow'ları için kapsamlı destek sunar.

### Temel Özellikler

- **Node Keşfi**: 500+ n8n node'u arasında arama ve bilgi alma
- **Workflow Yönetimi**: Oluşturma, güncelleme, silme, listeleme
- **Validasyon**: Kapsamlı workflow ve node validasyonu
- **Template Sistemi**: 2700+ hazır template'e erişim
- **AI Agent Desteği**: AI workflow'ları için özel araçlar
- **Versiyon Yönetimi**: Workflow versiyonlama ve rollback

---

## 🔧 Kurulum

### Gereksinimler

- n8n instance (self-hosted veya cloud)
- n8n API Key
- n8n API URL

### Environment Variables

```bash
N8N_API_URL=https://your-n8n-instance.com/api/v1
N8N_API_KEY=your-api-key-here
```

### MCP Konfigürasyonu

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": [
        "-y",
        "@n8n/mcp-server"
      ],
      "env": {
        "N8N_API_URL": "https://your-n8n-instance.com/api/v1",
        "N8N_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

---

## 🛠️ Araçlar (Tools)

### Kategori: Sistem

#### tools_documentation

Meta-dokümantasyon aracı. Tüm MCP araçları hakkında bilgi döner.

```javascript
// Genel bakış
tools_documentation()

// Belirli araç hakkında detaylı bilgi
tools_documentation({topic: "search_nodes", depth: "full"})

// AI Agent rehberi
tools_documentation({topic: "ai_agents_guide", depth: "full"})
```

#### n8n_health_check

n8n instance sağlık kontrolü yapar.

```javascript
// Basit kontrol
n8n_health_check()

// Detaylı diagnostik
n8n_health_check({mode: "diagnostic", verbose: true})
```

---

### Kategori: Keşif (Discovery)

#### search_nodes

n8n node'ları arasında metin araması yapar.

| Parametre | Tip | Zorunlu | Varsayılan | Açıklama |
|-----------|-----|---------|------------|----------|
| `query` | string | ✅ | - | Arama anahtar kelimeleri |
| `limit` | number | ❌ | 20 | Maksimum sonuç sayısı (max: 100) |
| `mode` | string | ❌ | "OR" | Arama modu: "OR", "AND", "FUZZY" |
| `includeExamples` | boolean | ❌ | false | Gerçek dünya örnekleri dahil et |

```javascript
// Basit arama
search_nodes({query: "webhook"})

// Tüm kelimeler eşleşmeli
search_nodes({query: "google sheets", mode: "AND"})

// Yazım hatası toleranslı
search_nodes({query: "slak", mode: "FUZZY"})

// Örneklerle birlikte
search_nodes({query: "http api", includeExamples: true})
```

---

### Kategori: Konfigürasyon

#### get_node

Node bilgisi ve şeması getirir.

| Parametre | Tip | Zorunlu | Varsayılan | Açıklama |
|-----------|-----|---------|------------|----------|
| `nodeType` | string | ✅ | - | Node tipi (örn: "nodes-base.httpRequest") |
| `detail` | string | ❌ | "standard" | Detay seviyesi: "minimal", "standard", "full" |
| `mode` | string | ❌ | "info" | Mod: "info", "docs", "search_properties", "versions" |
| `includeExamples` | boolean | ❌ | false | Örnek konfigürasyonlar dahil et |
| `includeTypeInfo` | boolean | ❌ | false | Tip bilgisi dahil et |

```javascript
// Standart bilgi (önerilen)
get_node({nodeType: "nodes-base.httpRequest"})

// Minimal metadata
get_node({nodeType: "nodes-base.slack", detail: "minimal"})

// Tam detay ve örnekler
get_node({nodeType: "nodes-base.googleSheets", detail: "full", includeExamples: true})

// Okunabilir dokümantasyon
get_node({nodeType: "nodes-base.webhook", mode: "docs"})

// Property arama
get_node({nodeType: "nodes-base.httpRequest", mode: "search_properties", propertyQuery: "auth"})

// Versiyon geçmişi
get_node({nodeType: "nodes-base.executeWorkflow", mode: "versions"})

// Versiyon karşılaştırma
get_node({nodeType: "nodes-base.httpRequest", mode: "compare", fromVersion: "3.0", toVersion: "4.1"})
```

---

### Kategori: Validasyon

#### validate_node

Node konfigürasyonunu doğrular.

```javascript
// Tam validasyon
validate_node({
  nodeType: "nodes-base.slack",
  config: {resource: "channel", operation: "create"},
  mode: "full"
})

// Hızlı kontrol
validate_node({
  nodeType: "nodes-base.httpRequest",
  config: {url: "https://api.example.com"},
  mode: "minimal"
})
```

#### validate_workflow

Workflow yapısını, bağlantılarını ve expression'larını doğrular.

```javascript
// Tam validasyon
validate_workflow({
  workflow: myWorkflowJson
})

// Özel ayarlarla
validate_workflow({
  workflow: myWorkflowJson,
  options: {
    validateNodes: true,
    validateConnections: true,
    validateExpressions: true,
    profile: "strict"
  }
})
```

---

### Kategori: Template

#### search_templates

2700+ template arasında arama yapar.

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `searchMode` | string | ❌ | "keyword", "by_nodes", "by_task", "by_metadata" |
| `query` | string | ❌ | Arama sorgusu (keyword modu için) |
| `nodeTypes` | array | ❌ | Node tipleri (by_nodes modu için) |
| `task` | string | ❌ | Görev tipi (by_task modu için) |
| `limit` | number | ❌ | Maksimum sonuç sayısı |

```javascript
// Anahtar kelime araması
search_templates({query: "chatbot", searchMode: "keyword"})

// Node'lara göre arama
search_templates({
  searchMode: "by_nodes",
  nodeTypes: ["n8n-nodes-base.httpRequest", "n8n-nodes-base.slack"]
})

// Göreve göre arama
search_templates({
  searchMode: "by_task",
  task: "ai_automation"
})

// Metadata filtresi
search_templates({
  searchMode: "by_metadata",
  complexity: "simple",
  requiredService: "openai"
})
```

#### get_template

Template detaylarını getirir.

```javascript
// Tam workflow
get_template({templateId: 1234, mode: "full"})

// Sadece node listesi
get_template({templateId: 1234, mode: "nodes_only"})

// Yapı (nodes + connections)
get_template({templateId: 1234, mode: "structure"})
```

---

### Kategori: Workflow Yönetimi

#### n8n_create_workflow

Yeni workflow oluşturur.

```javascript
n8n_create_workflow({
  name: "Webhook to Slack",
  nodes: [
    {
      id: "webhook_1",
      name: "Webhook",
      type: "n8n-nodes-base.webhook",
      typeVersion: 1,
      position: [250, 300],
      parameters: {
        httpMethod: "POST",
        path: "slack-notify"
      }
    },
    {
      id: "slack_1",
      name: "Slack",
      type: "n8n-nodes-base.slack",
      typeVersion: 1,
      position: [450, 300],
      parameters: {
        resource: "message",
        operation: "post",
        channel: "#general",
        text: "={{$json.message}}"
      }
    }
  ],
  connections: {
    "Webhook": {
      "main": [[{node: "Slack", type: "main", index: 0}]]
    }
  }
})
```

#### n8n_get_workflow

Workflow detaylarını getirir.

```javascript
// Tam workflow
n8n_get_workflow({id: "workflow_id", mode: "full"})

// Metadata + istatistikler
n8n_get_workflow({id: "workflow_id", mode: "details"})

// Sadece yapı
n8n_get_workflow({id: "workflow_id", mode: "structure"})

// Minimal bilgi
n8n_get_workflow({id: "workflow_id", mode: "minimal"})
```

#### n8n_update_partial_workflow

Workflow'u kısmi güncellemelerle değiştirir (önerilen).

```javascript
// Node ekleme
n8n_update_partial_workflow({
  id: "workflow_id",
  intent: "Add error handling",
  operations: [
    {
      type: "addNode",
      node: {
        name: "Error Handler",
        type: "n8n-nodes-base.set",
        position: [600, 400],
        parameters: {}
      }
    }
  ]
})

// Bağlantı ekleme
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [
    {
      type: "addConnection",
      source: "Webhook",
      target: "HTTP Request"
    }
  ]
})

// IF node dallanması
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [
    {type: "addConnection", source: "IF", target: "Success", branch: "true"},
    {type: "addConnection", source: "IF", target: "Error", branch: "false"}
  ]
})

// AI Agent bağlantıları
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [
    {type: "addConnection", source: "OpenAI", target: "AI Agent", sourceOutput: "ai_languageModel"},
    {type: "addConnection", source: "HTTP Tool", target: "AI Agent", sourceOutput: "ai_tool"},
    {type: "addConnection", source: "Memory", target: "AI Agent", sourceOutput: "ai_memory"}
  ]
})

// Node güncelleme
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [
    {
      type: "updateNode",
      nodeName: "HTTP Request",
      updates: {"parameters.url": "https://new-api.example.com"}
    }
  ]
})

// Workflow aktivasyonu
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [{type: "activateWorkflow"}]
})
```

#### n8n_list_workflows

Workflow listesini getirir.

```javascript
// Tüm workflow'lar
n8n_list_workflows()

// Aktif olanlar
n8n_list_workflows({active: true})

// Tag filtresi
n8n_list_workflows({tags: ["production"]})

// Sayfalama
n8n_list_workflows({limit: 50, cursor: "next_page_cursor"})
```

#### n8n_delete_workflow

Workflow'u kalıcı olarak siler.

```javascript
n8n_delete_workflow({id: "workflow_id"})
```

---

### Kategori: Test ve Çalıştırma

#### n8n_test_workflow

Workflow'u test eder/tetikler.

```javascript
// Otomatik tespit
n8n_test_workflow({workflowId: "123"})

// Webhook ile veri
n8n_test_workflow({
  workflowId: "123",
  triggerType: "webhook",
  data: {name: "John", email: "john@example.com"}
})

// Chat trigger
n8n_test_workflow({
  workflowId: "123",
  triggerType: "chat",
  message: "Hello AI",
  sessionId: "session_123"
})

// Form submission
n8n_test_workflow({
  workflowId: "123",
  triggerType: "form",
  data: {email: "test@example.com", name: "Test User"}
})
```

#### n8n_executions

Execution yönetimi.

```javascript
// Execution detayı
n8n_executions({action: "get", id: "execution_id"})

// Hata modu (debugging için)
n8n_executions({action: "get", id: "execution_id", mode: "error"})

// Execution listesi
n8n_executions({action: "list", workflowId: "workflow_id", status: "error"})

// Execution silme
n8n_executions({action: "delete", id: "execution_id"})
```

---

### Kategori: Versiyon Yönetimi

#### n8n_workflow_versions

Workflow versiyon geçmişi ve rollback.

```javascript
// Versiyon listesi
n8n_workflow_versions({mode: "list", workflowId: "workflow_id"})

// Belirli versiyon
n8n_workflow_versions({mode: "get", versionId: 5})

// Rollback
n8n_workflow_versions({mode: "rollback", workflowId: "workflow_id", versionId: 3})

// Eski versiyonları temizle
n8n_workflow_versions({mode: "prune", workflowId: "workflow_id", maxVersions: 10})
```

---

### Kategori: Template Deployment

#### n8n_deploy_template

Template'i n8n instance'a deploy eder.

```javascript
n8n_deploy_template({
  templateId: 1234,
  name: "My Custom Workflow",
  autoFix: true,
  autoUpgradeVersions: true
})
```

---

## 🤖 AI Agent Workflow'ları

### AI Bağlantı Tipleri

| Tip | Kaynak | Hedef | Açıklama |
|-----|--------|-------|----------|
| `ai_languageModel` | OpenAI, Anthropic, Gemini | AI Agent | Dil modeli bağlantısı |
| `ai_tool` | HTTP Tool, Code Tool | AI Agent | Araç bağlantısı |
| `ai_memory` | Window Buffer, Summary | AI Agent | Hafıza bağlantısı |
| `ai_outputParser` | Structured Parser | AI Agent | Çıktı parser bağlantısı |
| `ai_embedding` | Embeddings OpenAI | Vector Store | Embedding bağlantısı |
| `ai_vectorStore` | Pinecone, In-Memory | Vector Store Tool | Vector store bağlantısı |
| `ai_document` | Document Loader | Vector Store | Doküman bağlantısı |
| `ai_textSplitter` | Text Splitter | Document Chain | Text splitter bağlantısı |

### AI Agent Kurulum Örneği

```javascript
// 1. Workflow oluştur
n8n_create_workflow({
  name: "AI Assistant",
  nodes: [
    {
      id: "chat",
      name: "Chat Trigger",
      type: "@n8n/n8n-nodes-langchain.chatTrigger",
      position: [100, 100],
      parameters: {options: {responseMode: "lastNode"}}
    },
    {
      id: "openai",
      name: "OpenAI",
      type: "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      position: [300, 50],
      parameters: {model: "gpt-4"}
    },
    {
      id: "agent",
      name: "AI Agent",
      type: "@n8n/n8n-nodes-langchain.agent",
      position: [300, 150],
      parameters: {systemMessage: "You are a helpful assistant."}
    }
  ],
  connections: {}
})

// 2. Bağlantıları ekle
n8n_update_partial_workflow({
  id: "workflow_id",
  operations: [
    {type: "addConnection", source: "Chat Trigger", target: "AI Agent"},
    {type: "addConnection", source: "OpenAI", target: "AI Agent", sourceOutput: "ai_languageModel"}
  ]
})

// 3. Validate et
n8n_validate_workflow({id: "workflow_id"})
```

---

## ⚠️ Dikkat Edilmesi Gerekenler

### Yapılması Gerekenler ✅

```
✅ Workflow oluşturmadan önce validate_workflow kullan
✅ Node tiplerine "nodes-base." veya "nodes-langchain." prefix'i ekle
✅ AI bağlantılarında sourceOutput parametresini belirt
✅ IF node'ları için branch="true"/"false" kullan
✅ Switch node'ları için case=N kullan
✅ intent parametresini her zaman ekle
```

### Yapılmaması Gerekenler ❌

```
❌ API key olmadan n8n araçlarını çağırma
❌ Workflow'u aktif etmeden test etme
❌ AI Agent'a language model bağlamadan oluşturma
❌ sourceIndex yerine branch/case kullanmayı unutma
❌ Validasyon hatalarını görmezden gelme
```

---

## 📚 İlgili Kaynaklar

- **n8n Dokümantasyonu**: https://docs.n8n.io
- **n8n API**: https://docs.n8n.io/api
- **MCP Protokolü**: https://modelcontextprotocol.io

---

*Bu dokümantasyon, AI ajanlarının n8n MCP sunucusunu etkin kullanması için hazırlanmıştır.*
