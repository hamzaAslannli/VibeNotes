# OpenCode, Oh-My-OpenCode ve AGENTS.md Kapsamlı Rehberi

> **Araştırma Tarihi:** Ocak 2026  
> **Kaynaklar:** GitHub Blog (2500+ repo analizi), OpenAI Codex Docs, Builder.io, Factory.ai, agents.md resmi sitesi

---

## 📑 İçindekiler

1. [OpenCode Nedir?](#1-opencode-nedir)
2. [Oh-My-OpenCode Nedir?](#2-oh-my-opencode-nedir)
3. [AGENTS.md Nedir?](#3-agentsmd-nedir)
4. [AGENTS.md Dosya Hiyerarşisi](#4-agentsmd-dosya-hiyerarşisi)
5. [AGENTS.md Nasıl Yazılır?](#5-agentsmd-nasıl-yazılır)
6. [2500+ Repo Analizinden Çıkan Dersler](#6-2500-repo-analizinden-çıkan-dersler)
7. [Java/Spring Boot için AGENTS.md](#7-javaspring-boot-için-agentsmd)
8. [Best Practices](#8-best-practices)
9. [Nested AGENTS.md Kullanımı](#9-nested-agentsmd-kullanımı)
10. [Oh-My-OpenCode Konfigürasyonu](#10-oh-my-opencode-konfigürasyonu)
11. [Sık Yapılan Hatalar](#11-sık-yapılan-hatalar)
12. [Kaynaklar](#12-kaynaklar)

---

## 1. OpenCode Nedir?

**OpenCode**, terminal tabanlı açık kaynaklı bir AI coding agent'ıdır. Cursor veya Claude Code'un terminal versiyonu olarak düşünülebilir.

### Temel Özellikler

| Özellik | Açıklama |
|---------|----------|
| **Multi-Provider** | Anthropic, OpenAI, Google, vb. destekler |
| **MCP Entegrasyonu** | Model Context Protocol ile araç genişletme |
| **LSP Araçları** | Language Server Protocol ile kod analizi |
| **Agent Sistemi** | Primary + Subagent mimarisi |
| **Plugin Mimarisi** | Genişletilebilir yapı |

### Agent Türleri

**Primary Agents:**
- `Build` - Varsayılan agent, tüm araçlara erişim
- `Plan` - Analiz ve planlama için (değişiklik yapmaz)

**Subagents:**
- `General` - Genel amaçlı araştırma
- `Explore` - Hızlı codebase keşfi

### Temel Komutlar

```bash
# OpenCode başlat
opencode

# Belirli dizinde başlat
opencode --cd /path/to/project

# Agent'lar arası geçiş
Tab tuşu veya @ mention
```

---

## 2. Oh-My-OpenCode Nedir?

**Oh-My-OpenCode**, OpenCode için "batteries-included" bir plugin'dir. Yaratıcısı @code-yeongyu tarafından $24,000 değerinde token harcanarak optimize edilmiştir.

### Ana Agent: Sisyphus

- **Model:** Claude Opus 4.5 (32k thinking budget)
- **Rol:** "Engineering Manager" - görevleri delege eder
- **Aktivasyon:** `ultrawork` veya `ulw` keyword'ü

### Specialized Subagent'lar

| Agent | Model | Görev |
|-------|-------|-------|
| `oracle` | GPT-5.2 | Mimari, kod review, strateji |
| `librarian` | Claude Sonnet / Gemini Flash | Multi-repo analiz, dokümantasyon |
| `explore` | Grok / Gemini Flash / Haiku | Hızlı codebase keşfi |
| `frontend-ui-ux-engineer` | Gemini 3 Pro | UI/UX geliştirme |
| `document-writer` | Gemini Flash | Teknik yazım |
| `multimodal-looker` | Gemini Flash | PDF, görsel analizi |

### Dahili MCP'ler

- **Context7** - Dokümantasyon araması
- **grep.app** - GitHub kod araması
- **Exa** - Web araması

### Magic Keywords

| Keyword | Açıklama |
|---------|----------|
| `ultrawork` / `ulw` | Tüm özellikleri aktive eder |
| `ultrathink` | Derin düşünme modu |
| `@oracle` | GPT-5.2 ile mimari danışmanlık |
| `@librarian` | Dokümantasyon araması |

---

## 3. AGENTS.md Nedir?

**AGENTS.md**, AI coding agent'ları için standart bir format dosyasıdır. 60,000+ açık kaynak projede kullanılmaktadır.

### README.md vs AGENTS.md

| README.md | AGENTS.md |
|-----------|-----------|
| İnsanlar için | AI Agent'lar için |
| Proje açıklaması | Build komutları |
| Kurulum rehberi | Kod stili kuralları |
| Katkı rehberi | Sınırlar ve kısıtlamalar |
| Genel bilgi | Detaylı teknik context |

### Destekleyen Araçlar

- OpenAI Codex
- GitHub Copilot
- Google Jules
- Cursor
- Amp
- Factory
- Aider
- goose
- OpenCode
- Zed
- Warp
- VS Code
- Windsurf
- RooCode
- Gemini CLI
- Kilo Code

---

## 4. AGENTS.md Dosya Hiyerarşisi

### Öncelik Sırası (Yukarıdan Aşağıya)

```
1. ~/.codex/AGENTS.md              # Global (tüm projeler için)
       ↓
2. project-root/AGENTS.md          # Proje kökü
       ↓
3. src/module/AGENTS.md            # Modül seviyesi
       ↓
4. src/module/submodule/AGENTS.md  # Alt modül seviyesi
       ↓
5. User chat prompt                # Kullanıcı prompt'u (her şeyi override eder)
```

### Temel Kurallar

1. **En yakın dosya öncelik alır** - Düzenlenen dosyaya en yakın AGENTS.md
2. **Dosyalar birleştirilir (merge)** - Üst yazılmaz, eklenir
3. **Override dosyası** - `AGENTS.override.md` geçici değişiklikler için kullanılır
4. **Boyut limiti** - Varsayılan 32KB (ayarlanabilir)

### Örnek Proje Yapısı

```
project-root/
├── AGENTS.md                           # Proje geneli kurallar
├── AGENTS.override.md                  # Geçici override (opsiyonel)
├── src/
│   ├── frontend/
│   │   └── AGENTS.md                   # Frontend özel kurallar
│   ├── backend/
│   │   └── AGENTS.md                   # Backend özel kurallar
│   └── shared/
│       └── AGENTS.md                   # Shared lib kuralları
└── services/
    └── payments/
        └── AGENTS.override.md          # Payments servisi override
```

---

## 5. AGENTS.md Nasıl Yazılır?

### Temel Şablon

```markdown
# AGENTS.md

## Project Overview
[Projenin ne yaptığı, domain bilgisi - 1-2 paragraf]

## Tech Stack
- [Teknoloji 1 + versiyon]
- [Teknoloji 2 + versiyon]
- [Build tool]

## Commands
- Build: `[build komutu]`
- Test: `[test komutu]`
- Single test: `[tek test komutu]`
- Lint: `[lint komutu]`

## Project Structure
```
src/
├── module1/    → [Açıklama]
├── module2/    → [Açıklama]
└── module3/    → [Açıklama]
```

## Code Style
[Concrete örneklerle göster]

## Boundaries
- ✅ **Always:** [Her zaman yapılması gerekenler]
- ⚠️ **Ask First:** [Onay alınması gerekenler]
- 🚫 **Never:** [Asla yapılmaması gerekenler]
```

### 6 Temel Bölüm

GitHub'ın 2500+ repo analizine göre başarılı AGENTS.md dosyaları şu 6 alanı kapsar:

| Alan | İçerik |
|------|--------|
| **Commands** | Build, test, lint komutları (flag'lerle birlikte) |
| **Testing** | Test framework, coverage hedefi, test yapısı |
| **Project Structure** | Klasör yapısı, modüller, veri akışı |
| **Code Style** | Naming conventions, formatting, patterns |
| **Git Workflow** | Branch stratejisi, commit conventions, PR kuralları |
| **Boundaries** | Yapılması/yapılmaması gerekenler |

---

## 6. 2500+ Repo Analizinden Çıkan Dersler

### Başarısız vs Başarılı Agent Tanımları

**❌ Başarısız:**
```markdown
You are a helpful coding assistant.
```

**✅ Başarılı:**
```markdown
You are a test engineer who writes tests for React components, 
follows these examples, and never modifies source code.
```

### Anahtar Bulgular

1. **Komutları erken yaz** - İlk bölümlerde, flag'lerle birlikte
2. **Açıklama değil, örnek göster** - 1 kod snippet > 3 paragraf açıklama
3. **Net sınırlar koy** - "Never commit secrets" en yaygın faydalı kısıtlama
4. **Stack'i spesifik yaz** - "React 18 with TypeScript, Vite, and Tailwind CSS" ✅ / "React project" ❌
5. **6 temel alanı kapsa** - Commands, Testing, Structure, Style, Git, Boundaries

---

## 7. Java/Spring Boot için AGENTS.md

### Önerilen Yapı

```markdown
# AGENTS.md - Java/Spring Boot Project

## Code Formatting
- Indentation: 4 spaces
- Line Length: Maximum 120 characters
- Encoding: UTF-8

## Java Style
- Use descriptive names for classes, methods, and variables
- Avoid `var` keyword, prefer explicit types
- All method parameters should be `final`
- Prefer immutability
- Avoid magic numbers and strings; use constants
- Check emptiness and nullness before operations
- Prefer early returns
- Avoid else statements when not necessary

## Lombok Annotations
- Use `@RequiredArgsConstructor` for dependency injection
- Use `@Slf4j` for logging
- Use `@Builder(setterPrefix = "with")` for complex objects
- Avoid `@Data`; prefer `@Getter` and `@Setter` for granular control

## Spring Annotations
- `@Service` - Business logic classes
- `@Repository` - Data access classes
- `@RestController` - Web controllers
- `@Component` - Generic Spring components
- `@Configuration` - Configuration classes
- Prefer constructor injection over `@Autowired`
- `@Transactional` - Only at Service class level

## Testing
- Use JUnit 5 for unit and integration testing
- Use Mockito for mocking dependencies
- Use `@WebMvcTest` for controller tests
- Use `@SpringBootTest` for integration tests
- Use `given/when/then` structure in test methods

## Logging
- Use `@Slf4j` annotation from Lombok
- Log levels: DEBUG, INFO, WARN, ERROR
- Include contextual information (request IDs, user IDs)
- Never log sensitive information
- Use placeholders: `log.info("User: {}", userId)`

## Boundaries
- ✅ **Always:** Use Optional for nullable returns, write tests, use DI
- ⚠️ **Ask First:** Database schema changes, new dependencies
- 🚫 **Never:** Use static methods for business logic, commit secrets
```

---

## 8. Best Practices

### 1. Komutları Erken ve Detaylı Yaz

```markdown
## Commands
- Build: `mvn clean compile`
- Test all: `mvn test`
- Test single class: `mvn test -Dtest=MyTest`
- Test single method: `mvn test -Dtest=MyTest#myMethod`
- Test module: `mvn test -pl :module-name`
- Lint: `mvn checkstyle:check`
- Format: `mvn spotless:apply`
```

### 2. Açıklama Değil, Örnek Göster

```markdown
## Code Style Examples

### ✅ Good
```java
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }
}
```

### ❌ Bad
```java
public class UserService {
    @Autowired
    private UserRepository userRepository;
    
    public User findById(Long id) {
        return userRepository.findById(id).get(); // NPE riski!
    }
}
```
```

### 3. Boundaries Formatı (Emoji ile)

```markdown
## Boundaries

- ✅ **Always do:**
  - Use `@RequiredArgsConstructor` for DI
  - Write tests for new features
  - Use Optional for nullable returns
  - Log state changes

- ⚠️ **Ask first:**
  - Database schema changes
  - Adding new dependencies
  - Modifying CI/CD config
  - Changing public APIs

- 🚫 **Never do:**
  - Commit secrets or API keys
  - Use static methods for business logic
  - Modify state directly (use managers)
  - Skip tests
```

### 4. File-Scoped Commands

```markdown
## File-Scoped Commands (Faster Feedback)
- Type check single: `mvn compile -Dfile=path/to/File.java`
- Format single: `mvn spotless:apply -DspotlessFiles=path/to/File.java`
- Test single: `mvn test -Dtest=ClassName#methodName`
```

### 5. Legacy Dosyaları İşaretle

```markdown
## Legacy Code (Avoid as Examples)
- `src/old/LegacyService.java` - Old patterns, being refactored
- `src/deprecated/*` - Deprecated, do not extend
```

---

## 9. Nested AGENTS.md Kullanımı

### Ne Zaman Kullanılır?

- **Monorepo'lar** - Her paket için farklı kurallar
- **Farklı tech stack'ler** - Frontend vs Backend
- **Farklı takımlar** - Payments vs Auth
- **Özel prosedürler** - Security-critical modüller

### Örnek: Modül Seviyesi AGENTS.md

```markdown
# src/payments/AGENTS.md

## Module: Payments Service

> ⚠️ **SECURITY CRITICAL** - Extra care required

## Specific Rules
- Use `make test-payments` instead of `npm test`
- Never rotate API keys without notifying security channel
- All changes require security review

## Boundaries
- 🚫 **Never:** Log credit card numbers, store PII unencrypted
```

---

## 10. Oh-My-OpenCode Konfigürasyonu

### Dosya Lokasyonları

```
1. .opencode/oh-my-opencode.json     # Proje seviyesi (öncelikli)
2. ~/.config/opencode/oh-my-opencode.json  # Kullanıcı seviyesi
```

### Örnek Konfigürasyon

```jsonc
{
  "$schema": "https://oh-my-opencode.sisyphuslabs.ai/config.json",
  
  // Sisyphus ana agent ayarları
  "sisyphus": {
    "disabled": false,
    "planner_enabled": true,
    "default_builder_enabled": false
  },
  
  // Agent override'ları
  "agents": {
    "oracle": {
      "model": "openai/gpt-5.2",
      "temperature": 0.1
    },
    "librarian": {
      "model": "anthropic/claude-sonnet-4-5"
    }
  },
  
  // Devre dışı bırakılacak hook'lar
  "disabled_hooks": [
    "comment-checker",
    "startup-toast"
  ],
  
  // Devre dışı bırakılacak MCP'ler
  "disabled_mcps": [],
  
  // Claude Code uyumluluk katmanı
  "claude_code": {
    "mcp": true,
    "commands": true,
    "skills": true,
    "hooks": true,
    "agents": true
  },
  
  // Background task concurrency
  "background_tasks": {
    "defaultConcurrency": 3,
    "providerConcurrency": {
      "anthropic": 2,
      "openai": 3
    }
  }
}
```

### Kullanılabilir Hook'lar

| Hook | Açıklama |
|------|----------|
| `todo-continuation-enforcer` | TODO'lar bitene kadar devam ettirir |
| `context-window-monitor` | Context window yönetimi |
| `session-recovery` | Session hata kurtarma |
| `comment-checker` | Gereksiz yorum kontrolü |
| `think-mode` | Otomatik thinking mode |
| `ralph-loop` | Task tamamlanana kadar döngü |
| `preemptive-compaction` | Proaktif context sıkıştırma |

---

## 11. Sık Yapılan Hatalar

### ❌ Yapma

1. **Çok genel tanımlar**
   ```markdown
   You are a helpful assistant.  # ❌ Çok genel
   ```

2. **Sadece araç isimleri**
   ```markdown
   - Use Maven  # ❌ Flag'ler nerede?
   ```

3. **Açıklama paragrafları**
   ```markdown
   We prefer to use immutable objects because...  # ❌ Örnek göster
   ```

4. **Eksik sınırlar**
   ```markdown
   # Boundaries bölümü yok  # ❌ Agent ne yapmaması gerektiğini bilmiyor
   ```

### ✅ Yap

1. **Spesifik persona**
   ```markdown
   You are a test engineer who writes JUnit 5 tests for Spring Boot services.
   ```

2. **Komutlar flag'lerle**
   ```markdown
   - Test: `mvn test -Dtest=ClassName#methodName -DfailIfNoTests=false`
   ```

3. **Kod örnekleri**
   ```markdown
   ### ✅ Good
   ```java
   // Actual code example
   ```
   ```

4. **Net sınırlar**
   ```markdown
   - 🚫 **Never:** Modify `ActiveConflict` state directly
   ```

---

## 12. Kaynaklar

### Resmi Dokümantasyonlar
- [agents.md](https://agents.md/) - Resmi AGENTS.md sitesi
- [OpenAI Codex Docs](https://developers.openai.com/codex/guides/agents-md) - Codex rehberi
- [OpenCode Docs](https://opencode.ai/docs/agents/) - OpenCode agent dokümantasyonu

### Makaleler ve Analizler
- [GitHub Blog - 2500+ Repo Analizi](https://github.blog/ai-and-ml/github-copilot/how-to-write-a-great-agents-md-lessons-from-over-2500-repositories/)
- [Builder.io - Best Tips](https://www.builder.io/blog/agents-md)
- [Factory.ai Docs](https://docs.factory.ai/cli/configuration/agents-md)
- [Java/Spring Boot Guide](https://josealopez.dev/en/blog/agents-md-java-spring-boot)

### GitHub Repositories
- [agentsmd/agents.md](https://github.com/agentsmd/agents.md) - Resmi repo
- [code-yeongyu/oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) - Oh-My-OpenCode
- [openai/codex](https://github.com/openai/codex) - OpenAI Codex

### Örnek AGENTS.md Dosyaları
- [agentsmd.io/examples](https://agentsmd.io/examples) - Topluluk örnekleri

---

## 📝 Özet Checklist

Yeni bir AGENTS.md yazarken kontrol et:

- [ ] **Project Overview** - Domain bilgisi var mı?
- [ ] **Tech Stack** - Versiyonlarla birlikte mi?
- [ ] **Commands** - Flag'lerle birlikte mi?
- [ ] **Project Structure** - Klasör açıklamaları var mı?
- [ ] **Code Style** - Kod örnekleri var mı?
- [ ] **Testing** - Test komutları ve yapısı var mı?
- [ ] **Git Workflow** - Branch/commit kuralları var mı?
- [ ] **Boundaries** - ✅/⚠️/🚫 formatında mı?
- [ ] **Legacy warnings** - Kaçınılacak dosyalar işaretli mi?

---

*Bu doküman Ocak 2026'da hazırlanmıştır. Güncel bilgiler için kaynak linkleri kontrol edilmelidir.*
