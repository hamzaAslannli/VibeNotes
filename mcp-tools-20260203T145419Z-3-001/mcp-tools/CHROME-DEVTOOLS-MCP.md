# Chrome DevTools MCP Server

> AI ajanlarının Chrome tarayıcısını doğal dil ile kontrol etmesini, debug etmesini ve performans analizi yapmasını sağlayan resmi Model Context Protocol sunucusu.

---

## 🎯 Genel Bakış

Chrome DevTools MCP, Chrome DevTools ekibi tarafından geliştirilen resmi bir MCP sunucusudur. AI kodlama asistanlarının (Gemini, Claude, Cursor, Copilot vb.) canlı bir Chrome tarayıcısını kontrol etmesini ve incelemesini sağlar. Puppeteer üzerine inşa edilmiştir ve tamamen yerel makinenizde çalışır.

### Temel Özellikler

- **Tarayıcı Otomasyonu**: Navigasyon, tıklama, form doldurma, ekran görüntüsü
- **Debugging**: Console mesajları, network istekleri, JavaScript değerlendirme
- **Performans Analizi**: Performance trace kaydetme ve analiz etme
- **Emülasyon**: CPU, network ve viewport emülasyonu
- **Doğal Dil Kontrolü**: Puppeteer kodu yazmadan tarayıcı kontrolü

### Neden Kullanmalı?

AI kodlama asistanları temel bir problemle karşı karşıya: ürettikleri kodun tarayıcıda nasıl çalıştığını göremiyorlar. Chrome DevTools MCP bu sorunu çözer - AI asistanları artık web sayfalarını doğrudan Chrome'da debug edebilir ve DevTools yeteneklerinden faydalanabilir.

---

## 🔧 Kurulum

### Temel Konfigürasyon

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"]
    }
  }
}
```

### Kiro için Kurulum

Kiro Settings > Configure MCP > Open Workspace veya User MCP Config:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"]
    }
  }
}
```

### Claude Code için Kurulum

```bash
claude mcp add chrome-devtools npx chrome-devtools-mcp@latest
```

### Cursor için Kurulum

Cursor Settings → MCP → New MCP Server:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest"]
    }
  }
}
```

### VS Code Copilot için Kurulum

```bash
code --add-mcp '{"name":"chrome-devtools","command":"npx","args":["chrome-devtools-mcp@latest"]}'
```

### Gemini CLI için Kurulum

```bash
# Proje bazlı
gemini mcp add chrome-devtools -- npx chrome-devtools-mcp@latest

# Global
gemini mcp add --global chrome-devtools -- npx chrome-devtools-mcp@latest
```

---

## 🛠️ Araçlar (Tools)

Chrome DevTools MCP, 6 kategoride 26 araç sunar:

### Kategori 1: Input Automation (7 araç)

#### click

Sayfadaki bir elemente tıklar.

```javascript
// Kullanım örneği (doğal dil)
"Sign in linkine tıkla"
"Submit butonuna bas"
```

#### drag

Bir elementi sürükleyip bırakır.

```javascript
"Slider'ı sağa sürükle"
"Dosyayı upload alanına sürükle"
```

#### fill

Tek bir input alanını doldurur.

```javascript
"Email alanına test@example.com yaz"
"Şifre alanını doldur: mypassword123"
```

#### fill_form

Birden fazla form alanını aynı anda doldurur.

```javascript
"Formu doldur: email test@example.com, password secret123, name John Doe"
```

#### handle_dialog

Alert, confirm veya prompt dialoglarını yönetir.

```javascript
"Çıkan alert'i kabul et"
"Confirm dialogunda Cancel'a bas"
```

#### hover

Bir elementin üzerine gelir (hover state).

```javascript
"Dropdown menünün üzerine gel"
"Tooltip'i görmek için info ikonuna hover yap"
```

#### upload_file

Dosya yükleme işlemi yapar.

```javascript
"profile.jpg dosyasını avatar upload alanına yükle"
```

---

### Kategori 2: Navigation (7 araç)

#### navigate_page

Belirtilen URL'ye gider.

```javascript
"https://example.com adresine git"
"localhost:3000'a navigate et"
```

#### new_page

Yeni bir tarayıcı sekmesi açar.

```javascript
"Yeni bir sekme aç"
```

#### list_pages

Açık olan tüm sekmeleri listeler.

```javascript
"Açık sekmeleri göster"
```

#### select_page

Belirli bir sekmeye geçiş yapar.

```javascript
"İkinci sekmeye geç"
"Google sekmesini seç"
```

#### close_page

Mevcut veya belirtilen sekmeyi kapatır.

```javascript
"Bu sekmeyi kapat"
```

#### navigate_page_history

Tarayıcı geçmişinde ileri/geri gider.

```javascript
"Bir sayfa geri git"
"İleri git"
```

#### wait_for

Belirli bir koşulun gerçekleşmesini bekler.

```javascript
"Sayfa yüklenene kadar bekle"
"Loading spinner kaybolana kadar bekle"
```

---

### Kategori 3: Debugging (4 araç)

#### evaluate_script

Sayfada JavaScript kodu çalıştırır.

```javascript
"document.title değerini al"
"Sayfadaki tüm linkleri say"
```

**Örnek Kullanım:**

```javascript
// AI'ın çalıştıracağı kod
const articles = document.querySelectorAll('.article-preview');
return articles.length;
```

#### list_console_messages

Console'daki mesajları listeler (log, warn, error).

```javascript
"Console'da hata var mı kontrol et"
"Console mesajlarını göster"
```

**Dönen Örnek:**

```
Error> Access to XMLHttpRequest at 'https://api.example.com' blocked by CORS policy
Warning> Deprecated API usage detected
Log> Application initialized
```

#### take_screenshot

Mevcut sayfanın ekran görüntüsünü alır.

```javascript
"Sayfanın ekran görüntüsünü al"
"Homepage'in screenshot'ını kaydet"
```

#### take_snapshot

Sayfanın DOM yapısının snapshot'ını alır.

```javascript
"Sayfanın DOM snapshot'ını al"
```

---

### Kategori 4: Network (2 araç)

#### list_network_requests

Yapılan tüm network isteklerini listeler.

```javascript
"Network isteklerini göster"
"Hangi API çağrıları yapıldı?"
```

**Dönen Örnek:**

```
https://example.com/ GET [success - 200]
https://api.example.com/data GET [failed - 404]
https://cdn.example.com/style.css GET [success - 200]
```

#### get_network_request

Belirli bir network isteğinin detaylarını getirir.

```javascript
"API isteğinin detaylarını göster"
"Login request'inin response'unu incele"
```

---

### Kategori 5: Performance (3 araç)

#### performance_start_trace

Performance trace kaydını başlatır.

```javascript
"Performance trace'i başlat"
"Sayfa performansını kaydetmeye başla"
```

#### performance_stop_trace

Performance trace kaydını durdurur ve sonuçları döner.

```javascript
"Performance kaydını durdur"
```

#### performance_analyze_insight

Performance trace'i analiz eder ve öneriler sunar.

```javascript
"Performance sonuçlarını analiz et"
"LCP neden yüksek, analiz et"
```

---

### Kategori 6: Emulation (3 araç)

#### emulate_cpu

CPU throttling uygular (yavaş cihaz simülasyonu).

```javascript
"4x CPU slowdown uygula"
"Düşük performanslı cihaz simüle et"
```

#### emulate_network

Network koşullarını simüle eder (3G, 4G, offline).

```javascript
"3G network simüle et"
"Yavaş bağlantı koşullarını test et"
```

#### resize_page

Viewport boyutunu değiştirir.

```javascript
"Viewport'u 375x667 yap (iPhone)"
"Tablet boyutuna geç"
```

---

## 📋 Kullanım Senaryoları

### 1. Kod Değişikliklerini Doğrulama

```
Prompt: "Yaptığın değişikliğin tarayıcıda çalıştığını doğrula"

AI:
1. navigate_page ile localhost'a gider
2. Değişikliği test eder
3. take_screenshot ile sonucu gösterir
```

### 2. Network ve Console Hatalarını Teşhis Etme

```
Prompt: "localhost:8080'deki bazı resimler yüklenmiyor. Ne oluyor?"

AI:
1. navigate_page ile sayfaya gider
2. list_console_messages ile hataları kontrol eder
3. list_network_requests ile başarısız istekleri bulur
4. Sorunu raporlar
```

### 3. Form Test Etme

```
Prompt: "Login formunu test et: email test@test.com, password 123456"

AI:
1. navigate_page ile login sayfasına gider
2. fill_form ile formu doldurur
3. click ile submit butonuna basar
4. Sonucu doğrular ve screenshot alır
```

### 4. Performance Audit

```
Prompt: "web.dev sitesinin LCP değerini kontrol et"

AI:
1. performance_start_trace başlatır
2. navigate_page ile siteye gider
3. performance_stop_trace ile kaydı durdurur
4. performance_analyze_insight ile analiz eder
5. LCP değerini ve önerileri raporlar
```

### 5. Responsive Tasarım Testi

```
Prompt: "Sayfayı mobil, tablet ve desktop boyutlarında test et"

AI:
1. resize_page ile 375x667 (mobil) ayarlar, screenshot alır
2. resize_page ile 768x1024 (tablet) ayarlar, screenshot alır
3. resize_page ile 1920x1080 (desktop) ayarlar, screenshot alır
4. Sonuçları karşılaştırır
```

### 6. Yavaş Bağlantı Testi

```
Prompt: "Sayfanın 3G bağlantıda nasıl yüklendiğini test et"

AI:
1. emulate_network ile 3G simüle eder
2. performance_start_trace başlatır
3. navigate_page ile sayfaya gider
4. Yükleme süresini ve performansı raporlar
```

---

## ⚙️ Konfigürasyon Seçenekleri

| Parametre | Açıklama | Varsayılan |
|-----------|----------|------------|
| `--headless` | Headless (UI'sız) mod | false |
| `--browserUrl`, `-u` | Çalışan Chrome'a bağlan | - |
| `--wsEndpoint`, `-w` | WebSocket endpoint | - |
| `--executablePath`, `-e` | Chrome executable yolu | Sistem Chrome |
| `--isolated` | Geçici profil kullan | false |
| `--userDataDir` | Chrome profil dizini | ~/.cache/chrome-devtools-mcp |
| `--channel` | Chrome kanalı (stable, beta, dev) | stable |
| `--viewport` | Başlangıç viewport boyutu | - |
| `--proxyServer` | Proxy sunucu | - |
| `--autoConnect` | Çalışan Chrome'a otomatik bağlan | false |
| `--acceptInsecureCerts` | Self-signed sertifikaları kabul et | false |
| `--categoryEmulation` | Emülasyon araçlarını dahil et | true |
| `--categoryPerformance` | Performance araçlarını dahil et | true |
| `--categoryNetwork` | Network araçlarını dahil et | true |

### Örnek Konfigürasyonlar

#### Headless Mod

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--headless"]
    }
  }
}
```

#### Özel Viewport

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--viewport", "1280x720"]
    }
  }
}
```

#### Çalışan Chrome'a Bağlanma

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--browserUrl", "http://127.0.0.1:9222"]
    }
  }
}
```

#### İzole Profil (Geçici)

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--isolated"]
    }
  }
}
```

---

## 🔗 Çalışan Chrome'a Bağlanma

### Otomatik Bağlantı (Chrome 145+)

1. Chrome'da `chrome://inspect/#remote-debugging` adresine gidin
2. Remote debugging'i etkinleştirin
3. MCP konfigürasyonuna `--autoConnect` ekleyin

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--autoConnect"]
    }
  }
}
```

### Manuel Bağlantı (Port Forwarding)

1. Chrome'u debug portu ile başlatın:

**macOS:**
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug
```

**Linux:**
```bash
google-chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug
```

**Windows:**
```bash
"C:\Program Files\Google\Chrome\Application\chrome.exe" ^
  --remote-debugging-port=9222 ^
  --user-data-dir=C:\temp\chrome-debug
```

2. MCP konfigürasyonunu güncelleyin:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--browserUrl", "http://127.0.0.1:9222"]
    }
  }
}
```

---

## ⚠️ Dikkat Edilmesi Gerekenler

### Güvenlik Uyarıları

```
⚠️ chrome-devtools-mcp, tarayıcı içeriğini MCP client'larına açar
⚠️ Hassas veya kişisel bilgileri paylaşmaktan kaçının
⚠️ --acceptInsecureCerts dikkatli kullanılmalı
```

### Yapılması Gerekenler ✅

```
✅ Kurulumu test etmek için basit bir prompt dene
✅ Hassas veriler için izole profil kullan (--isolated)
✅ Performance testleri için emülasyon araçlarını kullan
✅ Hata ayıklama için console ve network araçlarını birlikte kullan
✅ Screenshot'ları doğrulama için kullan
```

### Yapılmaması Gerekenler ❌

```
❌ Hassas bilgileri (şifreler, API key'ler) tarayıcıda bırakma
❌ Production ortamlarında debug portu açık bırakma
❌ Sandbox'lı ortamlarda Chrome başlatmaya çalışma
❌ Çok uzun süren işlemler için timeout ayarlamayı unutma
```

---

## 🐛 Sorun Giderme

### Chrome Başlamıyor

- Sandbox sorunu olabilir, `--no-sandbox` argümanı ekleyin
- Executable path'i kontrol edin
- Başka bir Chrome instance çalışıyor olabilir

### Bağlantı Kurulamıyor

- Port'un doğru olduğunu kontrol edin
- Firewall ayarlarını kontrol edin
- Chrome'un debug modunda başlatıldığından emin olun

### Araçlar Çalışmıyor

- MCP client'ı yeniden başlatın
- `npx chrome-devtools-mcp@latest --help` ile versiyonu kontrol edin
- Log dosyası için `--logFile` kullanın

---

## 📚 İlgili Kaynaklar

- **GitHub**: https://github.com/ChromeDevTools/chrome-devtools-mcp
- **Chrome DevTools Blog**: https://developer.chrome.com/blog/chrome-devtools-mcp
- **Tool Reference**: https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/tool-reference.md
- **Troubleshooting**: https://github.com/ChromeDevTools/chrome-devtools-mcp/blob/main/docs/troubleshooting.md
- **MCP Protokolü**: https://modelcontextprotocol.io

---

*Bu dokümantasyon, AI ajanlarının Chrome DevTools MCP sunucusunu etkin kullanması için hazırlanmıştır.*
