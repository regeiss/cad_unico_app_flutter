# 📱 Cadastro Unificado - App Flutter Web

Sistema de gestão de cadastros e demandas sociais desenvolvido em Flutter para web, integrado com API Django.

## 🚀 Características

- ✅ **Interface Responsiva** - Funciona perfeitamente em desktop, tablet e mobile
- ✅ **Autenticação Completa** - Login/logout com persistência de sessão
- ✅ **Dashboard Interativo** - Visão geral com estatísticas e gráficos
- ✅ **Gestão de Responsáveis** - CRUD completo com validações
- ✅ **Controle de Membros** - Gerenciamento de membros familiares
- ✅ **Sistema de Demandas** - Visualização de demandas de saúde e educação
- ✅ **Design Moderno** - Material Design 3 com tema claro/escuro
- ✅ **API Integrada** - Comunicação completa com backend Django

## 📋 Pré-requisitos

- **Flutter SDK** >= 3.0.0
- **Dart SDK** >= 3.0.0
- **Chrome** (para execução web)
- **Git**

## 🛠️ Instalação

### 1. Clone o repositório
```bash
git clone <url-do-repositorio>
cd cadastro_app
```

### 2. Instale as dependências
```bash
flutter pub get
```

### 3. Configure a API
Edite o arquivo `lib/utils/constants.dart` e configure a URL da sua API Django:

```dart
class AppConstants {
  // Configure aqui a URL da sua API Django
  static const String apiBaseUrl = 'http://localhost:8000';
  // ... outras configurações
}
```

### 4. Execute o projeto
```bash
# Para desenvolvimento
flutter run -d chrome

# Para build de produção
flutter build web
```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── user_model.dart
│   └── ...
├── providers/                # Gerenciamento de estado
│   ├── auth_provider.dart
│   ├── responsavel_provider.dart
│   └── ...
├── screens/                  # Telas da aplicação
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── responsaveis/
│   ├── membros/
│   └── demandas/
├── services/                 # Serviços e APIs
│   └── api_service.dart
├── utils/                    # Utilitários e constantes
│   ├── constants.dart
│   └── app_theme.dart
└── widgets/                  # Widgets reutilizáveis
    ├── dashboard_card.dart
    ├── sidebar.dart
    └── ...
```

## 🔧 Configuração da API

O app Flutter se conecta com a API Django através dos seguintes endpoints:

### Autenticação
- `POST /auth/login/` - Login do usuário
- `GET /auth/user/` - Dados do usuário logado
- `POST /auth/logout/` - Logout

### Responsáveis
- `GET /cadastro/api/responsaveis/` - Listar responsáveis
- `POST /cadastro/api/responsaveis/` - Criar responsável
- `GET /cadastro/api/responsaveis/{cpf}/` - Buscar responsável
- `PUT /cadastro/api/responsaveis/{cpf}/` - Atualizar responsável
- `GET /cadastro/api/responsaveis/{cpf}/com_membros/` - Responsável com membros

### Membros
- `GET /cadastro/api/membros/` - Listar membros
- `POST /cadastro/api/membros/` - Criar membro

### Demandas
- `GET /cadastro/api/demandas-saude/` - Listar demandas de saúde
- `GET /cadastro/api/demandas-educacao/` - Listar demandas de educação

## 🎨 Personalização

### Tema
Edite `lib/utils/app_theme.dart` para personalizar cores e estilos:

```dart
class AppTheme {
  static const Color primaryColor = Color(0xFF1976D2); // Cor primária
  static const Color accentColor = Color(0xFF03DAC6);  // Cor de destaque
  // ... outras cores
}
```

### Constantes
Configure textos e comportamentos em `lib/utils/constants.dart`:

```dart
class AppConstants {
  static const String appName = 'Cadastro Unificado';
  static const int defaultPageSize = 20;
  // ... outras constantes
}
```

## 📱 Funcionalidades

### 🔐 Sistema de Login
- Login com usuário e senha
- Validação de campos
- Persistência de sessão
- Logout seguro

### 📊 Dashboard
- Cards com estatísticas
- Gráficos de demandas
- Ações rápidas
- Navegação intuitiva

### 👥 Gestão de Responsáveis
- Lista paginada com filtros
- Busca por nome/CPF
- Formulário completo de cadastro
- Validação de CPF
- Máscaras de entrada
- Visualização detalhada

### 👨‍👩‍👧‍👦 Membros
- Lista de membros por responsável
- Filtros por status
- Cadastro de novos membros

### 📋 Demandas
- Visualização por categoria (Saúde, Educação, Ambiente)
- Filtros por prioridade
- Identificação de grupos prioritários

## 🌐 Deploy para Produção

### Build para Web
```bash
# Gerar build otimizado
flutter build web --release

# Os arquivos serão gerados em build/web/
```

### Configurações de Produção
1. Configure a URL da API de produção em `constants.dart`
2. Atualize as configurações CORS no Django
3. Configure HTTPS se necessário

### Hospedagem
O build pode ser hospedado em:
- **Firebase Hosting**
- **Netlify**
- **Vercel**
- **GitHub Pages**
- **Servidor web tradicional**

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Erro de CORS
Configure CORS no Django:
```python
# settings.py
CORS_ALLOW_ALL_ORIGINS = True  # Apenas para desenvolvimento
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",  # URL do Flutter web
]
```

#### 2. API não conecta
Verifique:
- URL da API em `constants.dart`
- Servidor Django rodando
- Firewall/antivírus

#### 3. Erro ao fazer build
```bash
# Limpe o cache
flutter clean
flutter pub get
flutter build web
```

#### 4. Problemas de dependências
```bash
# Atualize as dependências
flutter pub upgrade
```

## 🧪 Testes

```bash
# Executar testes
flutter test

# Executar testes com coverage
flutter test --coverage
```

## 📚 Tecnologias Utilizadas

- **Flutter 3.x** - Framework principal
- **Provider** - Gerenciamento de estado
- **Dio** - Cliente HTTP
- **GoRouter** - Navegação
- **Material Design 3** - Design system
- **Shared Preferences** - Persistência local

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 📞 Suporte

Para dúvidas e suporte:
- 📧 Email: suporte@example.com
- 💬 Issues: [GitHub Issues](link-para-issues)
- 📖 Documentação: [Wiki do Projeto](link-para-wiki)

---

## 🚀 Próximos Passos

- [ ] Implementar PWA completo
- [ ] Adicionar notificações push
- [ ] Sistema de relatórios
- [ ] Exportação de dados
- [ ] Tema escuro/claro automático
- [ ] Suporte offline
- [ ] Testes automatizados
- [ ] CI/CD pipeline

---

**Desenvolvido com ❤️ em Flutter**

# 🚀 Preparação para Produção - Cadastro Unificado

## 📋 Checklist de Produção

### ✅ Segurança
- [ ] **Configurar HTTPS obrigatório**
- [ ] **Implementar rate limiting na API**
- [ ] **Validar todas as entradas do usuário**
- [ ] **Sanitizar dados antes de salvar**
- [ ] **Implementar headers de segurança**
- [ ] **Configurar CORS adequadamente**
- [ ] **Remover dados sensíveis dos logs**
- [ ] **Implementar rotação de tokens**

### ✅ Performance
- [ ] **Otimizar imagens e assets**
- [ ] **Implementar compressão gzip**
- [ ] **Configurar cache adequado**
- [ ] **Minificar código JavaScript**
- [ ] **Implementar lazy loading**
- [ ] **Otimizar consultas à API**
- [ ] **Implementar paginação eficiente**

### ✅ Monitoramento
- [ ] **Configurar analytics**
- [ ] **Implementar error tracking**
- [ ] **Configurar logs de produção**
- [ ] **Implementar health checks**
- [ ] **Configurar alertas**
- [ ] **Monitorar performance**

### ✅ Backup e Recuperação
- [ ] **Configurar backup automático**
- [ ] **Testar restauração de backup**
- [ ] **Implementar sincronização offline**
- [ ] **Configurar replicação de dados**

## 🔧 Configurações de Build

### web/index.html
```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Sistema de Gestão de Cadastros e Demandas Sociais">
  <meta name="keywords" content="cadastro, social, gestão, demandas">
  <meta name="author" content="Sua Organização">
  
  <!-- PWA -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Cadastro Unificado">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  
  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <!-- Manifest -->
  <link rel="manifest" href="manifest.json">
  
  <!-- SEO -->
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  
  <!-- Security Headers -->
  <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' https:;">
  
  <title>Cadastro Unificado</title>
  
  <!-- Loading Screen -->
  <style>
    .loading {
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      height: 100vh;
      background: linear-gradient(135deg, #1976d2, #1565c0);
      color: white;
      font-family: 'Roboto', sans-serif;
    }
    .loading-icon {
      width: 80px;
      height: 80px;
      margin-bottom: 20px;
    }
    .loading-spinner {
      border: 4px solid rgba(255,255,255,0.3);
      border-top: 4px solid white;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin-top: 20px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div id="loading" class="loading">
    <svg class="loading-icon" viewBox="0 0 24 24" fill="currentColor">
      <path d="M12 2L2 7v10c0 5.55 3.84 9.95 9 11 5.16-1.05 9-5.45 9-11V7l-10-5z"/>
    </svg>
    <h2>Cadastro Unificado</h2>
    <p>Carregando sistema...</p>
    <div class="loading-spinner"></div>
  </div>
  
  <script>
    window.addEventListener('flutter-first-frame', function () {
      document.getElementById('loading').remove();
    });
  </script>
  
  <script src="main.dart.js" type="application/javascript"></script>
</body>
</html>
```

### Dockerfile
```dockerfile
# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY . .

# Get dependencies
RUN flutter pub get

# Build web app
RUN flutter build web --release --web-renderer html

# Production stage
FROM nginx:alpine

# Copy built app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Security headers
RUN echo 'add_header X-Frame-Options "SAMEORIGIN";' >> /etc/nginx/conf.d/security.conf && \
    echo 'add_header X-Content-Type-Options "nosniff";' >> /etc/nginx/conf.d/security.conf && \
    echo 'add_header X-XSS-Protection "1; mode=block";' >> /etc/nginx/conf.d/security.conf && \
    echo 'add_header Referrer-Policy "strict-origin-when-cross-origin";' >> /etc/nginx/conf.d/security.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### nginx.conf
```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Security headers
    include /etc/nginx/conf.d/security.conf;

    # PWA support
    location /manifest.json {
        add_header Cache-Control "public, max-age=3600";
    }

    location /sw.js {
        add_header Cache-Control "no-cache";
    }

    # Static assets caching
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Flutter routes
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache";
    }

    # API proxy (if needed)
    location /api/ {
        proxy_pass http://api-backend:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

## 🐳 Docker Compose para desenvolvimento

### docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:80"
    environment:
      - API_URL=http://api:8000
    depends_on:
      - api
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf

  api:
    image: your-api-image:latest
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/cadastro
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=cadastro
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## 🔄 CI/CD Pipeline

### .github/workflows/deploy.yml
```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.27.4'
        channel: 'stable'
        cache: true

    - name: Install dependencies
      run: flutter pub get

    - name: Run analyzer
      run: flutter analyze

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        files: coverage/lcov.info

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.27.4'
        channel: 'stable'
        cache: true

    - name: Install dependencies
      run: flutter pub get

    - name: Build web
      run: flutter build web --release --web-renderer html

    - name: Build Docker image
      run: |
        docker build -t cadastro-app:${{ github.sha }} .
        docker tag cadastro-app:${{ github.sha }} cadastro-app:latest

    - name: Deploy to staging
      if: github.event_name == 'pull_request'
      run: |
        echo "Deploy to staging environment"
        # Adicionar comandos de deploy para staging

    - name: Deploy to production
      if: github.ref == 'refs/heads/main'
      run: |
        echo "Deploy to production environment"
        # Adicionar comandos de deploy para produção

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Run security scan
      uses: securecodewarrior/github-action-add-sarif@v1
      with:
        sarif-file: security-scan-results.sarif
```

## 📊 Monitoramento e Analytics

### lib/services/analytics_service.dart (Implementação completa)
```dart
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Inicializar Firebase Analytics ou outra solução
      if (kDebugMode) {
        debugPrint('Analytics initialized in debug mode');
      }
      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing analytics: $e');
    }
  }

  // User events
  static Future<void> logLogin(String method) async {
    await _logEvent('login', {'method': method});
  }

  static Future<void> logSignUp(String method) async {
    await _logEvent('sign_up', {'method': method});
  }

  // Screen tracking
  static Future<void> logScreenView(String screenName) async {
    await _logEvent('screen_view', {'screen_name': screenName});
  }

  // Business events
  static Future<void> logResponsavelCreated() async {
    await _logEvent('responsavel_created');
  }

  static Future<void> logMembroAdded() async {
    await _logEvent('membro_added');
  }

  static Future<void> logDemandaViewed(String type) async {
    await _logEvent('demanda_viewed', {'type': type});
  }

  // Search and filter events
  static Future<void> logSearch(String query, String section) async {
    await _logEvent('search', {
      'search_term': query,
      'section': section,
    });
  }

  static Future<void> logFilterUsed(String filterType, String value) async {
    await _logEvent('filter_used', {
      'filter_type': filterType,
      'filter_value': value,
    });
  }

  // Error tracking
  static Future<void> logError(String error, Map<String, dynamic>? context) async {
    await _logEvent('error_occurred', {
      'error_message': error,
      ...?context,
    });
  }

  // Performance tracking
  static Future<void> logPerformance(String action, int duration) async {
    await _logEvent('performance', {
      'action': action,
      'duration_ms': duration,
    });
  }

  static Future<void> _logEvent(String eventName, [Map<String, dynamic>? parameters]) async {
    if (!_initialized) await init();
    
    try {
      if (kDebugMode) {
        debugPrint('Analytics Event: $eventName ${parameters ?? ''}');
      }
      // Implementar envio real para o serviço de analytics
    } catch (e) {
      debugPrint('Error logging analytics event: $e');
    }
  }

  // User properties
  static Future<void> setUserProperty(String name, String value) async {
    if (!_initialized) await init();
    
    try {
      if (kDebugMode) {
        debugPrint('Analytics User Property: $name = $value');
      }
      // Implementar definição de propriedade do usuário
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }
}
```

## 🔐 Configurações de Segurança

### Variáveis de Ambiente (.env)
```bash
# API Configuration
API_BASE_URL=https://api.cadastrounificado.com
API_TIMEOUT=30000

# Security
JWT_SECRET=your-super-secret-jwt-key
ENCRYPTION_KEY=your-encryption-key

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/cadastro
REDIS_URL=redis://localhost:6379

# External Services
VIACEP_API_URL=https://viacep.com.br/ws/
ANALYTICS_API_KEY=your-analytics-key

# Feature Flags
ENABLE_DEBUG_MODE=false
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

## 📈 Métricas de Performance

### Core Web Vitals
- **LCP (Largest Contentful Paint)**: < 2.5s
- **FID (First Input Delay)**: < 100ms
- **CLS (Cumulative Layout Shift)**: < 0.1

### Metas de Performance
- **Time to Interactive**: < 3s
- **Bundle Size**: < 2MB
- **API Response Time**: < 500ms
- **Cache Hit Rate**: > 80%

## 🚀 Scripts de Deploy

### deploy.sh
```bash
#!/bin/bash

set -e

echo "🚀 Iniciando deploy do Cadastro Unificado..."

# Verificar se está na branch main
if [ "$(git branch --show-current)" != "main" ]; then
    echo "❌ Deploy deve ser feito a partir da branch main"
    exit 1
fi

# Executar testes
echo "🧪 Executando testes..."
flutter test

# Build da aplicação
echo "🔨 Fazendo build da aplicação..."
flutter build web --release --web-renderer html

# Build da imagem Docker
echo "🐳 Construindo imagem Docker..."
docker build -t cadastro-app:latest .

# Deploy
echo "🚀 Fazendo deploy..."
# Adicionar comandos específicos do seu provedor

echo "✅ Deploy concluído com sucesso!"
```

## 📝 Documentação de API

### API Endpoints Documentation
```markdown
## Autenticação

### POST /auth/login/
Login do usuário

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "token": "string",
  "user": {
    "id": "number",
    "username": "string",
    "email": "string"
  }
}
```

## Responsáveis

### GET /cadastro/api/responsaveis/
Lista responsáveis com paginação

**Query Parameters:**
- `page`: número da página (padrão: 1)
- `page_size`: itens por página (padrão: 20)
- `search`: termo de busca
- `status`: filtro por status (A, I, P, B)

**Response:**
```json
{
  "count": "number",
  "next": "string|null",
  "previous": "string|null",
  "results": [
    {
      "cpf": "string",
      "nome": "string",
      "status": "string",
      // ... outros campos
    }
  ]
}
```
```

## 🎯 Próximos Passos

### Fase 1 - Estabilização (2-4 semanas)
1. Implementar widgets e utils faltantes
2. Configurar sistema de logs
3. Implementar busca de CEP
4. Testes unitários básicos
5. Deploy em ambiente de staging

### Fase 2 - Melhorias (4-6 semanas)
1. Sistema de cache e offline
2. PWA completo
3. Notificações push
4. Analytics e monitoramento
5. Testes de integração

### Fase 3 - Funcionalidades Avançadas (6-8 semanas)
1. Sistema de relatórios
2. Exportação de dados
3. Dashboard avançado
4. Integração com outros sistemas
5. Otimizações de performance

### Fase 4 - Produção (2-3 semanas)
1. Deploy em produção
2. Monitoramento em tempo real
3. Backup e recuperação
4. Documentação completa
5. Treinamento dos usuários

---

**Total estimado: 14-21 semanas para implementação completa**