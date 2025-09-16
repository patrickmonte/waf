#!/bin/bash

# Script para instalar o ModSecurity v3 e GeoIP em Oracle Linux 7, 8 ou 9.
# Instala apenas o ModSecurity e GeoIP, sem o Core Rule Set (CRS).
# Execute este script com privilégios de root.

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
    # Instala o devtoolset-9 que fornece GCC 9 (com suporte a C++17)
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

# --- Instalação de libmaxminddb a partir do código fonte ---
install_libmaxminddb() {
  echo "Instalando libmaxminddb a partir do código fonte..."
  cd /usr/local/src/
  if [ -d "libmaxminddb" ]; then
    rm -rf libmaxminddb
  fi
  git clone --recursive https://github.com/maxmind/libmaxminddb
  cd libmaxminddb
  ./bootstrap
  ./configure
  make
  make install
  # Atualiza o cache de bibliotecas
  ldconfig
}

# --- Compilação do ModSecurity v3 ---
compile_modsecurity() {
  echo "Compilando o ModSecurity v3..."
  cd /usr/local/src/
  if [ -d "ModSecurity" ]; then
    rm -rf ModSecurity
  fi
  git clone https://github.com/SpiderLabs/ModSecurity
  cd ModSecurity
  git submodule init
  git submodule update
  ./build.sh
  ./configure
  make
  make install
}

# --- Compilação do Conector Apache ---
compile_apache_connector() {
  echo "Compilando o conector do ModSecurity para Apache..."
  cd /usr/local/src/
  if [ -d "ModSecurity-apache" ]; then
    rm -rf ModSecurity-apache
  fi
  git clone https://github.com/SpiderLabs/ModSecurity-apache
  cd ModSecurity-apache
  ./autogen.sh
  ./configure
  make
  make install
}

# --- Configuração do Apache e ModSecurity ---
configure_apache_modsec() {
  echo "Configurando o Apache e o ModSecurity..."
  
  cat > /etc/httpd/conf.modules.d/10-mod_security.conf << EOF
LoadModule security3_module modules/mod_security3.so
EOF
  
  mkdir -p /etc/httpd/modsecurity.d
  
  cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/httpd/modsecurity.d/modsecurity.conf
  cp /usr/local/src/ModSecurity/unicode.mapping /etc/httpd/modsecurity.d/
  
  sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/httpd/modsecurity.d/modsecurity.conf

  # Configuração do GeoIP
  cat >> /etc/httpd/modsecurity.d/modsecurity.conf << EOF

# --- Configuração do GeoIP ---
SecGeoLookupDB /usr/share/GeoIP/GeoIP.dat
EOF

  # Configuração básica do ModSecurity
  cat > /etc/httpd/conf.d/mod_security.conf << EOF
<IfModule security3_module>
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

install_libmaxminddb
check_success "Instalação da libmaxminddb"

# Versão corrigida para o script, usando um bloco de comandos e redirecionamento
if [ "$OS_VERSION" -eq 7 ]; then
  echo "Ativando o devtoolset-9 para compilação no Oracle Linux 7..."
  # Exportar funções para torná-las disponíveis no subshell
  export -f compile_modsecurity
  export -f compile_apache_connector
  export -f check_success
  scl enable devtoolset-9 -- bash -c '
    set -e
    compile_modsecurity
    check_success "Compilação do ModSecurity v3"
    compile_apache_connector
    check_success "Compilação do conector Apache"
  '
else
  compile_modsecurity
  check_success "Compilação do ModSecurity v3"
  compile_apache_connector
  check_success "Compilação do conector Apache"
fi

configure_apache_modsec
check_success "Configuração do Apache e ModSecurity"

restart_apache
check_success "Reinicialização do Apache"

# --- Finalização ---
echo "---------------------------------------------------------"
echo "🚀 Instalação e configuração concluídas com sucesso!"
echo "ModSecurity v3 com GeoIP está ativo."
echo "---------------------------------------------------------"