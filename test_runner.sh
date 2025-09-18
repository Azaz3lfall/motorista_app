#!/bin/bash

# Script para executar todos os testes do projeto

echo "🚀 Executando testes do App Motorista..."
echo "========================================"

# Verificar se o Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Instale o Flutter primeiro."
    exit 1
fi

# Navegar para o diretório do projeto
cd "$(dirname "$0")"

echo "📱 Verificando dependências..."
flutter pub get

echo ""
echo "🧪 Executando testes unitários..."
flutter test test/models/
flutter test test/utils/

echo ""
echo "🎨 Executando testes de widget..."
flutter test test/widgets/

echo ""
echo "📊 Executando análise de código..."
flutter analyze

echo ""
echo "✅ Todos os testes concluídos!"
echo "========================================"

# Mostrar cobertura de testes se disponível
if command -v genhtml &> /dev/null; then
    echo "📈 Gerando relatório de cobertura..."
    flutter test --coverage
    if [ -f coverage/lcov.info ]; then
        genhtml coverage/lcov.info -o coverage/html
        echo "📊 Relatório de cobertura gerado em: coverage/html/index.html"
    fi
fi

echo ""
echo "🎉 Processo de teste finalizado!"

