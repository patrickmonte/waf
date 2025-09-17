#!/bin/bash

# Script para instalar o ModSecurity v2 em Oracle Linux 7, 8 ou 9
# A versão 2 possui conector Apache integrado, simplificando a instalação
# Execute este script com privilégios de root

# --- Interrompe o script em caso de erro ---
set -e

# --- Função de verificação de erro ---
check_success() {
  if [ $? -ne 0 ]; then
    echo "❌ ERRO: A etapa '$1' falhou. Abortando a instalação."
    exit 1
  fi
  echo "✅ SUCESSO: Etapa '$1' concluída."
}

# --- Verificação de Root ---
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root."
  exit 1
fi

# --- Detecção da Versão do Oracle Linux ---
OS_VERSION=$(grep -oE '[0-9]+' /etc/oracle-release | head -n 1)

if [[ "$OS_VERSION" -ne 7 && "$OS_VERSION" -ne 8 && "$OS_VERSION" -ne 9 ]]; then
  echo "Versão do Oracle Linux não suportada. Este script suporta as versões 7, 8 e 9."
  exit 1
fi

echo "Detectada a versão $OS_VERSION do Oracle Linux."

# --- Instalação de Dependências ---
install_dependencies() {
  echo "Instalando dependências..."
  
  # Dependências comuns
  yum install -y httpd httpd-devel git flex bison yajl yajl-devel curl-devel zlib-devel pcre-devel autoconf automake libtool make libxml2-devel pkgconfig openssl-devel wget
  
  # Dependências específicas da versão
  if [ "$OS_VERSION" -eq 7 ]; then
    yum reinstall -y https://archives.fedoraproject.org/pub/archive/epel/7/x86_64/Packages/e/epel-release-7-14.noarch.rpm
    # Instala o SCL para obter um compilador mais novo
    yum install -y oracle-software-release-el7 oracle-softwarecollection-release-el7
    # Instala o devtoolset-9 que fornece GCC 9
    yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
    yum install -y GeoIP-devel GeoIP
  elif [ "$OS_VERSION" -eq 8 ]; then
    dnf install -y 'dnf-command(config-manager)'
    dnf config-manager --set-enabled ol8_codeready_builder
    dnf install -y epel-release gcc-c++
    dnf install -y GeoIP-devel GeoIP
  elif [ "$OS_VERSION" -eq 9 ]; then
    dnf install -y 'dnf-command(config-manager)'
    dnf config-manager --set-enabled ol9_codeready_builder
    dnf install -y epel-release gcc-c++
    dnf install -y GeoIP-devel GeoIP
  fi
}

# --- Compilação do ModSecurity v2 ---
compile_modsecurity_v2() {
  echo "Compilando o ModSecurity v2..."
  cd /usr/local/src/
  if [ -d "ModSecurity" ]; then
    rm -rf ModSecurity
  fi
  
  # Usando a versão 2.9.12 (última estável da v2)
  git clone -b v2.9.12 https://github.com/SpiderLabs/ModSecurity
  cd ModSecurity
  ./autogen.sh
  ./configure --enable-standalone-module --enable-geoip
  make
  make install
}

# --- Configuração do Apache ---
configure_apache() {
  echo "Configurando o Apache..."
  
  # Copia o módulo do diretório de instalação para o Apache
  cp /usr/local/modsecurity/lib/mod_security2.so /etc/httpd/modules/
  
  cat > /etc/httpd/conf.modules.d/10-mod_security.conf << EOF
LoadModule security2_module modules/mod_security2.so
EOF
  
  mkdir -p /etc/httpd/modsecurity.d
  cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/httpd/modsecurity.d/modsecurity.conf
  cp /usr/local/src/ModSecurity/unicode.mapping /etc/httpd/modsecurity.d/
  
  sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/httpd/modsecurity.d/modsecurity.conf

  # Configuração básica
  cat > /etc/httpd/conf.d/mod_security.conf << EOF
<IfModule security2_module>
    Include modsecurity.d/modsecurity.conf
</IfModule>
EOF
}

# --- Reiniciar e Habilitar o Apache ---
restart_apache() {
  echo "Reiniciando e habilitando o Apache..."
  systemctl restart httpd
  systemctl enable httpd
}

# --- Execução do Script ---
install_dependencies
check_success "Instalação de dependências"

if [ "$OS_VERSION" -eq 7 ]; then
  echo "Ativando o devtoolset-9 para compilação no Oracle Linux 7..."
  # Exportar funções para torná-las disponíveis no subshell
  export -f compile_modsecurity_v2
  export -f check_success
  scl enable devtoolset-9 -- bash -c '
    set -e
    compile_modsecurity_v2
    check_success "Compilação do ModSecurity v2"
  '
else
  compile_modsecurity_v2
  check_success "Compilação do ModSecurity v2"
fi

configure_apache
check_success "Configuração do Apache"

restart_apache
check_success "Reinicialização do Apache"

# --- Finalização ---
echo "---------------------------------------------------------"
echo "🚀 Instalação e configuração do ModSecurity v2 concluídas!"
echo "---------------------------------------------------------"