# AGENTS.md - AI Coding Agent Universal Instructions

> Bu dosya, AI kodlama ajanlarının projeyi anlaması ve etkili çalışması için evrensel talimatlar içerir.
> README.md insanlar için, AGENTS.md ise AI ajanları içindir.
> Desteklenen ajanlar: Claude Code, OpenAI Codex, Cursor, VS Code Copilot, Gemini CLI, Devin, opencode, Windsurf, Aider, goose ve diğerleri.

---

## 🧠 Başlangıç Protokolü

Herhangi bir göreve başlamadan önce aşağıdaki adımları sırasıyla uygula:

### Adım 1: Dokümantasyon Taraması
```
1. Proje kökünden başlayarak tüm .md uzantılı dosyaları listele
2. README.md, CONTRIBUTING.md, CHANGELOG.md, ARCHITECTURE.md dosyalarını oku
3. docs/ dizini varsa içeriğini tara
4. Alt dizinlerde AGENTS.md veya CLAUDE.md dosyası varsa bunları da oku
5. Her .md dosyasının içeriğini kısa notlar halinde hafızana al
```

### Adım 2: Proje Yapısı Analizi
```
1. Kök dizindeki yapılandırma dosyalarını tespit et:
   - package.json, pnpm-workspace.yaml → Node.js/JavaScript/TypeScript
   - pyproject.toml, setup.py, requirements.txt → Python
   - go.mod, go.sum → Go
   - Cargo.toml → Rust
   - composer.json → PHP
   - Gemfile → Ruby
   - pom.xml, build.gradle → Java/Kotlin

2. Dizin yapısını analiz et ve şu kalıpları ara:
   - src/, lib/, app/ → Ana kaynak kodu
   - tests/, test/, __tests__/, spec/ → Test dosyaları
   - docs/, documentation/ → Dokümantasyon
   - scripts/, bin/, tools/ → Yardımcı scriptler
   - config/, .config/ → Yapılandırma

3. Giriş noktalarını belirle:
   - main.*, index.*, app.*, server.*
   - package.json'daki "main" ve "bin" alanları
   - __main__.py, wsgi.py, asgi.py
```

### Adım 3: Mimari Analizi
```
1. Import/export yapısını incele ve modül bağımlılık grafiğini çıkar
2. Kullanılan tasarım kalıplarını tespit et:
   - MVC, MVVM, Clean Architecture, Hexagonal
   - Repository Pattern, Service Layer, Factory Pattern
   - Component-based, Module-based yapılar

3. Katmanları belirle:
   - Presentation/UI katmanı
   - Business Logic/Domain katmanı
   - Data Access/Infrastructure katmanı
   - API/Controller katmanı

4. State management yaklaşımını anla (frontend için)
5. API yapısını analiz et (REST, GraphQL, gRPC, WebSocket)
```

### Adım 4: Bağımlılık ve Versiyon Tespiti
```
1. Paket yöneticisi dosyasını oku ve tüm bağımlılıkları listele
2. Ana framework ve kütüphanelerin versiyonlarını not al
3. Dev dependencies ve production dependencies ayrımını yap
4. Peer dependencies ve uyumluluk gereksinimlerini kontrol et
5. Lock dosyasının (package-lock.json, pnpm-lock.yaml, poetry.lock, go.sum) varlığını doğrula
```

### Adım 5: MCP Araçları Kontrolü
```
1. Aşağıdaki yapılandırma dosyalarını kontrol et:
   - .mcp.json (proje seviyesi)
   - mcp.json
   - ~/.config/*/mcp.json (global)

2. Aktif MCP sunucularını ve araçlarını listele
3. Her aracın ne işe yaradığını ve nasıl çağrıldığını anla
4. Kullanılabilir MCP yeteneklerini göreve göre değerlendir:
   - Dosya sistemi erişimi
   - Git işlemleri
   - Veritabanı sorguları
   - API çağrıları
   - Browser otomasyonu
   - Harici servis entegrasyonları
```

---

## 📜 Evrensel Kod Kuralları

### Genel Prensipler
```
- DRY (Don't Repeat Yourself): Tekrarlanan kodu fonksiyona çıkar
- KISS (Keep It Simple): Gereksiz karmaşıklıktan kaçın
- SOLID prensiplerini uygula
- Mevcut kod stiline uy, yeni stil dayatma
- Değişiklik yapmadan önce mevcut testlerin geçtiğini doğrula
- Her değişiklik için uygun test yaz
```

### Dosya ve Dizin Kuralları
```
- Yeni dosya oluştururken mevcut isimlendirme kurallarını takip et:
  - camelCase, PascalCase, kebab-case, snake_case hangisi kullanılıyorsa onu sürdür
- Dosyaları ilgili dizinlere yerleştir, kök dizini kirletme
- Her modül/bileşen kendi dizininde olmalı (index dosyası ile export)
- Test dosyaları ya kaynak dosyanın yanında ya da tests/ dizininde olmalı
```

### Kod Stili Tespiti
```
1. Mevcut kod dosyalarından stil kurallarını çıkar:
   - Girinti: tab mı space mi, kaç karakter
   - Tırnak işareti: tek mi çift mi
   - Noktalı virgül kullanımı
   - Trailing comma tercihi
   - Import sıralaması

2. Yapılandırma dosyalarını kontrol et:
   - .editorconfig
   - .prettierrc, prettier.config.js
   - .eslintrc, eslint.config.js
   - .stylelintrc
   - pyproject.toml [tool.black], [tool.ruff]
   - rustfmt.toml
   - .golangci.yml

3. Bu kurallara mutlaka uy, asla ezme
```

### Commit ve PR Kuralları
```
1. Commit mesajı formatını tespit et:
   - Conventional Commits: type(scope): description
   - Gitmoji: :emoji: description
   - Jira/Issue referansı: [PROJ-123] description

2. .github/ veya .gitlab/ dizinindeki şablonları incele
3. CONTRIBUTING.md dosyasındaki kurallara uy
4. Tek bir commit'te tek bir mantıksal değişiklik yap
5. Açıklayıcı commit mesajları yaz (ne ve neden)
```

---

## 🧪 Test Stratejisi

### Test Komutlarını Tespit Et
```
1. package.json'daki scripts bölümünü kontrol et:
   - "test", "test:unit", "test:integration", "test:e2e"
   - "test:watch", "test:coverage"

2. Makefile varsa test hedeflerini bul
3. pyproject.toml'da pytest yapılandırmasını ara
4. CI/CD workflow dosyalarındaki test komutlarını incele
```

### Test Yazma Kuralları
```
1. Mevcut test dosyalarının yapısını analiz et
2. Kullanılan test framework'ünü tespit et:
   - JavaScript: Jest, Vitest, Mocha, Cypress, Playwright
   - Python: pytest, unittest, nose
   - Go: testing paketi, testify
   - Rust: built-in test framework

3. Test isimlendirme kurallarını takip et:
   - describe/it blokları
   - test_* fonksiyon isimleri
   - should/when/given kalıpları

4. Her yeni fonksiyon için en az:
   - 1 happy path testi
   - 1 edge case testi
   - 1 error case testi
```

### Test Çalıştırma Protokolü
```
1. Değişiklik yapmadan önce mevcut testleri çalıştır
2. Değişiklik yaptıktan sonra ilgili testleri çalıştır
3. Tüm testler geçene kadar commit yapma
4. Coverage düşüşüne izin verme
```

---

## 🔧 Build ve Çalıştırma

### Otomatik Komut Tespiti
```
1. package.json scripts:
   - "dev", "start", "serve" → Geliştirme sunucusu
   - "build", "compile" → Production build
   - "lint", "lint:fix" → Kod kalitesi
   - "format", "prettier" → Kod formatlama

2. Makefile targets:
   - make, make all → Varsayılan build
   - make run, make dev → Çalıştırma
   - make test → Test
   - make clean → Temizlik

3. Python projeleri:
   - pip install -e . → Editable kurulum
   - python -m module_name → Modül çalıştırma
   - uvicorn/gunicorn → ASGI/WSGI sunucu

4. Go projeleri:
   - go build → Build
   - go run . → Çalıştırma
   - go mod tidy → Bağımlılık düzenleme
```

### Environment Yönetimi
```
1. .env.example veya .env.sample dosyasını kontrol et
2. Gerekli environment değişkenlerini tespit et
3. Asla gerçek credential'ları kod veya commit'e ekleme
4. Development ve production ortam farklarını anla
```

---

## 🔍 Hata Ayıklama Protokolü

### Hata Analizi
```
1. Hata mesajını tam olarak oku ve anla
2. Stack trace'i takip et, root cause'u bul
3. İlgili dosya ve satır numarasına git
4. Benzer hataların daha önce çözülüp çözülmediğini araştır:
   - Git history'de benzer değişiklikleri ara
   - Issue tracker'ı kontrol et
   - Test dosyalarında ipucu ara
```

### Çözüm Yaklaşımı
```
1. Minimal değişiklik yap, geniş kapsamlı refactor'dan kaçın
2. Değişikliğin yan etkilerini değerlendir
3. İlgili testleri güncelle veya yeni test ekle
4. Değişikliği açıklayan yorum ekle (gerekirse)
```

---

## 🔌 MCP (Model Context Protocol) Entegrasyonu

### MCP Nedir?
MCP, AI ajanlarının harici araçlar ve veri kaynaklarıyla standart bir protokol üzerinden iletişim kurmasını sağlayan açık bir standarttır. Anthropic tarafından 2024'te tanıtılmış ve Linux Foundation altındaki Agentic AI Foundation'a devredilmiştir.

### Yaygın MCP Sunucuları ve Yetenekleri

#### Dosya ve Sistem
```
- filesystem: Dosya okuma, yazma, listeleme, arama
- git: Repository işlemleri, commit, branch, diff
- shell/bash: Komut çalıştırma
```

#### Geliştirme Araçları
```
- github: Issue, PR, repository yönetimi
- gitlab: CI/CD, merge request işlemleri
- jira: Issue takibi
- linear: Proje yönetimi
```

#### Veritabanları
```
- postgres: PostgreSQL sorguları
- mysql: MySQL sorguları
- mongodb: MongoDB işlemleri
- sqlite: SQLite veritabanı
- redis: Cache işlemleri
```

#### Web ve API
```
- fetch: HTTP istekleri
- puppeteer: Browser otomasyonu
- playwright: E2E test otomasyonu
```

#### Bulut Servisleri
```
- aws: AWS servis entegrasyonu
- gcp: Google Cloud entegrasyonu
- azure: Azure servis entegrasyonu
- vercel: Deployment yönetimi
- cloudflare: Edge ve DNS yönetimi
```

#### Üretkenlik
```
- slack: Mesajlaşma
- notion: Dokümantasyon
- google-drive: Dosya depolama
- calendar: Takvim yönetimi
```

### MCP Kullanım Protokolü
```
1. Görev için gerekli MCP araçlarını belirle
2. Aracı kullanmadan önce yapılandırmanın doğru olduğunu kontrol et
3. Minimum yetki prensibiyle çalış (sadece gerekli izinleri kullan)
4. Hassas verileri loglamadan işle
5. Hata durumunda graceful fallback uygula
```

---

## 📝 Dokümantasyon Güncelleme

### Ne Zaman Güncelle
```
- Yeni özellik eklediğinde → README ve/veya docs/
- API değişikliğinde → API dokümantasyonu
- Konfigürasyon değişikliğinde → .env.example ve ilgili docs
- Breaking change'de → CHANGELOG ve migration guide
```

### Nasıl Güncelle
```
1. Mevcut dokümantasyon stiline uy
2. Kod örneklerini çalışır durumda tut
3. Versiyon numaralarını güncel tut
4. Değişiklik tarihini ekle (gerekirse)
```

---

## ⚠️ Kritik Uyarılar

### Asla Yapma
```
❌ Mevcut çalışan kodu "iyileştirmek" için refactor etme (istenmedikçe)
❌ Test coverage'ı düşürme
❌ Linting kurallarını devre dışı bırakma
❌ Credential veya secret'ları koda yazma
❌ package-lock, yarn.lock, pnpm-lock dosyalarını silme
❌ Başka biriyle çakışabilecek değişiklikler yapma
❌ Projenin kullandığı dil/framework versiyonunu değiştirme
❌ Geriye dönük uyumluluğu bozma (istenmedikçe)
```

### Her Zaman Yap
```
✅ Değişiklikten önce mevcut durumu anla
✅ Küçük, atomik değişiklikler yap
✅ Her değişikliği test et
✅ Commit mesajlarını açıklayıcı yaz
✅ Kod stiline uy
✅ Dokümantasyonu güncel tut
✅ Güvenlik açıklarına dikkat et
✅ Performance etkisini değerlendir
```

---

## 🔄 Görev Tamamlama Kontrol Listesi

Her görev sonunda bu listeyi kontrol et:

```
□ Tüm testler geçiyor mu?
□ Linting hataları var mı?
□ Yeni kod mevcut stile uyuyor mu?
□ Gerekli dokümantasyon güncellendi mi?
□ Breaking change var mı? (varsa belgelendi mi?)
□ Security açığı oluşturuldu mu?
□ Performance etkisi değerlendirildi mi?
□ Commit mesajı açıklayıcı mı?
□ PR/MR açıklaması yeterli mi?
```

---

## 📚 Ek Kaynaklar

### Proje-Spesifik Talimatlar
Alt dizinlerde bulunan AGENTS.md dosyaları, o dizine özel talimatlar içerir. Bir dizinde çalışırken en yakın AGENTS.md dosyasını öncelikli olarak uygula.

### İç İçe AGENTS.md Yapısı
```
project/
├── AGENTS.md              ← Genel kurallar (bu dosya)
├── packages/
│   ├── frontend/
│   │   └── AGENTS.md      ← Frontend-spesifik kurallar
│   └── backend/
│       └── AGENTS.md      ← Backend-spesifik kurallar
└── tests/
    └── AGENTS.md          ← Test yazma kuralları
```

### Çakışma Çözümü
En yakın AGENTS.md dosyasındaki kurallar, üst dizindeki kuralları override eder. Kullanıcının doğrudan verdiği talimatlar her şeyi override eder.

---

*Bu dosya, projenin AI ajanlarla verimli çalışmasını sağlamak için tasarlanmıştır.*

*AGENTS.md standardı hakkında daha fazla bilgi: https://agents.md*
*MCP hakkında daha fazla bilgi: https://modelcontextprotocol.io*

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
