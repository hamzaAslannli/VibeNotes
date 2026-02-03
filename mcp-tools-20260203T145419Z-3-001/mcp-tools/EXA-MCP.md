# Exa MCP Server

> AI ajanlarının web araması, kod araması ve içerik çıkarma yeteneklerine erişmesini sağlayan Model Context Protocol sunucusu.

---

## 🎯 Genel Bakış

Exa MCP, AI ajanlarını Exa AI'ın güçlü arama yetenekleriyle buluşturur. Web araması, kod araması, şirket araştırması ve derin araştırma gibi özellikler sunar. Özellikle kodlama ajanları için optimize edilmiş `exa-code` özelliği, milyarlarca GitHub repo, dokümantasyon sayfası ve Stack Overflow gönderisi üzerinde arama yapabilir.

### Temel Özellikler

- **Web Araması**: Gerçek zamanlı web araması ve içerik çıkarma
- **Kod Araması**: GitHub, dokümantasyon ve Stack Overflow üzerinde kod araması
- **Derin Araştırma**: Karmaşık sorular için kapsamlı araştırma raporları
- **Şirket Araştırması**: Şirket web sitelerinden detaylı bilgi toplama
- **LinkedIn Araması**: Şirket ve kişi profilleri araması

---

## 🔧 Kurulum

### Remote MCP (Önerilen)

```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp?exaApiKey=YOUR_API_KEY"
    }
  }
}
```

### Belirli Araçları Etkinleştirme

```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp?exaApiKey=YOUR_API_KEY&tools=web_search_exa,get_code_context_exa"
    }
  }
}
```

### Tüm Araçları Etkinleştirme

```json
{
  "mcpServers": {
    "exa": {
      "type": "http",
      "url": "https://mcp.exa.ai/mcp?exaApiKey=YOUR_API_KEY&tools=get_code_context_exa,web_search_exa,deep_search_exa,company_research_exa,crawling_exa,linkedin_search_exa,deep_researcher_start,deep_researcher_check"
    }
  }
}
```

### NPX ile Yerel Kurulum

```json
{
  "mcpServers": {
    "exa": {
      "command": "npx",
      "args": [
        "-y",
        "exa-mcp-server"
      ],
      "env": {
        "EXA_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

### Sadece Kod Araması (Geliştiriciler için)

```json
{
  "mcpServers": {
    "exa": {
      "command": "npx",
      "args": [
        "-y",
        "exa-mcp-server",
        "tools=get_code_context_exa"
      ],
      "env": {
        "EXA_API_KEY": "your-api-key-here"
      }
    }
  }
}
```

---

## 🛠️ Araçlar (Tools)

### 1. web_search_exa

Gerçek zamanlı web araması yapar ve optimize edilmiş sonuçlar döner.

#### Parametreler

| Parametre | Tip | Zorunlu | Varsayılan | Açıklama |
|-----------|-----|---------|------------|----------|
| `query` | string | ✅ | - | Arama sorgusu |
| `numResults` | number | ❌ | 8 | Döndürülecek sonuç sayısı |
| `type` | string | ❌ | "auto" | Arama tipi: "auto", "fast", "deep" |
| `livecrawl` | string | ❌ | "fallback" | Canlı tarama modu: "fallback", "preferred" |
| `contextMaxCharacters` | number | ❌ | 10000 | LLM için optimize edilmiş maksimum karakter |

#### Kullanım Örneği

```javascript
web_search_exa({
  query: "Next.js 14 server actions best practices",
  numResults: 5,
  type: "auto"
})
```

#### Dönen Değer

```json
{
  "results": [
    {
      "title": "Server Actions in Next.js 14",
      "url": "https://example.com/article",
      "snippet": "Server Actions are asynchronous functions...",
      "publishedDate": "2024-01-15",
      "domain": "example.com"
    }
  ]
}
```

---

### 2. get_code_context_exa

Programlama görevleri için kod snippet'leri, örnekler ve dokümantasyon arar.

#### Parametreler

| Parametre | Tip | Zorunlu | Varsayılan | Açıklama |
|-----------|-----|---------|------------|----------|
| `query` | string | ✅ | - | Kod araması sorgusu |
| `tokensNum` | number | ❌ | 5000 | Döndürülecek token sayısı (1000-50000) |

#### Kullanım Örneği

```javascript
get_code_context_exa({
  query: "React useState hook examples with TypeScript",
  tokensNum: 8000
})
```

#### En İyi Kullanım Senaryoları

```javascript
// API kullanım örnekleri
get_code_context_exa({
  query: "Express.js middleware authentication JWT"
})

// Framework konfigürasyonu
get_code_context_exa({
  query: "Next.js partial prerendering configuration"
})

// Kütüphane entegrasyonu
get_code_context_exa({
  query: "Prisma many-to-many relations example"
})
```

---

### 3. deep_search_exa

Akıllı sorgu genişletme ve yüksek kaliteli özetlerle derin web araması yapar.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `query` | string | ✅ | Araştırma sorgusu |
| `numResults` | number | ❌ | Sonuç sayısı |

#### Kullanım Örneği

```javascript
deep_search_exa({
  query: "Microservices vs monolith architecture comparison 2024",
  numResults: 10
})
```

---

### 4. company_research

Şirket web sitelerini tarayarak detaylı bilgi toplar.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `query` | string | ✅ | Şirket adı veya açıklaması |

#### Kullanım Örneği

```javascript
company_research({
  query: "Vercel company information products services"
})
```

---

### 5. crawling

Belirli URL'lerden içerik çıkarır.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `url` | string | ✅ | Taranacak URL |

#### Kullanım Örneği

```javascript
crawling({
  url: "https://docs.example.com/api-reference"
})
```

---

### 6. linkedin_search

LinkedIn'de şirket ve kişi araması yapar.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `query` | string | ✅ | LinkedIn arama sorgusu |

#### Kullanım Örneği

```javascript
linkedin_search({
  query: "software engineer at Google San Francisco"
})
```

---

### 7. deep_researcher_start

Karmaşık sorular için AI araştırmacı başlatır.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `query` | string | ✅ | Araştırma sorusu |

#### Kullanım Örneği

```javascript
deep_researcher_start({
  query: "What are the best practices for building scalable microservices in 2024?"
})
```

#### Dönen Değer

```json
{
  "researchId": "research_abc123",
  "status": "started",
  "estimatedTime": "2-5 minutes"
}
```

---

### 8. deep_researcher_check

Başlatılan araştırmanın durumunu kontrol eder ve sonuçları alır.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `researchId` | string | ✅ | Araştırma ID'si |

#### Kullanım Örneği

```javascript
deep_researcher_check({
  researchId: "research_abc123"
})
```

---

## 📋 Kullanım Protokolü

### Kod Araması İş Akışı

```
1. Kullanıcının kod sorusu analiz edilir
2. get_code_context_exa ile ilgili kod örnekleri aranır
3. Sonuçlar filtrelenir ve kullanıcıya sunulur
```

### Derin Araştırma İş Akışı

```
1. deep_researcher_start ile araştırma başlatılır
2. Kullanıcıya bekleme süresi bildirilir
3. deep_researcher_check ile periyodik kontrol yapılır
4. Araştırma tamamlandığında sonuçlar sunulur
```

---

## 🎯 En İyi Kullanım Senaryoları

### 1. Güncel Teknoloji Bilgisi

```javascript
// En son framework güncellemeleri
web_search_exa({
  query: "React 19 new features release notes",
  type: "deep"
})
```

### 2. Kod Örnekleri ve Patterns

```javascript
// Design pattern implementasyonları
get_code_context_exa({
  query: "Repository pattern TypeScript implementation",
  tokensNum: 10000
})
```

### 3. Karşılaştırmalı Araştırma

```javascript
// Teknoloji karşılaştırması
deep_researcher_start({
  query: "PostgreSQL vs MongoDB for real-time applications performance comparison"
})
```

### 4. API Dokümantasyonu

```javascript
// Belirli API kullanımı
crawling({
  url: "https://api.openai.com/docs/api-reference"
})
```

---

## ⚠️ Dikkat Edilmesi Gerekenler

### Yapılması Gerekenler ✅

```
✅ Kod soruları için get_code_context_exa kullan
✅ Genel web araması için web_search_exa kullan
✅ Karmaşık araştırmalar için deep_researcher kullan
✅ Spesifik URL'ler için crawling kullan
✅ Token limitlerini göz önünde bulundur
```

### Yapılmaması Gerekenler ❌

```
❌ Hassas bilgileri sorguya ekleme
❌ Çok geniş/belirsiz sorgular kullanma
❌ deep_researcher sonucunu beklemeden kontrol etme
❌ Rate limit'leri aşma
```

---

## 🔧 Araç Seçim Rehberi

| Senaryo | Önerilen Araç |
|---------|---------------|
| Kod örnekleri arama | `get_code_context_exa` |
| Genel web araması | `web_search_exa` |
| Detaylı araştırma | `deep_search_exa` |
| Kapsamlı rapor | `deep_researcher_start/check` |
| Şirket bilgisi | `company_research` |
| Belirli sayfa içeriği | `crawling` |
| LinkedIn profilleri | `linkedin_search` |

---

## 🔐 API Key Alma

1. https://dashboard.exa.ai/api-keys adresine gidin
2. Hesap oluşturun veya giriş yapın
3. Yeni API key oluşturun
4. Key'i güvenli bir şekilde saklayın

---

## 📚 İlgili Kaynaklar

- **Exa AI**: https://exa.ai
- **API Dokümantasyonu**: https://docs.exa.ai
- **GitHub**: https://github.com/exa-labs/exa-mcp-server
- **MCP Protokolü**: https://modelcontextprotocol.io

---

*Bu dokümantasyon, AI ajanlarının Exa MCP sunucusunu etkin kullanması için hazırlanmıştır.*
