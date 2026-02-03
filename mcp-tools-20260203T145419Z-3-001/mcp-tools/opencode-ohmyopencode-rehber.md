# OpenCode + Oh-My-OpenCode v3.0 Kapsamlı Kullanım Rehberi

> **Sisyphus agent strongly recommends Opus 4.5 model. Using other models may result in significantly degraded experience.**

---

## 📋 İçindekiler

1. [Kurulum](#kurulum)
2. [Temel Kavramlar](#temel-kavramlar)
3. [Agent Sistemi](#agent-sistemi)
4. [Kullanım Modları](#kullanım-modları)
5. [Slash Komutları](#slash-komutları)
6. [Klavye Kısayolları](#klavye-kısayolları)
7. [Örnek Senaryolar](#örnek-senaryolar)
8. [Konfigürasyon](#konfigürasyon)
9. [İpuçları ve Best Practices](#ipuçları-ve-best-practices)

---

## 🚀 Kurulum

### OpenCode Kurulumu
```bash
# OpenCode kurulumu
curl -fsSL https://opencode.ai/install | bash

# Versiyon kontrolü
opencode --version  # 1.0.150 veya üzeri olmalı
```

### Oh-My-OpenCode Kurulumu
```bash
# Bun ile kurulum (önerilen)
bunx oh-my-opencode install

# veya npm ile
npm install -g oh-my-opencode
```

### Interaktif Kurulum (Subscription'lara göre)
```bash
# Claude + OpenAI + Gemini varsa
bunx oh-my-opencode install --no-tui --claude=max20 --openai=yes --gemini=yes --copilot=no

# Sadece Claude varsa
bunx oh-my-opencode install --no-tui --claude=yes --openai=no --gemini=no --copilot=no

# Sadece GitHub Copilot varsa
bunx oh-my-opencode install --no-tui --claude=no --gemini=no --copilot=yes
```

### Authentication
```bash
# Anthropic (Claude) authentication
opencode auth login
# Provider: Anthropic → Login method: Claude Pro/Max

# Google (Gemini) - Antigravity plugin ile
opencode auth login
# Provider: Google → Login method: OAuth with Google (Antigravity)

# OpenAI
opencode auth login
# Provider: OpenAI → Login method: ChatGPT Plus/Pro (Codex Subscription)
```

---

## 🧠 Temel Kavramlar

### Ultrawork Felsefesi
Oh-My-OpenCode'un temel felsefesi: **"Human in the loop = Bottleneck"**

Agent'ın işi bitene kadar çalışması, insan müdahalesini minimuma indirmek ve production-ready kod üretmek ana hedeftir.

### Anahtar Terimler

| Terim | Açıklama |
|-------|----------|
| **Sisyphus** | Ana orchestrator agent. Görevleri planlar, delege eder ve yönetir |
| **Prometheus** | Planlama agent'ı. Interview yapar, detaylı plan oluşturur |
| **Atlas** | Orchestration modu. Plan'ları execute eder |
| **Category** | Domain-specific task delegation (visual, business-logic, quick) |
| **Skill** | MCP server + özel bilgi içeren workflow paketi |
| **delegate_task** | Görev atama fonksiyonu |
| **Ultrawork (ulw)** | Maksimum performans modu |

---

## 🤖 Agent Sistemi

### Mevcut Agent'lar

| Agent | Model | Görev | Erişim |
|-------|-------|-------|--------|
| **Sisyphus** | claude-opus-4-5 | Ana orchestrator, plan & execute | Full write/edit |
| **Prometheus** | claude-opus-4-5 | Planlama, interview | Read-only |
| **Oracle** | openai/gpt-5.2 | Mimari, code review, debugging | Read-only |
| **Librarian** | opencode/big-pickle | Docs, OSS araştırma, GitHub search | Read-only |
| **Explore** | opencode/gpt-5-nano | Hızlı codebase grep | Read-only |
| **Multimodal-Looker** | google/gemini-3-flash | PDF, görsel analizi | Read-only |
| **Frontend-UI-UX** | Category ile | UI/UX development | Write capable |
| **Document-Writer** | Category ile | Dokümantasyon | Write capable |

### Agent Çağırma Yöntemleri

```
# Doğrudan prompt içinde
Ask @oracle to review this design and propose an architecture

Ask @librarian how this is implemented - why does the behavior keep changing?

Ask @explore for the policy on this feature
```

### delegate_task Kullanımı

```javascript
// Category ile (önerilen)
delegate_task(category="visual-engineering", prompt="Create a responsive dashboard component")

delegate_task(category="business-logic", prompt="Design the payment processing flow")

delegate_task(category="quick", prompt="Fix this typo", load_skills=["git-master"])

// Doğrudan agent ile
delegate_task(agent="oracle", prompt="Review this architecture")

// Background'da çalıştırma
delegate_task(agent="explore", background=true, prompt="Find auth implementations")
```

### Background Tasks

```javascript
// Background'da çalıştır
delegate_task(agent="explore", background=true, prompt="Find auth implementations")

// Devam et...

// Sonuçları al
background_output(task_id="bg_abc123")
```

---

## 🎯 Kullanım Modları

### 1. Ultrawork Mode (Hızlı & Otomatik)

**Ne zaman kullanılır:** Basit-orta karmaşıklıkta görevler, context açıklaması zahmetli olduğunda

```
# En basit kullanım - sadece "ulw" ekle
Refactor this authentication module. ulw

Fix all TypeScript errors in the project. ulw

Add dark mode support to the app. ulw
```

**Keyword'ler:**
- `ultrawork` veya `ulw` → Maksimum performans modu
- `search` / `find` / `찾아` / `検索` → Paralel explore + librarian
- `analyze` / `investigate` / `분석` / `調査` → Derin analiz modu
- `ultrathink` → Extended thinking modu

### 2. Prometheus + Atlas Mode (Planlı & Detaylı)

**Ne zaman kullanılır:** Karmaşık projeler, kesin verification gerektiğinde

```
# Adım 1: Tab tuşuna bas → Prometheus mode'a gir
# veya
@plan "I want to refactor the authentication system to NextAuth"

# Adım 2: Prometheus seni interview eder, sorular sorar
# Adım 3: Plan oluşturur → .sisyphus/plans/*.md dosyasını incele
# Adım 4: Planı onayla

# Adım 5: Execution başlat
/start-work
```

**Workflow:**
```
1. Press Tab → Enter Prometheus mode
2. Describe work → Prometheus interviews you
3. Confirm plan → Review .sisyphus/plans/*.md
4. Run /start-work → Atlas (Orchestrator) executes
```

### 3. Normal Mode (Basit Görevler)

**Ne zaman kullanılır:** Quick fix, basit sorular

```
# Direkt prompt yaz
Fix the typo in line 42 of auth.ts

What does this function do?

Add a console.log here
```

### Mod Seçim Karar Ağacı

```
Hızlı fix veya basit görev mi?
└─ EVET → Normal prompt yaz
└─ HAYIR → Context açıklaması zahmetli mi?
           └─ EVET → "ulw" kullan
           └─ HAYIR → Precise, verifiable execution gerekli mi?
                      └─ EVET → @plan + /start-work
                      └─ HAYIR → "ulw" kullan
```

---

## ⌨️ Slash Komutları

### Oh-My-OpenCode Komutları

| Komut | Açıklama | Kullanım |
|-------|----------|----------|
| `/start-work` | Prometheus planını execute et | Plan hazırsa |
| `/ralph-loop` | Self-referential development loop | `/ralph-loop "Build REST API" --max-iterations=50` |
| `/ulw-loop` | Ultrawork loop - intensive coding | `/ulw-loop "Complete all tasks"` |
| `/cancel-ralph` | Aktif Ralph Loop'u iptal et | Loop çalışırken |
| `/init-deep` | Hierarchical AGENTS.md oluştur | `/init-deep [--max-depth=N]` |
| `/refactor` | LSP + AST-grep ile intelligent refactoring | `/refactor` |
| `/commit` | Git commit (git-master skill ile) | `/commit "feat: add auth"` |

### OpenCode Built-in Komutları

| Komut | Kısayol | Açıklama |
|-------|---------|----------|
| `/undo` | `Ctrl+X, U` | Son mesajı geri al (dosya değişiklikleri dahil) |
| `/redo` | `Ctrl+X, R` | Geri alınan işlemi yeniden yap |
| `/share` | - | Session'ı paylaşılabilir hale getir |
| `/help` | `Ctrl+X, H` | Yardım menüsü |
| `/init` | - | Proje başlat |
| `/editor` | - | External editor'da düzenle |
| `/export` | - | Conversation'ı export et |

---

## ⌨️ Klavye Kısayolları

### Leader Key: `Ctrl+X`

| Kısayol | Aksiyon |
|---------|---------|
| `Ctrl+X, N` | Yeni session başlat |
| `Ctrl+X, U` | Undo (son mesajı geri al) |
| `Ctrl+X, R` | Redo |
| `Ctrl+X, H` | Help/Command palette |
| `Ctrl+X, S` | Session listesi |
| `Tab` | Agent mode değiştir (Prometheus'a geç) |
| `Shift+Enter` | Multiline input |
| `Ctrl+C` | İşlemi iptal et |

### Navigation

| Kısayol | Aksiyon |
|---------|---------|
| `Ctrl+G, Home` | İlk mesaja git |
| `Ctrl+Alt+G, End` | Son mesaja git |
| `Ctrl+A` | Satır başına git |
| `Ctrl+E` | Satır sonuna git |
| `Ctrl+K` | Cursor'dan sonrasını sil |

---

## 📚 Örnek Senaryolar

### Senaryo 1: Yeni Feature Geliştirme (Basit)

```bash
# Proje klasörüne git
cd ~/my-project

# OpenCode başlat
opencode

# Prompt gir
> Add user authentication with JWT tokens. ulw
```

Sisyphus otomatik olarak:
1. Codebase'i analiz eder
2. Gerekli dosyaları belirler
3. Implementasyon yapar
4. Test eder
5. Commit atar

### Senaryo 2: Kompleks Refactoring (Planlı)

```bash
# OpenCode başlat
opencode

# Tab tuşuna bas → Prometheus mode
> I need to migrate our authentication from sessions to JWT, 
  update all API endpoints, and add refresh token support

# Prometheus interview yapar:
# - "What's your current session implementation?"
# - "Do you need backward compatibility?"
# - "What's the token expiry policy?"

# Cevapla, plan oluşsun
# Plan'ı incele: .sisyphus/plans/auth-migration.md

# Execute et
/start-work
```

### Senaryo 3: Bug Debugging

```bash
> The payment module throws "undefined is not a function" error 
  when processing refunds. Ask @oracle to analyze and fix this. ulw
```

Oracle mimari analiz yapar, Sisyphus fix'i uygular.

### Senaryo 4: Documentation & Research

```bash
> Ask @librarian how Next.js 15 handles server components differently 
  from version 14, and show me examples from their official repo
```

Librarian:
- GitHub'da arar
- Official docs'u kontrol eder
- Implementation örnekleri bulur

### Senaryo 5: Code Review & Architecture

```bash
> Ask @oracle to review our payment processing architecture 
  and suggest improvements for handling high concurrency
```

### Senaryo 6: Parallel Background Tasks

```bash
> I need to refactor the user module. 
  First, have @explore find all user-related files in background,
  have @librarian check best practices for user management in background,
  then implement the changes. ulw
```

### Senaryo 7: Ralph Loop ile Autonomous Development

```bash
# Proje yap ve bırak
/ralph-loop "Build a complete REST API with:
- User CRUD
- Authentication  
- Rate limiting
- Tests
Output <promise>COMPLETE</promise> when done." --max-iterations=50

# Ya da ultrawork loop
/ulw-loop "Fix all eslint warnings and add missing type annotations"
```

### Senaryo 8: UI/UX Development

```bash
> Create a beautiful dashboard with:
- Sales chart
- User statistics
- Recent activity feed
Use shadcn/ui and Tailwind CSS. ulw
```

delegate_task(category="visual-engineering", ...) otomatik çağrılır.

### Senaryo 9: Git Workflow

```bash
# Atomic commit
> Commit these changes with a proper conventional commit message. 
  delegate_task(category='quick', load_skills=['git-master'])

# veya slash command
/commit "feat(auth): add JWT token refresh"
```

### Senaryo 10: Browser Automation

```bash
> Test the login flow in browser:
1. Go to localhost:3000
2. Fill email and password
3. Click submit
4. Verify redirect to dashboard
Use playwright skill. ulw
```

---

## ⚙️ Konfigürasyon

### Config Dosyası Konumları

```
~/.config/opencode/oh-my-opencode.json     # Global (user-wide)
.opencode/oh-my-opencode.json              # Project-specific (öncelikli)
```

### Tam Config Örneği

```jsonc
{
  "$schema": "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json",
  
  // Agent Konfigürasyonları
  "agents": {
    "oracle": {
      "model": "openai/gpt-5.2",
      "temperature": 0.3
    },
    "librarian": {
      "model": "anthropic/claude-sonnet-4-5",
      "prompt_append": "Always provide GitHub permalinks as evidence."
    },
    "explore": {
      "model": "opencode/gpt-5-nano",
      "temperature": 0.5
    },
    "multimodal-looker": {
      "model": "google/gemini-3-flash",
      "disable": false
    }
  },
  
  // Devre dışı agent'lar
  "disabled_agents": [],
  
  // Category Konfigürasyonları
  "categories": {
    "quick": {
      "model": "opencode/gpt-5-nano"
    },
    "visual-engineering": {
      "model": "google/gemini-3-pro",
      "temperature": 0.8,
      "prompt_append": "Use shadcn/ui components and Tailwind CSS."
    },
    "business-logic": {
      "model": "anthropic/claude-sonnet-4-5",
      "temperature": 0.2
    },
    // Custom category
    "turkish-writer": {
      "model": "google/gemini-3-flash",
      "temperature": 0.5,
      "prompt_append": "You are a Turkish technical writer. Maintain a friendly and clear tone."
    }
  },
  
  // Devre dışı skill'ler
  "disabled_skills": [],
  
  // Devre dışı hook'lar
  "disabled_hooks": [
    // "comment-checker",
    // "startup-toast"
  ],
  
  // Devre dışı MCP'ler
  "disabled_mcps": [],
  
  // Background Task Concurrency
  "background_task": {
    "defaultConcurrency": 5,
    "providerConcurrency": {
      "anthropic": 3,
      "openai": 5,
      "google": 10
    },
    "modelConcurrency": {
      "anthropic/claude-opus-4-5": 2,
      "google/gemini-3-flash": 10
    }
  },
  
  // Ralph Loop
  "ralph_loop": {
    "enabled": true,
    "default_max_iterations": 100
  },
  
  // LSP Konfigürasyonu
  "lsp": {
    "typescript-language-server": {
      "command": ["typescript-language-server", "--stdio"],
      "extensions": [".ts", ".tsx"],
      "priority": 10
    },
    "pylsp": {
      "command": ["pylsp"],
      "extensions": [".py"],
      "priority": 10
    }
  },
  
  // Deneysel Özellikler
  "experimental": {
    "preemptive_compaction_threshold": 0.85,
    "truncate_all_tool_outputs": false,
    "aggressive_truncation": false,
    "auto_resume": true,
    "dcp_for_compaction": false
  }
}
```

### Mevcut Hook'lar

| Hook | Varsayılan | Açıklama |
|------|------------|----------|
| `todo-continuation-enforcer` | ✅ | TODO'lar bitene kadar devam ettirir |
| `context-window-monitor` | ✅ | Token kullanımını izler |
| `session-recovery` | ✅ | Hata sonrası session kurtarma |
| `session-notification` | ✅ | Agent idle olunca OS notification |
| `comment-checker` | ✅ | Fazla yorum yazımını engeller |
| `keyword-detector` | ✅ | ulw, search gibi keyword'leri algılar |
| `preemptive-compaction` | ✅ | Token limit yaklaşınca compact eder |
| `ralph-loop` | ✅ | Ralph loop yönetimi |
| `auto-update-checker` | ✅ | Güncelleme kontrolü |
| `startup-toast` | ✅ | Başlangıç bildirimi |

---

## 💡 İpuçları ve Best Practices

### 1. Doğru Modu Seç

```
Basit görev → Normal prompt
Orta karmaşıklık → ulw
Kompleks proje → Prometheus + /start-work
Autonomous loop → /ralph-loop veya /ulw-loop
```

### 2. Agent'ları Doğru Kullan

- **Oracle**: Mimari kararlar, debugging, strategy
- **Librarian**: External library/framework soruları
- **Explore**: "Bu nerede?" soruları, pattern matching

### 3. Background Tasks ile Paralelleştir

```
# Paralel araştırma
delegate_task(agent="explore", background=true, prompt="Find all auth files")
delegate_task(agent="librarian", background=true, prompt="Check JWT best practices")

# Devam et, sonuçlar gelince kullan
```

### 4. Categories ile Token Tasarrufu

```javascript
// Basit görevler için ucuz model
delegate_task(category="quick", load_skills=["git-master"], prompt="Commit this")

// UI işleri için visual-engineering
delegate_task(category="visual-engineering", prompt="Create dashboard")
```

### 5. AGENTS.md Kullan

Proje root'una `AGENTS.md` ekle:
```markdown
# Project Rules

## Build
- Run `pnpm install` before development
- Use `pnpm dev` for development server

## Code Style
- Use TypeScript strict mode
- Follow conventional commits

## Pitfalls
- Never import from 'lodash', use 'lodash-es'
```

### 6. Skills ile Özelleştir

`.opencode/skills/my-skill/SKILL.md`:
```yaml
---
name: my-skill
description: My custom workflow
mcp:
  my-mcp:
    command: npx
    args: ["-y", "my-mcp-server"]
---

# My Skill Instructions

This content will be injected into the agent's system prompt.
```

### 7. Token Limit Yönetimi

```jsonc
{
  "experimental": {
    "preemptive_compaction_threshold": 0.85,  // %85'te compact et
    "aggressive_truncation": true,  // Agresif truncation
    "dcp_for_compaction": true  // Dynamic Context Pruning
  }
}
```

---

## 🔧 Troubleshooting

### "Agent not working properly"
- Opus 4.5 model kullandığından emin ol
- `opencode models` ile mevcut modelleri kontrol et

### "Session interrupted"
- Aynı session'da `continue` yaz
- Veya `/start-work` ile devam et

### "Token limit exceeded"
- `preemptive_compaction_threshold` değerini düşür
- `aggressive_truncation: true` yap

### "Background task not completing"
- `background_output(task_id="...")` ile kontrol et
- `background_task.modelConcurrency` limitlerine bak

---

## 📚 Faydalı Kaynaklar

- [Oh-My-OpenCode GitHub](https://github.com/code-yeongyu/oh-my-opencode)
- [Oh-My-OpenCode Docs](https://ohmyopencode.com/)
- [OpenCode Docs](https://opencode.ai/docs/)
- [Ultrawork Manifesto](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/ultrawork-manifesto.md)
- [Orchestration Guide](https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/orchestration-guide.md)

---

> **Son Not**: Oh-My-OpenCode sürekli gelişiyor. En güncel bilgiler için GitHub releases sayfasını takip et: `oh-my-opencode@latest`
