# 🛡️ ModSecurity Installer para Oracle Linux

Scripts automatizados para instalação do ModSecurity v3 em sistemas Oracle Linux 7, 8 e 9.

## 📁 Scripts Disponíveis

1. **`install_modsecurity_v4.sh`**  
   Instalação completa com:
   - ModSecurity v3
   - Core Rule Set (CRS) v4
   - Suporte a GeoIP

2. **`install_modsecurity_latest.sh`**  
   Instalação simplificada com:
   - ModSecurity v3 (última versão)
   - Suporte a GeoIP
   - Sem CRS

## 📚 Documentação Detalhada

Consulte o guia completo de instalação e configuração:  
[modsecurity_installation_guide.md](modsecurity_installation_guide.md)

## 🚀 Como Utilizar

```bash
# 1. Baixe o script desejado
wget https://exemplo.com/install_modsecurity_v4.sh

# 2. Torne executável
chmod +x install_modsecurity_*.sh

# 3. Execute com privilégios root
sudo ./install_modsecurity_v4.sh
```

## ⚙️ Requisitos do Sistema
- Oracle Linux 7, 8 ou 9
- Acesso root
- Conexão com internet
- 1GB+ de espaço em disco

## ❓ Suporte
Problemas ou dúvidas?  
Abra uma issue no repositório ou contate: suporte@exemplo.com
