# 🛡️ ModSecurity Installer para Oracle Linux

Scripts automatizados para instalação e desinstalação do ModSecurity em sistemas Oracle Linux 7, 8 e 9.

## 📁 Scripts Disponíveis

1. **`install_modsecurity_CRS.sh`**
   Instalação completa v3 com:
   - ModSecurity v3
   - Core Rule Set (CRS) v4
   - Suporte a GeoIP

2. **`install_modsecurity_GEOIP.sh`**
   Instalação simplificada v3 com:
   - ModSecurity v3 (última versão)
   - Suporte a GeoIP
   - Sem CRS

3. **`install_modsecurity_v2.sh`**
   Instalação da versão estável v2 com:
   - ModSecurity v2.9.7
   - Conector Apache integrado
   - Suporte a GeoIP

4. **`install_modsecurity_v2_GEOIP.sh`**
   Instalação simplificada v2 com:
   - ModSecurity v2.9.7
   - Conector Apache integrado
   - Suporte a GeoIP
   - Sem CRS

5. **`uninstall_modsecurity.sh`**
   Remoção completa de:
   - ModSecurity (v2 e v3)
   - Core Rule Set (CRS)
   - GeoIP
   - Arquivos de configuração

## 📚 Documentação Detalhada

Consulte o guia completo de instalação e configuração:
[modsecurity_installation_guide.md](modsecurity_installation_guide.md)

## 🚀 Como Utilizar

```bash
# 1. Baixe o script desejado
wget https://exemplo.com/install_modsecurity_CRS.sh

# 2. Torne executável
chmod +x install_modsecurity_*.sh

# 3. Execute com privilégios root
sudo ./install_modsecurity_CRS.sh

# Para desinstalar
sudo ./uninstall_modsecurity.sh
```

## ⚙️ Requisitos do Sistema
- Oracle Linux 7, 8 ou 9
- Acesso root
- Conexão com internet
- 1GB+ de espaço em disco

## ❓ Suporte
Problemas ou dúvidas?
Abra uma issue no repositório ou contate: suporte@exemplo.com
