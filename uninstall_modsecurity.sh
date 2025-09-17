#!/bin/bash

# Script para remover completamente ModSecurity, CRS e GeoIP
# Execute com privilégios de root

# --- Interrompe o script em caso de erro ---
set -e

# --- Verificação de Root ---
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute como root."
  exit 1
fi

echo "⚠️ ATENÇÃO: Este script removerá completamente o ModSecurity, CRS e GeoIP"
read -p "Deseja continuar? (s/n): " confirm
if [[ $confirm != "s" && $confirm != "S" ]]; then
  echo "Operação cancelada."
  exit 0
fi

# --- Parar Apache ---
echo "Parando o Apache..."
systemctl stop httpd || true

# --- Remover arquivos de configuração ---
echo "Removendo arquivos de configuração..."
rm -f /etc/httpd/conf.modules.d/10-mod_security.conf
rm -f /etc/httpd/conf.d/mod_security.conf
rm -rf /etc/httpd/modsecurity.d
rm -rf /usr/share/GeoIP

# --- Remover módulos ---
echo "Removendo módulos..."
rm -f /etc/httpd/modules/mod_security2.so
rm -f /etc/httpd/modules/mod_security3.so
rm -f /usr/local/modsecurity/lib/mod_security*.so

# --- Remover diretórios de origem ---
echo "Removendo diretórios de origem..."
rm -rf /usr/local/src/libmaxminddb
rm -rf /usr/local/src/ModSecurity
rm -rf /usr/local/src/ModSecurity-apache

# --- Remover pacotes instalados ---
echo "Removendo pacotes relacionados..."
if command -v dnf &> /dev/null; then
  dnf remove -y GeoIP GeoIP-devel
elif command -v yum &> /dev/null; then
  yum remove -y GeoIP GeoIP-devel
fi

# --- Reinstalar Apache limpo (opcional) ---
read -p "Deseja reinstalar um Apache limpo? (s/n): " reinstall
if [[ $reinstall == "s" || $reinstall == "S" ]]; then
  echo "Reinstalando Apache..."
  if command -v dnf &> /dev/null; then
    dnf remove -y httpd
    dnf install -y httpd mod_ssl
  elif command -v yum &> /dev/null; then
    yum remove -y httpd
    yum install -y httpd mod_ssl
  fi
fi

# --- Finalização ---
echo "---------------------------------------------------------"
echo "✅ Remoção completa do ModSecurity, CRS e GeoIP realizada"
echo "---------------------------------------------------------"