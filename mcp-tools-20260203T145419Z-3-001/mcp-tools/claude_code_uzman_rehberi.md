# Claude Code Uzman Rehberi: Çok Katmanlı Yapılar

## İçindekiler
1. [Genel Mimari](#genel-mimari)
2. [Agent Skills (Beceriler)](#agent-skills-beceriler)
3. [Subagents (Alt Ajanllar)](#subagents-alt-ajanlar)
4. [Hooks (Kancalar)](#hooks-kancalar)
5. [Plugins (Eklentiler)](#plugins-eklentiler)
6. [MCP (Model Context Protocol)](#mcp-model-context-protocol)
7. [Memory Yönetimi (CLAUDE.md)](#memory-yönetimi-claudemd)
8. [Slash Commands (Eğik Çizgi Komutları)](#slash-commands-eğik-çizgi-komutları)
9. [Best Practices ve Workflow](#best-practices-ve-workflow)

---

## Genel Mimari

Claude Code, basit bir kod asistanından çok daha fazlası—bir **AI ajan orkestrasyon framework'ü**. Katmanlı yapısı şöyle:

```
┌─────────────────────────────────────────────────────────────┐
│                    KULLANICI KATMANI                        │
│  (Doğal dil komutları, slash komutları, # quick memory)     │
├─────────────────────────────────────────────────────────────┤
│                    MEMORY KATMANI                           │
│  (CLAUDE.md hiyerarşisi, .claude/rules/)                    │
├─────────────────────────────────────────────────────────────┤
│                    SKILLS KATMANI                           │
│  (Otomatik aktive olan domain bilgisi)                      │
├─────────────────────────────────────────────────────────────┤
│                    SUBAGENT KATMANI                         │
│  (Paralel çalışan özelleşmiş ajanlar)                       │
├─────────────────────────────────────────────────────────────┤
│                    HOOKS KATMANI                            │
│  (Otomatik tetiklenen eylemler)                             │
├─────────────────────────────────────────────────────────────┤
│                    MCP KATMANI                              │
│  (Dış araç ve servis entegrasyonları)                       │
├─────────────────────────────────────────────────────────────┤
│                    PLUGINS KATMANI                          │
│  (Paketlenmiş ve paylaşılabilir konfigürasyonlar)           │
└─────────────────────────────────────────────────────────────┘
```

### Temel Fark: Skills vs Subagents vs MCP

| Bileşen | Ne Yapar | Ne Zaman Kullanılır |
|---------|----------|---------------------|
| **Skills** | Claude'a *nasıl düşüneceğini* öğretir | Domain uzmanlığı, metodolojiler |
| **Subagents** | İzole context'te *iş yapar* | Paralel işler, karmaşık görevler |
| **MCP** | Dış *araçlara erişim* sağlar | API'ler, veritabanları, servisler |

---

## Agent Skills (Beceriler)

### Nedir?

Skills, Claude'un yeteneklerini genişleten **modüler bilgi paketleri**dir. Bir klasör içinde talimatlar, scriptler ve kaynak dosyalar barındırır. Claude, görev tanımına göre otomatik olarak ilgili skill'i aktive eder.

### Temel Konsept: Progressive Disclosure

Skills, "aşamalı açıklama" prensibiyle çalışır:
1. **Metadata** (her zaman yüklenir): Skill adı ve açıklaması
2. **Talimatlar** (eşleşme olunca yüklenir): SKILL.md içeriği
3. **Kaynaklar** (ihtiyaç olunca yüklenir): Scripts, templates, references

Bu sayede context window verimli kullanılır.

### SKILL.md Dosya Yapısı

```markdown
---
name: skill-adi
description: Bu skill ne zaman kullanılmalı. Claude bu açıklamaya göre eşleştirme yapar.
context: fork  # Opsiyonel: izole context'te çalıştır
allowed-tools:  # Opsiyonel: araç kısıtlamaları
  - Read
  - Bash
hooks:  # Opsiyonel: lifecycle hook'ları
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/check.sh"
---

# Skill Talimatları

Bu skill aktive olduğunda Claude'un izleyeceği adımlar...

## Adım 1: Analiz
...

## Adım 2: Uygulama
...
```

### Skill Lokasyonları

```
~/.claude/skills/           # Kullanıcı skills (tüm projeler)
.claude/skills/             # Proje skills (takım paylaşımı)
plugins/*/skills/           # Plugin skills
/mnt/skills/public/         # Anthropic'in hazır skills'leri
```

### Örnek: Code Review Skill

```markdown
---
name: code-review
description: Kod değişikliklerini gözden geçir. "review", "incele", "kontrol et" dendiğinde kullan.
---

# Kod İnceleme Talimatları

## İnceleme Kriterleri
1. **Güvenlik**: SQL injection, XSS, hassas veri sızıntısı
2. **Performans**: N+1 sorguları, gereksiz döngüler
3. **Okunabilirlik**: İsimlendirme, fonksiyon boyutu
4. **Test Kapsamı**: Edge case'ler, hata durumları

## Çıktı Formatı
Her sorun için:
- Dosya ve satır numarası
- Sorun açıklaması
- Önerilen düzeltme
- Öncelik seviyesi (kritik/orta/düşük)
```

### Context Fork ile İzole Çalışma

```yaml
context: fork
```

Bu ayar, skill'i ayrı bir context window'da çalıştırır. Uzun analizler ana konuşmayı kirletmez.

---

## Subagents (Alt Ajanlar)

### Nedir?

Subagent'lar, Claude'un belirli görevler için **özelleşmiş yardımcılarıdır**. Her biri:
- Kendi context window'una sahip
- Özel system prompt'u var
- Araç erişimi kısıtlanabilir
- Farklı model kullanabilir

### Yerleşik Subagent'lar

| Agent | Amaç | Araçlar |
|-------|------|---------|
| **Explore** | Codebase keşfi, dosya arama | Read-only |
| **Plan** | Mimari planlama, strateji | Read-only |
| **General Purpose** | Karmaşık çok adımlı görevler | Tümü |

### Custom Subagent Oluşturma

**Yol:** `.claude/agents/` veya `~/.claude/agents/`

```markdown
---
name: security-auditor
description: Güvenlik açıklarını tespit eder
model: sonnet
tools:
  - Read
  - Grep
  - Glob
---

Sen uzman bir güvenlik denetçisisin. Görevin:

1. OWASP Top 10 açıklarını tara
2. Bağımlılık güvenliğini kontrol et
3. Hassas veri sızıntılarını tespit et

## Raporlama
Her bulgu için:
- CVE referansı (varsa)
- Risk seviyesi
- Düzeltme önerisi
```

### Subagent Yönetimi

```bash
/agents           # İnteraktif yönetim arayüzü
/agents list      # Mevcut agent'ları listele
```

### Multi-Agent Workflow Örneği

```
┌─────────────────┐
│   Orchestrator  │
│   (Ana Agent)   │
└────────┬────────┘
         │
    ┌────┴────┬────────┬────────┐
    ▼         ▼        ▼        ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
│Backend│ │Frontend│ │Tester │ │Security│
│ Agent │ │ Agent │ │ Agent │ │ Agent │
└───────┘ └───────┘ └───────┘ └───────┘
```

### Paralel Çalıştırma

```
"Bu 3 dosyayı paralel olarak analiz et:
1. auth.ts - güvenlik analizi
2. cache.ts - performans incelemesi  
3. utils.ts - tip kontrolü"
```

Claude otomatik olarak 3 subagent spawn eder.

---

## Hooks (Kancalar)

### Nedir?

Hook'lar, Claude'un workflow'undaki belirli noktalarda **otomatik tetiklenen eylemlerdir**.

### Hook Event'leri

| Event | Ne Zaman | Kullanım |
|-------|----------|----------|
| `SessionStart` | Oturum başlangıcı | Bağımlılık kontrolü |
| `PreToolUse` | Araç kullanmadan önce | İzin kontrolü, validasyon |
| `PostToolUse` | Araç kullandıktan sonra | Format, lint, test |
| `PreCompact` | Context sıkıştırma öncesi | Önemli bilgileri kaydet |
| `Stop` | Claude durduğunda | Cleanup, raporlama |

### Hook Konfigürasyonu

**Yol:** `.claude/settings.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint --fix $CLAUDE_FILE_PATH"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "./scripts/security-check.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook Tipleri

1. **command**: Shell komutu çalıştır
2. **prompt**: LLM ile değerlendir
3. **agent**: Agentic doğrulayıcı çalıştır

### Hook Çıktı Formatı

```json
{
  "block": true,           // Eylemi engelle (sadece PreToolUse)
  "message": "Neden",      // Kullanıcıya mesaj
  "feedback": "Bilgi",     // Engellemeyen geri bildirim
  "suppressOutput": true,  // Çıktıyı gizle
  "continue": false        // Devam et/etme
}
```

### Pratik Örnekler

**Otomatik Test Çalıştırma:**
```json
{
  "matcher": "Write",
  "hooks": [{
    "type": "command",
    "command": "if [[ $CLAUDE_FILE_PATH == *.test.* ]]; then npm test -- $CLAUDE_FILE_PATH; fi"
  }]
}
```

**Main Branch Koruma:**
```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command", 
    "command": "./scripts/check-branch.sh"
  }]
}
```

---

## Plugins (Eklentiler)

### Nedir?

Plugin'ler, Claude Code özelleştirmelerini **paketleyip paylaşmanın** standart yoludur:
- Slash commands
- Subagents
- Skills
- Hooks
- MCP servers
- LSP servers

### Plugin Yapısı

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Manifest (zorunlu)
├── commands/              # Slash komutları
│   └── deploy.md
├── agents/                # Custom agent'lar
│   └── reviewer.md
├── skills/                # Skills
│   └── my-skill/
│       └── SKILL.md
├── hooks/
│   └── hooks.json         # Hook konfigürasyonu
├── .mcp.json              # MCP server config
└── README.md
```

### plugin.json Örneği

```json
{
  "name": "my-awesome-plugin",
  "version": "1.0.0",
  "description": "Takım workflow'larını otomatize eder",
  "author": "your-name",
  "repository": "github.com/you/my-plugin"
}
```

### Plugin Kurulumu

```bash
/plugin install github.com/user/plugin-name
/plugin install plugin-name@marketplace-name
```

### Plugin Komutları

```bash
/plugin list              # Kurulu plugin'leri listele
/plugin enable <name>     # Plugin'i aktive et
/plugin disable <name>    # Plugin'i devre dışı bırak
/plugin uninstall <name>  # Plugin'i kaldır
/plugin update <name>     # Plugin'i güncelle
```

### Marketplace'ler

Plugin'ler marketplace'lerden keşfedilebilir:
- Anthropic resmi: `anthropics/skills`
- Topluluk: `cased/claude-code-plugins`

---

## MCP (Model Context Protocol)

### Nedir?

MCP, Claude'un dış araç ve servislere bağlanmasını sağlayan **standart protokoldür**.

### MCP vs Skills Farkı

- **MCP**: Araçları *sağlar* (veritabanı, API erişimi)
- **Skills**: Araçları *nasıl kullanacağını* öğretir

### MCP Konfigürasyonu

**Yol:** `.mcp.json`

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_TOKEN": "${SLACK_TOKEN}"
      }
    }
  }
}
```

### MCP Ekleme Komutları

```bash
# Stdio transport
claude mcp add github -- npx -y @modelcontextprotocol/server-github

# SSE transport
claude mcp add --transport sse myapi https://api.example.com/mcp

# Environment variable ile
claude mcp add --env SUPABASE_ACCESS_TOKEN=xxx supabase -- npx -y @supabase/mcp-server-supabase
```

### Popüler MCP Server'lar

| Server | Kullanım |
|--------|----------|
| `server-github` | GitHub repo, PR, issue yönetimi |
| `server-postgres` | PostgreSQL sorguları |
| `server-slack` | Slack mesajları, kanal yönetimi |
| `server-filesystem` | Dosya sistemi erişimi |
| `server-playwright` | Browser otomasyonu |

---

## Memory Yönetimi (CLAUDE.md)

### Hiyerarşi

```
┌─────────────────────────────────────────────┐
│  1. Enterprise Policy (en yüksek öncelik)   │  ← IT kuralları
├─────────────────────────────────────────────┤
│  2. Project Memory (./CLAUDE.md)            │  ← Proje talimatları
├─────────────────────────────────────────────┤
│  3. Project Rules (.claude/rules/)          │  ← Modüler kurallar
├─────────────────────────────────────────────┤
│  4. User Memory (~/.claude/CLAUDE.md)       │  ← Kişisel tercihler
└─────────────────────────────────────────────┘
```

### CLAUDE.md Best Practices

```markdown
# Proje: E-Ticaret API

## Tech Stack
- Node.js 20 + TypeScript strict mode
- PostgreSQL + Prisma ORM
- Express.js + Zod validasyon

## Kod Standartları
- Fonksiyonlar max 50 satır
- Her public fonksiyona JSDoc
- Error handling: custom AppError class kullan

## Test Kuralları
- Her feature için integration test
- Coverage minimum %80
- Test dosyaları: `*.test.ts`

## Yasak İşlemler
- ASLA production DB'ye direkt bağlanma
- API key'leri ASLA client-side'da tutma
- `any` tipi YASAK

## Sık Kullanılan Komutlar
- `npm run dev` - Development server
- `npm run test:watch` - Test watch mode
- `npm run db:migrate` - Migration çalıştır
```

### Quick Memory (#)

Konuşma sırasında anlık bellek ekleme:

```
# Bu projede always use yarn instead of npm
# Test dosyalarını __tests__ klasörüne koy
```

### Import Sistemi

```markdown
# CLAUDE.md

Proje genel bakış için @README.md
API dokümantasyonu için @docs/api.md
Veritabanı şeması için @prisma/schema.prisma
```

### Modüler Rules

**Yol:** `.claude/rules/`

```
.claude/rules/
├── typescript.md      # TS kuralları
├── testing.md         # Test kuralları
├── api/
│   └── security.md    # API güvenlik kuralları
└── frontend/
    └── components.md  # Component kuralları
```

**Glob pattern ile hedefleme:**

```markdown
---
globs: ["src/api/**/*.ts", "src/routes/**/*.ts"]
---

# API Güvenlik Kuralları

- Tüm endpoint'lerde JWT doğrulama
- Rate limiting zorunlu
- Input validasyonu Zod ile
```

### Memory Komutları

```bash
/memory           # Memory dosyalarını düzenle
/init             # Otomatik CLAUDE.md oluştur
/clear            # Context'i temizle (yeni görev için)
/compact          # Context'i sıkıştır
```

---

## Slash Commands (Eğik Çizgi Komutları)

### Yerleşik Komutlar

| Komut | Açıklama |
|-------|----------|
| `/help` | Yardım menüsü |
| `/clear` | Context'i temizle |
| `/compact` | Context'i sıkıştır |
| `/memory` | Memory yönetimi |
| `/init` | Proje başlat |
| `/agents` | Agent yönetimi |
| `/plugin` | Plugin yönetimi |
| `/cost` | Token kullanımı |
| `/plan` | Plan moduna geç |

### Custom Command Oluşturma

**Yol:** `.claude/commands/` veya `~/.claude/commands/`

```markdown
---
description: Yeni feature için branch ve boilerplate oluştur
argument-hint: <feature-name>
---

# Feature Scaffolding

1. `git checkout -b feature/$ARGUMENTS` ile yeni branch oluştur
2. `src/features/$ARGUMENTS/` klasör yapısını oluştur:
   - index.ts
   - types.ts
   - service.ts
   - controller.ts
   - *.test.ts
3. Basic boilerplate kod yaz
4. CLAUDE.md'ye feature notunu ekle
```

### Komut Argümanları

`$ARGUMENTS` placeholder'ı ile argüman al:

```
/feature user-authentication
```

---

## Best Practices ve Workflow

### Günlük Workflow

```
1. Oturum Başlat
   └─ Claude otomatik CLAUDE.md yükler

2. Görev Tanımla
   └─ Net ve spesifik prompt

3. Çalışma
   └─ /cost ile token takibi
   └─ Gerekirse subagent kullan

4. Checkpoint
   └─ Önemli karar? CLAUDE.md güncelle
   └─ Token > 50k? /compact

5. Görev Değişimi
   └─ Farklı konu? /clear

6. Oturum Sonu
   └─ Öğrenilenleri # ile kaydet
```

### Token Yönetimi

```bash
/cost                    # Mevcut kullanımı gör
# 50k token üstü → /compact
# Farklı görev → /clear
```

### Ne Zaman Ne Kullanmalı?

| Senaryo | Kullanılacak |
|---------|--------------|
| Tekrarlayan workflow | Slash Command |
| Domain uzmanlığı | Skill |
| Paralel iş | Subagent |
| Otomatik kalite kontrolü | Hook |
| Dış servis entegrasyonu | MCP |
| Takım paylaşımı | Plugin |
| Proje context'i | CLAUDE.md |

### Örnek Üretim Pipeline'ı

```
1. PM Spec Agent
   └─ Gereksinimi oku, spec yaz, READY_FOR_ARCH

2. Architect Agent  
   └─ Design doğrula, ADR yaz, READY_FOR_BUILD

3. Implementer Agent
   └─ Kod yaz, test yaz, DONE

4. Hooks
   └─ Auto-lint, auto-test, auto-format
```

---

## Özet: Çok Katmanlı Güç

Claude Code'un gücü, bu katmanların **birlikte çalışmasından** gelir:

```
CLAUDE.md (context) 
    + Skills (uzmanlık)
    + Subagents (paralel iş)
    + Hooks (otomasyon)
    + MCP (entegrasyon)
    + Plugins (paylaşım)
    ─────────────────────
    = Production-Ready AI Workflow
```

### Başlangıç Önerileri

1. **Önce CLAUDE.md'yi iyi yapılandır**
2. **Tekrarlayan işler için command yaz**
3. **Kalite için hook ekle**
4. **Karmaşık görevlerde subagent kullan**
5. **Dış servisler için MCP bağla**
6. **Her şeyi plugin olarak paketleyip paylaş**

---

## Kaynaklar

- [Claude Code Resmi Docs](https://code.claude.com/docs)
- [Agent Skills Rehberi](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Anthropic Skills Marketplace](https://github.com/anthropics/skills)
- [Awesome Claude Code](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Code Plugins](https://github.com/cased/claude-code-plugins)
