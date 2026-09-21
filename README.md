# Valorant FFH4X Orientation Responsive

Projeto de tweak iOS/Theos com o nome de pacote `destroying`.

## Estado do build

O build não pode ser executado neste ambiente Linux porque o projeto exige **Theos**, um SDK do iPhone/iOS e a toolchain Apple. A tentativa local falha com:

```text
[!] THEOS not found at /var/mobile/theos
```

O workflow de GitHub Actions em `.github/workflows/build.yml` usa um runner macOS para instalar o Theos e tentar gerar o pacote `.deb`.

## Build local em um Mac/iPhone com Theos

```bash
export THEOS=/path/to/theos
./Make.sh
```

O pacote gerado aparecerá em `packages/`. Para instalação em um dispositivo compatível, use o fluxo de deploy apropriado ao seu ambiente; o script aceita `./Make.sh install` quando `dpkg` está disponível.

## Estrutura

- `Makefile`: configuração do tweak Theos para `arm64`, rootless e iOS 16.5.
- `Make.sh`: limpeza e empacotamento do projeto.
- `Tweak.xm`, `ImGui*`, `KittyMemory/`, `fishhook/` e `imgui/`: código-fonte e dependências incluídas no arquivo original.
- `Resources/`: recursos incorporados ao pacote.

## Observações

Este repositório reproduz o conteúdo do arquivo ZIP fornecido. Nenhum segredo ou artefato de build é incluído; diretórios `.theos/` e `packages/` são ignorados pelo Git.
