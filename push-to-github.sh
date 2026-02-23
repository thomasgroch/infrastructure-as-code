#!/bin/bash
# Script para fazer push do projeto para o GitHub
# Rode este script na sua máquina local após baixar o projeto

REPO_NAME="infrastructure-as-code"
GITHUB_USER="thomasgroch"

echo "Criando repositório no GitHub..."

# Criar repo via API (requer token com scope 'repo')
curl -X POST \
  -H "Authorization: token SEU_TOKEN_AQUI" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"Idempotent Ansible deployment for Passbolt\",\"private\":false}"

echo ""
echo "Configurando remote e fazendo push..."

cd infrastructure-as-code
git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
git branch -m main
git push -u origin main

echo ""
echo "✅ Projeto publicado em: https://github.com/$GITHUB_USER/$REPO_NAME"
