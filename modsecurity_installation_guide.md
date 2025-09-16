# Guia de Instalação do ModSecurity v3 para Oracle Linux

Este guia detalha o processo de instalação do ModSecurity v3 (com e sem Core Rule Set) em sistemas Oracle Linux 7, 8 e 9.

## Pré-requisitos
- Acesso root ao servidor
- Conexão ativa com a internet
- 1GB+ de espaço livre em disco
- 15-30 minutos para instalação

## 📦 Opção 1: Instalação Completa (ModSecurity + CRS + GeoIP)

### Passo 1: Baixar o script
```bash
wget https://exemplo.com/install_modsecurity_v4.sh
chmod +x install_modsecurity_v4.sh
```

### Passo 2: Executar a instalação
```bash
sudo ./install_modsecurity_v4.sh
```

### Fluxo de instalação:
1. Instala dependências específicas da versão do Oracle Linux
2. Compila e instala a libmaxminddb
3. Compila o ModSecurity v3
4. Compila o conector Apache
5. Configura o ModSecurity com CRS v4.18.0 e GeoIP
6. Reinicia o Apache

## ⚡ Opção 2: Instalação Simplificada (Apenas ModSecurity + GeoIP)

### Passo 1: Baixar o script
```bash
wget https://exemplo.com/install_modsecurity_latest.sh
chmod +x install_modsecurity_latest.sh
```

### Passo 2: Executar a instalação
```bash
sudo ./install_modsecurity_latest.sh
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
3. Desative temporariamente o ModSecurity comentando `LoadModule security3_module`

### Problema: Bloqueios indevidos
**Solução:**
1. Ajuste o nível de paranoia no CRS
2. Adicione exceções específicas
3. Modifique `SecRuleEngine` para `DetectionOnly` para modo de teste

## 📚 Recursos Adicionais
- [Documentação Oficial ModSecurity](https://github.com/SpiderLabs/ModSecurity)
- [Core Rule Set Repository](https://github.com/coreruleset/coreruleset)
- [Guia de Referência ModSecurity](https://modsecurity.org/rules.html)
