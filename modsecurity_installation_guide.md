# Guia de Instalação do ModSecurity para Oracle Linux

Este guia detalha o processo de instalação do ModSecurity (versões v2 e v3) em sistemas Oracle Linux 7, 8 e 9.

## Pré-requisitos
- Acesso root ao servidor
- Conexão ativa com a internet
- 1GB+ de espaço livre em disco
- 15-30 minutos para instalação

## 🛡️ Opção 1: Instalação ModSecurity v2 (Estável)

### Características:
- Versão 2.9.7 (estável)
- Conector Apache integrado
- Suporte a GeoIP

### Passo 1: Baixar o script
```bash
wget https://exemplo.com/install_modsecurity_v2.sh
chmod +x install_modsecurity_v2.sh
```

### Passo 2: Executar a instalação
```bash
sudo ./install_modsecurity_v2.sh
```

### Fluxo de instalação:
1. Instala dependências específicas da versão do Oracle Linux
2. Compila o ModSecurity v2 com conector integrado
3. Configura o Apache com suporte a GeoIP
4. Reinicia o Apache

## 📦 Opção 2: Instalação Completa v3 (ModSecurity + CRS + GeoIP)

### Passo 1: Baixar o script
```bash
wget https://exemplo.com/install_modsecurity_CRS.sh
chmod +x install_modsecurity_CRS.sh
```

### Passo 2: Executar a instalação
```bash
sudo ./install_modsecurity_CRS.sh
```

### Fluxo de instalação:
1. Instala dependências específicas da versão do Oracle Linux
2. Compila e instala a libmaxminddb
3. Compila o ModSecurity v3
4. Compila o conector Apache
5. Configura o ModSecurity com CRS v4.18.0 e GeoIP
6. Reinicia o Apache

## ⚡ Opção 3: Instalação Simplificada v3 (Apenas ModSecurity + GeoIP)

### Passo 1: Baixar o script
```bash
wget https://exemplo.com/install_modsecurity_GEOIP.sh
chmod +x install_modsecurity_GEOIP.sh
```

### Passo 2: Executar a instalação
```bash
sudo ./install_modsecurity_GEOIP.sh
```

### Fluxo de instalação:
1. Instala dependências essenciais
2. Compila componentes principais
3. Configura ModSecurity com suporte a GeoIP
4. Reinicia o Apache

## ✔️ Verificação Pós-Instalação

### Verificar módulo no Apache
```bash
httpd -M | grep security
```
Saída esperada:
```
# Para v2:
 security2_module (shared)
# Para v3:
 security3_module (shared)
```

### Testar funcionalidade básica
```bash
curl -I http://localhost/?exec=/bin/bash
```
Verifique no log do Apache (`/var/log/httpd/error_log`) por entradas do ModSecurity

## ⚙️ Configurações Principais

### Arquivos de configuração:
- `/etc/httpd/conf.modules.d/10-mod_security.conf` - Carrega o módulo
- `/etc/httpd/modsecurity.d/modsecurity.conf` - Configuração principal
- `/etc/httpd/conf.d/mod_security.conf` - Inclusão de configurações

### Configurações importantes:
```apache
SecRuleEngine On               # Ativa o motor de regras
SecAuditLog /var/log/modsec_audit.log  # Log de auditoria
SecDebugLog /var/log/modsec_debug.log  # Log de depuração
SecGeoLookupDB /usr/share/GeoIP/GeoIP.dat  # Banco de dados GeoIP
```

## 🔧 Solução de Problemas Comuns

### Problema: "command not found" durante instalação
**Solução:**
1. Verifique se todas as dependências foram instaladas
2. Execute novamente o script com `sudo ./script.sh`

### Problema: Apache não inicia após instalação
**Solução:**
1. Verifique logs em `/var/log/httpd/error_log`
2. Teste configuração com `httpd -t`
3. Desative temporariamente o ModSecurity comentando `LoadModule`

### Problema: Erro ao carregar módulo
**Solução:**
```bash
# 1. Localize o arquivo do módulo
find / -name mod_security*.so 2>/dev/null

# 2. Se encontrado em outro diretório, crie um symlink
sudo ln -s /caminho/correto/mod_security*.so /etc/httpd/modules/

# 3. Verifique as permissões
sudo chmod 755 /etc/httpd/modules/mod_security*.so

# 4. Atualize o cache de bibliotecas
sudo ldconfig
```

### Problema: Bloqueios indevidos
**Solução:**
1. Ajuste o nível de paranoia no CRS
2. Adicione exceções específicas
3. Modifique `SecRuleEngine` para `DetectionOnly` para modo de teste

## 🗑️ Desinstalação Completa

Para remover completamente o ModSecurity, CRS e GeoIP:

```bash
wget https://exemplo.com/uninstall_modsecurity.sh
chmod +x uninstall_modsecurity.sh
sudo ./uninstall_modsecurity.sh
```

O script:
1. Remove arquivos de configuração
2. Remove módulos do Apache
3. Desinstala pacotes relacionados
4. Remove diretórios de origem
5. Oferece opção para reinstalar Apache limpo

## 📚 Recursos Adicionais
- [Documentação Oficial ModSecurity](https://github.com/SpiderLabs/ModSecurity)
- [Core Rule Set Repository](https://github.com/coreruleset/coreruleset)
- [Guia de Referência ModSecurity](https://modsecurity.org/rules.html)
