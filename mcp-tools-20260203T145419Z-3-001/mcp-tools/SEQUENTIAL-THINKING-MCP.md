# Sequential Thinking MCP Server

> AI ajanlarının yapılandırılmış düşünme süreci ile karmaşık problemleri adım adım çözmesini sağlayan Model Context Protocol sunucusu.

---

## 🎯 Genel Bakış

Sequential Thinking MCP, AI ajanlarına dinamik ve yansıtıcı problem çözme yeteneği kazandırır. Karmaşık problemleri yönetilebilir adımlara böler, düşünceleri revize eder, alternatif yollar keşfeder ve çözüm hipotezleri üretir.

### Temel Özellikler

- **Yapılandırılmış Problem Çözme**: Karmaşık problemleri adımlara bölme
- **Düşünce Revizyonu**: Önceki düşünceleri sorgulama ve güncelleme
- **Dallanma (Branching)**: Alternatif çözüm yollarını keşfetme
- **Dinamik Ayarlama**: Toplam düşünce sayısını dinamik olarak değiştirme
- **Hipotez Doğrulama**: Çözüm hipotezleri üretme ve doğrulama

---

## 🔧 Kurulum

### NPX ile Kurulum (Önerilen)

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    }
  }
}
```

### Docker ile Kurulum

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "mcp/sequentialthinking"
      ]
    }
  }
}
```

### Kaynak Koddan Build

```bash
docker build -t mcp/sequentialthinking -f src/sequentialthinking/Dockerfile .
```

---

## 🛠️ Araçlar (Tools)

### sequentialthinking

Yapılandırılmış, adım adım düşünme süreci sağlar.

#### Parametreler

| Parametre | Tip | Zorunlu | Açıklama |
|-----------|-----|---------|----------|
| `thought` | string | ✅ | Mevcut düşünme adımı |
| `nextThoughtNeeded` | boolean | ✅ | Başka düşünce adımı gerekip gerekmediği |
| `thoughtNumber` | integer | ✅ | Mevcut düşünce numarası (1'den başlar) |
| `totalThoughts` | integer | ✅ | Tahmini toplam düşünce sayısı |
| `isRevision` | boolean | ❌ | Bu düşünce önceki bir düşünceyi revize ediyor mu |
| `revisesThought` | integer | ❌ | Hangi düşünce numarası revize ediliyor |
| `branchFromThought` | integer | ❌ | Dallanma noktası düşünce numarası |
| `branchId` | string | ❌ | Mevcut dal tanımlayıcısı |
| `needsMoreThoughts` | boolean | ❌ | Daha fazla düşünce gerekip gerekmediği |

---

## 📋 Kullanım Protokolü

### Temel İş Akışı

```
1. Problemi analiz et ve tahmini düşünce sayısını belirle
2. Her adımda düşünceyi kaydet
3. Gerekirse önceki düşünceleri revize et
4. Alternatif yollar için dallan
5. Hipotez üret ve doğrula
6. Tatmin edici sonuca ulaşana kadar devam et
```

### Düşünce Tipleri

#### 1. Normal Analitik Adım

```javascript
sequentialthinking({
  thought: "Problemi analiz ediyorum: Kullanıcı bir e-ticaret sitesi için ödeme sistemi istiyor. Öncelikle güvenlik gereksinimlerini belirlememiz gerekiyor.",
  nextThoughtNeeded: true,
  thoughtNumber: 1,
  totalThoughts: 5
})
```

#### 2. Revizyon Adımı

```javascript
sequentialthinking({
  thought: "Önceki düşüncemi revize ediyorum: Güvenlik gereksinimlerini belirlerken PCI-DSS uyumluluğunu da dahil etmeliyim.",
  nextThoughtNeeded: true,
  thoughtNumber: 3,
  totalThoughts: 5,
  isRevision: true,
  revisesThought: 1
})
```

#### 3. Dallanma Adımı

```javascript
sequentialthinking({
  thought: "Alternatif bir yaklaşım düşünüyorum: Stripe yerine PayPal entegrasyonu da değerlendirilebilir.",
  nextThoughtNeeded: true,
  thoughtNumber: 4,
  totalThoughts: 6,
  branchFromThought: 2,
  branchId: "paypal-alternative"
})
```

#### 4. Hipotez Üretimi

```javascript
sequentialthinking({
  thought: "Hipotez: Stripe + 3D Secure kombinasyonu en güvenli ve kullanıcı dostu çözüm olacaktır. Bunun nedenleri: 1) Geniş kart desteği, 2) Otomatik fraud detection, 3) Kolay entegrasyon.",
  nextThoughtNeeded: true,
  thoughtNumber: 5,
  totalThoughts: 7
})
```

#### 5. Hipotez Doğrulama

```javascript
sequentialthinking({
  thought: "Hipotezi doğruluyorum: Stripe'ın fraud detection oranları %99.9, 3D Secure ile chargeback oranları %80 azalıyor. Hipotez doğrulandı.",
  nextThoughtNeeded: true,
  thoughtNumber: 6,
  totalThoughts: 7
})
```

#### 6. Sonuç Adımı

```javascript
sequentialthinking({
  thought: "Sonuç: E-ticaret ödeme sistemi için Stripe + 3D Secure + Webhook entegrasyonu öneriyorum. Bu çözüm güvenlik, kullanılabilirlik ve maliyet açısından optimal.",
  nextThoughtNeeded: false,
  thoughtNumber: 7,
  totalThoughts: 7
})
```

---

## 🎯 En İyi Kullanım Senaryoları

### 1. Karmaşık Problem Çözme

```javascript
// Mimari karar verme
sequentialthinking({
  thought: "Microservices vs Monolith kararı için faktörleri değerlendiriyorum: 1) Takım büyüklüğü, 2) Ölçeklenebilirlik gereksinimleri, 3) Deployment karmaşıklığı",
  nextThoughtNeeded: true,
  thoughtNumber: 1,
  totalThoughts: 8
})
```

### 2. Planlama ve Tasarım

```javascript
// Proje planlama
sequentialthinking({
  thought: "Sprint planlaması yapıyorum: Öncelik sırası - 1) Authentication, 2) Core API, 3) Frontend, 4) Testing. Her sprint 2 hafta.",
  nextThoughtNeeded: true,
  thoughtNumber: 1,
  totalThoughts: 5
})
```

### 3. Hata Ayıklama

```javascript
// Bug analizi
sequentialthinking({
  thought: "Memory leak analizi: 1) Heap dump incelendi, 2) Event listener'lar kontrol edildi, 3) Closure'lar gözden geçirildi. Sorun: removeEventListener eksik.",
  nextThoughtNeeded: true,
  thoughtNumber: 3,
  totalThoughts: 4
})
```

### 4. Araştırma ve Analiz

```javascript
// Teknoloji değerlendirme
sequentialthinking({
  thought: "React vs Vue karşılaştırması: Performans açısından React Fiber daha optimize, ancak Vue'nun reactivity sistemi daha sezgisel.",
  nextThoughtNeeded: true,
  thoughtNumber: 2,
  totalThoughts: 6
})
```

---

## 🔄 Dinamik Düşünce Yönetimi

### Düşünce Sayısını Artırma

```javascript
// Başlangıçta 5 düşünce planlandı, ama daha fazla gerekti
sequentialthinking({
  thought: "Daha fazla analiz gerekiyor: Edge case'leri değerlendirmeliyim.",
  nextThoughtNeeded: true,
  thoughtNumber: 5,
  totalThoughts: 8,  // 5'ten 8'e artırıldı
  needsMoreThoughts: true
})
```

### Erken Sonlandırma

```javascript
// Beklenenden erken çözüme ulaşıldı
sequentialthinking({
  thought: "Çözüm bulundu: Basit bir cache invalidation sorunu. Redis TTL ayarı yeterli.",
  nextThoughtNeeded: false,  // 3. adımda sonlandırıldı
  thoughtNumber: 3,
  totalThoughts: 5
})
```

---

## 📊 Dallanma (Branching) Stratejileri

### Paralel Keşif

```javascript
// Ana dal
sequentialthinking({
  thought: "Ana çözüm yolu: REST API tasarımı",
  thoughtNumber: 2,
  totalThoughts: 6,
  nextThoughtNeeded: true
})

// Alternatif dal
sequentialthinking({
  thought: "Alternatif: GraphQL API tasarımı",
  thoughtNumber: 3,
  totalThoughts: 6,
  branchFromThought: 2,
  branchId: "graphql-branch",
  nextThoughtNeeded: true
})
```

### Dal Karşılaştırma

```javascript
sequentialthinking({
  thought: "Dal karşılaştırması: REST daha basit ve cache-friendly, GraphQL daha esnek. Proje gereksinimleri göz önüne alındığında REST tercih edilmeli.",
  thoughtNumber: 5,
  totalThoughts: 6,
  nextThoughtNeeded: true
})
```

---

## ⚠️ Dikkat Edilmesi Gerekenler

### Yapılması Gerekenler ✅

```
✅ Gerçekçi bir başlangıç düşünce sayısı belirle
✅ Her düşünceyi açık ve net ifade et
✅ Gerektiğinde önceki düşünceleri revize et
✅ Belirsizlik durumunda dallanma kullan
✅ Hipotezleri doğrula
✅ nextThoughtNeeded=false sadece gerçekten bittiğinde kullan
```

### Yapılmaması Gerekenler ❌

```
❌ Çok fazla düşünce ile başlama (5-10 arası ideal)
❌ Düşünceleri çok kısa veya belirsiz bırakma
❌ Revizyon yapmadan hatalı düşünceleri devam ettirme
❌ Gereksiz dallanma yapma
❌ Doğrulanmamış hipotezlerle sonuçlandırma
```

---

## 🧠 Düşünce Kalıpları

### Problem Analizi Kalıbı

```
Düşünce 1: Problem tanımı ve kapsam belirleme
Düşünce 2: Mevcut durum analizi
Düşünce 3: Kısıtlar ve gereksinimler
Düşünce 4: Olası çözümler
Düşünce 5: Çözüm değerlendirme
Düşünce 6: Sonuç ve öneriler
```

### Karar Verme Kalıbı

```
Düşünce 1: Karar kriterleri belirleme
Düşünce 2: Seçenekleri listeleme
Düşünce 3: Her seçeneği kriterlere göre değerlendirme
Düşünce 4: Trade-off analizi
Düşünce 5: Karar ve gerekçe
```

### Hata Ayıklama Kalıbı

```
Düşünce 1: Hata belirtilerini tanımlama
Düşünce 2: Olası nedenleri listeleme
Düşünce 3: Her nedeni test etme
Düşünce 4: Kök neden belirleme
Düşünce 5: Çözüm uygulama
Düşünce 6: Doğrulama
```

---

## 📚 İlgili Kaynaklar

- **GitHub**: https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking
- **NPM**: @modelcontextprotocol/server-sequential-thinking
- **MCP Protokolü**: https://modelcontextprotocol.io

---

*Bu dokümantasyon, AI ajanlarının Sequential Thinking MCP sunucusunu etkin kullanması için hazırlanmıştır.*
