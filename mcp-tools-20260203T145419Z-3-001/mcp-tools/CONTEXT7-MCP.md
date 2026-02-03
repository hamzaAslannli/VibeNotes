# Context7 MCP Server

> AI ajanlarının güncel kütüphane dokümantasyonlarına ve kod örneklerine erişmesini sağlayan Model Context Protocol sunucusu.

---

## 🎯 Genel Bakış

Context7 MCP, AI ajanlarının programlama kütüphaneleri, framework'ler ve SDK'lar için güncel dokümantasyona erişmesini sağlar. LLM'lerin eğitim verilerinde bulunmayan veya güncelliğini yitirmiş bilgiler yerine, gerçek zamanlı ve versiyon-spesifik dokümantasyon sunar.

### Temel Özellikler

- **Güncel Dokümantasyon**: Kütüphanelerin en son versiyonlarına ait dokümantasyon
- **Kod Örnekleri**: Gerçek dünya kullanım örnekleri ve snippet'ler
- **Versiyon Desteği**: Belirli versiyonlara özel dokümantasyon erişimi
- **Hallüsinasyon Önleme**: Güncel olmayan API'ler yerine doğru bilgi sağlama

---

## 🔧 Kurulum

### NPX ile Yerel Kurulum

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ]
    }
  }
}
```

### API Key ile Kurulum

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp",
        "--api-key",
        "YOUR_API_KEY"
      ]
    }
  }
}
```

### Remote MCP Server (HTTP)

```json
{
  "mcpServers": {
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "YOUR_API_KEY"
      },
      "tools": [
        "get-library-docs",
        "resolve-library-id"
      ]
    }
  }
}
```

---

## 🛠️ Araçlar (Tools)

### 1. resolve-library-id

Paket/ürün adını Context7 uyumlu kütüphane ID'sine çözümler.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `libraryName` | string | ✅ | Aranacak kütüphane adı |
| `query` | string | ✅ | Kullanıcının orijinal sorusu veya görevi |

#### Kullanım Örneği

```javascript
// React kütüphanesi için ID çözümleme
resolve_library_id({
  libraryName: "react",
  query: "React hooks kullanarak state yönetimi nasıl yapılır?"
})
```

#### Dönen Değer

```json
{
  "libraryId": "/facebook/react",
  "name": "React",
  "description": "A JavaScript library for building user interfaces",
  "codeSnippets": 1500,
  "sourceReputation": "High",
  "benchmarkScore": 95.2
}
```

#### Önemli Notlar

- **Her zaman önce çağrılmalı**: `query-docs` kullanmadan önce bu araç ile geçerli bir library ID alınmalıdır
- **İstisna**: Kullanıcı `/org/project` formatında direkt ID verirse bu adım atlanabilir
- **Maksimum 3 çağrı**: Soru başına en fazla 3 kez çağrılmalı

---

### 2. query-docs (get-library-docs)

Belirli bir kütüphane için dokümantasyon ve kod örnekleri getirir.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `libraryId` | string | ✅ | Context7 uyumlu kütüphane ID'si (örn: `/facebook/react`) |
| `query` | string | ✅ | Dokümantasyonda aranacak soru veya konu |

#### Kullanım Örneği

```javascript
// React hooks dokümantasyonu
query_docs({
  libraryId: "/facebook/react",
  query: "useEffect cleanup function examples"
})
```

#### Dönen Değer

```json
{
  "content": {
    "snippets": [
      {
        "title": "useEffect Cleanup Example",
        "description": "How to properly clean up effects",
        "code": "useEffect(() => {\n  const subscription = props.source.subscribe();\n  return () => {\n    subscription.unsubscribe();\n  };\n}, [props.source]);"
      }
    ],
    "totalSnippets": 15
  },
  "totalTokens": 2500,
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalPages": 2,
    "hasNext": true,
    "hasPrev": false
  }
}
```

---

## 📋 Kullanım Protokolü

### Standart İş Akışı

```
1. Kullanıcı sorusu analiz edilir
2. resolve-library-id ile kütüphane ID'si alınır
3. query-docs ile ilgili dokümantasyon çekilir
4. Sonuçlar kullanıcıya sunulur
```

### Doğrudan ID Kullanımı

Kullanıcı direkt kütüphane ID'si verirse:

```
"Implement JWT auth with Supabase. use library /supabase/supabase"
```

Bu durumda `resolve-library-id` atlanabilir ve direkt `query-docs` çağrılabilir.

---

## 🎯 En İyi Kullanım Senaryoları

### 1. Güncel API Bilgisi

```javascript
// Next.js 14 App Router için güncel bilgi
resolve_library_id({
  libraryName: "next.js",
  query: "Next.js 14 App Router server components"
})

query_docs({
  libraryId: "/vercel/next.js",
  query: "server components data fetching patterns"
})
```

### 2. Versiyon-Spesifik Dokümantasyon

```javascript
// Belirli bir versiyon için
query_docs({
  libraryId: "/vercel/next.js/v14.3.0",
  query: "partial prerendering configuration"
})
```

### 3. Kod Örnekleri Arama

```javascript
// Pratik örnekler için
query_docs({
  libraryId: "/prisma/prisma",
  query: "many-to-many relations with explicit join table"
})
```

---

## ⚠️ Dikkat Edilmesi Gerekenler

### Yapılması Gerekenler ✅

```
✅ Her zaman önce resolve-library-id çağır
✅ Spesifik ve açıklayıcı query'ler kullan
✅ Versiyon gerekiyorsa belirt
✅ Sonuçları doğrula ve kullanıcıya sun
✅ Maksimum 3 çağrı kuralına uy
```

### Yapılmaması Gerekenler ❌

```
❌ Library ID'yi tahmin etme
❌ Hassas bilgileri (API key, şifre) query'ye ekleme
❌ Aynı soru için 3'ten fazla çağrı yapma
❌ resolve-library-id sonucunu beklemeden query-docs çağırma
```

---

## 🔗 Desteklenen Kütüphaneler (Örnekler)

| Kütüphane | Library ID | Snippet Sayısı |
|-----------|------------|----------------|
| React | `/facebook/react` | 1500+ |
| Next.js | `/vercel/next.js` | 2000+ |
| Vue.js | `/vuejs/vue` | 1200+ |
| Supabase | `/supabase/supabase` | 800+ |
| Prisma | `/prisma/prisma` | 600+ |
| TailwindCSS | `/tailwindlabs/tailwindcss` | 400+ |
| Express | `/expressjs/express` | 300+ |
| FastAPI | `/tiangolo/fastapi` | 500+ |

---

## 📚 İlgili Kaynaklar

- **Resmi Site**: https://context7.com
- **MCP Protokolü**: https://modelcontextprotocol.io
- **NPM Paketi**: @upstash/context7-mcp

---

*Bu dokümantasyon, AI ajanlarının Context7 MCP sunucusunu etkin kullanması için hazırlanmıştır.*
