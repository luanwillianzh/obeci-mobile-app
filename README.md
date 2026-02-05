# OBECI Mobile App

Este é o aplicativo móvel para a plataforma OBECI, desenvolvido em Flutter. O aplicativo permite gerenciar turmas, escolas e professores através da API do backend.

## Configuração do Projeto

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- Android Studio ou outro ambiente de desenvolvimento configurado
- Backend do OBECI rodando (geralmente em `http://localhost:9090`)

### Instalação

1. Clone este repositório
2. Navegue até o diretório do projeto
3. Execute o comando para obter as dependências:

```bash
flutter pub get
```

### Configuração do Backend

Para que o aplicativo funcione corretamente com o backend, certifique-se de que:

1. O backend do OBECI está rodando (geralmente em `http://localhost:9090`)
2. Se estiver usando um emulador Android, use `http://10.0.2.2:9090` como URL base para acessar o localhost do host
3. Se estiver usando um dispositivo físico, substitua o IP no `ApiService` pela máquina onde o backend está rodando

### Executando o Aplicativo

Execute o seguinte comando para iniciar o aplicativo:

```bash
flutter run
```

## Funcionalidades

- Autenticação de usuários (login e registro)
- Gerenciamento de turmas (criar, ler, atualizar e deletar)
- Gerenciamento de escolas (criar, ler, atualizar e deletar)
- Interface intuitiva e responsiva
- Integração completa com o backend OBECI

## Estrutura do Projeto

- `lib/main.dart` - Ponto de entrada do aplicativo e configuração dos providers
- `lib/services/api_service.dart` - Camada de comunicação com o backend
- `lib/models/` - Modelos de dados
- `lib/providers/` - Providers para gerenciamento de estado
- `lib/screens/` - Telas do aplicativo

## Dependências

- `dio` - Para requisições HTTP
- `provider` - Para gerenciamento de estado
- `shared_preferences` - Para armazenamento local
- `intl` - Para formatação de datas e números
- `form_validator` - Para validação de formulários

## Configuração de Permissões

O aplicativo requer permissão de internet. Verifique o arquivo `android/app/src/main/AndroidManifest.xml` para garantir que a permissão esteja incluída:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## Comunicação com o Backend

O aplicativo móvel se comunica com o backend OBECI da seguinte forma:

- Base URL: `http://10.0.2.2:9090` (para emulador Android) ou o IP do servidor backend
- Autenticação: JWT tokens armazenados localmente e enviados como Bearer token
- Endpoints principais:
  - `/auth/login` - Autenticação
  - `/auth/register` - Registro de usuário
  - `/auth/logout` - Logout
  - `/api/turmas` - Operações CRUD para turmas
  - `/api/escolas` - Operações CRUD para escolas
  - `/api/usuarios` - Operações CRUD para usuários

## Solução de Problemas

### Conectividade com o Backend

Se o aplicativo não conseguir se conectar ao backend:

1. Verifique se o servidor backend está rodando
2. Confirme que o endereço IP e porta estão corretos no `ApiService`
3. Se estiver usando um emulador Android, tente usar `10.0.2.2` em vez de `localhost`
4. Verifique as configurações de firewall
5. Certifique-se de que o backend está configurado para aceitar conexões CORS

### Erros de Compilação

Se encontrar erros de compilação:

1. Execute `flutter clean`
2. Execute `flutter pub get` novamente
3. Tente compilar novamente

## Desenvolvimento

Para adicionar novas funcionalidades:

1. Adicione novos métodos no `ApiService` conforme necessário
2. Crie modelos correspondentes em `lib/models/`
3. Atualize ou crie providers em `lib/providers/`
4. Crie novas telas em `lib/screens/`
5. Adicione rotas no `main.dart`