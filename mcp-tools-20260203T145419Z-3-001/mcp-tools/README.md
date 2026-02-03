# MCP Araçları Dokümantasyonu

> AI ajanlarının Model Context Protocol (MCP) sunucularını etkin kullanması için kapsamlı rehber.

---

## 📚 İçindekiler

| Dosya | Açıklama | Temel Kullanım |
|-------|----------|----------------|
| [CONTEXT7-MCP.md](./CONTEXT7-MCP.md) | Kütüphane dokümantasyonu erişimi | Güncel API bilgisi, kod örnekleri |
| [EXA-MCP.md](./EXA-MCP.md) | Web ve kod araması | Araştırma, kod snippet'leri |
| [SEQUENTIAL-THINKING-MCP.md](./SEQUENTIAL-THINKING-MCP.md) | Yapılandırılmış düşünme | Karmaşık problem çözme |
| [N8N-MCP.md](./N8N-MCP.md) | Workflow otomasyonu | n8n workflow yönetimi |
| [CHROME-DEVTOOLS-MCP.md](./CHROME-DEVTOOLS-MCP.md) | Tarayıcı otomasyonu ve debugging | Chrome kontrolü, performans analizi |

---

## 🎯 MCP Nedir?

Model Context Protocol (MCP), AI ajanlarının harici araçlar ve veri kaynaklarıyla standart bir protokol üzerinden iletişim kurmasını sağlayan açık bir standarttır. Anthropic tarafından 2024'te tanıtılmış ve Linux Foundation altındaki Agentic AI Foundation'a devredilmiştir.

### Temel Kavramlar

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   AI Agent      │────▶│   MCP Server    │────▶│  External Tool  │
│  (Claude, etc.) │◀────│   (Protocol)    │◀────│  (API, DB, etc) │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## 🔧 Genel Kurulum

### Konfigürasyon Dosyası Konumları

| Platform | Konum |
|----------|-------|
| Claude Desktop | `~/.config/claude/claude_desktop_config.json` |
| Cursor | `.cursor/mcp.json` |
| VS Code Copilot | `.vscode/mcp.json` |
| Kiro | `.kiro/settings/mcp.json` |
| Global | `~/.config/mcp/mcp.json` |

### Temel Konfigürasyon Yapısı

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "your-key"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### HTTP Tabanlı Konfigürasyon

```json
{
  "mcpServers": {
    "remote-server": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_KEY"
      }
    }
  }
}
```

---

## 🛠️ Araç Seçim Rehberi

### Senaryo Bazlı Öneriler

| Senaryo | Önerilen MCP | Araç |
|---------|--------------|------|
| Kütüphane API bilgisi | Context7 | `resolve-library-id` → `query-docs` |
| Kod örnekleri arama | Exa | `get_code_context_exa` |
| Genel web araması | Exa | `web_search_exa` |
| Karmaşık problem çözme | Sequential Thinking | `sequentialthinking` |
| Workflow oluşturma | n8n | `n8n_create_workflow` |
| Node bilgisi | n8n | `search_nodes` → `get_node` |
| Tarayıcı otomasyonu | Chrome DevTools | `navigate_page`, `click`, `fill` |
| Web debugging | Chrome DevTools | `list_console_messages`, `list_network_requests` |
| Performans analizi | Chrome DevTools | `performance_start_trace` → `performance_analyze_insight` |

### Kombinasyon Örnekleri

#### Araştırma + Düşünme

```
1. Exa ile web araması yap
2. Sequential Thinking ile sonuçları analiz et
3. Yapılandırılmış sonuç üret
```

#### Dokümantasyon + Kod

```
1. Context7 ile güncel API bilgisi al
2. Exa ile kod örnekleri ara
3. Sonuçları birleştir
```

#### Workflow Oluşturma

```
1. n8n search_nodes ile gerekli node'ları bul
2. n8n get_node ile konfigürasyon bilgisi al
3. n8n validate_workflow ile doğrula
4. n8n n8n_create_workflow ile oluştur
```

---

## 📋 Kullanım Protokolü

### Genel İş Akışı

```
1. Görevi analiz et
2. Uygun MCP sunucusunu seç
3. Gerekli araçları belirle
4. Araçları sırayla çağır
5. Sonuçları doğrula
6. Kullanıcıya sun
```

### Hata Yönetimi

```
1. Araç çağrısı başarısız olursa:
   - Parametreleri kontrol et
   - Alternatif araç dene
   - Kullanıcıya bilgi ver

2. Sonuç yetersizse:
   - Sorguyu genişlet
   - Farklı MCP dene
   - Manuel araştırma öner
```

---

## ⚠️ Genel Dikkat Edilmesi Gerekenler

### Güvenlik

```
❌ API key'leri koda yazma
❌ Hassas bilgileri sorguya ekleme
❌ Credential'ları loglama
✅ Environment variable kullan
✅ Minimum yetki prensibi uygula
```

### Performans

```
✅ Gerekli araçları seç, hepsini çağırma
✅ Sonuçları cache'le (mümkünse)
✅ Rate limit'lere dikkat et
✅ Timeout'ları ayarla
```

### Kalite

```
✅ Sonuçları doğrula
✅ Kaynak belirt
✅ Güncelliği kontrol et
✅ Alternatif kaynakları değerlendir
```

---

## 🔗 Faydalı Linkler

- **MCP Spesifikasyonu**: https://modelcontextprotocol.io
- **MCP Sunucu Listesi**: https://github.com/modelcontextprotocol/servers
- **Anthropic MCP Docs**: https://docs.anthropic.com/mcp

---

*Bu dokümantasyon, AI ajanlarının MCP ekosistemini etkin kullanması için hazırlanmıştır.*
