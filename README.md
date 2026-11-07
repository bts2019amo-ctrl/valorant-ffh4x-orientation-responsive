# 8ball Pooll Login (iOS / Theos)

Este repositório gera um tweak iOS rootless que exibe somente um prompt UIKit para inserir uma KAY e validá-la no serviço configurado.

## Escopo

- Exibe uma caixa nativa com campo seguro para a chave.
- Valida a KAY por `GET https://proxysystem.org/api/trpc/proxyKeys.publicCheckKey`, com `input={json:{key,deviceId}}`.
- Autoriza somente quando a resposta tRPC contém `success=true`, `active=true` e `status="active"`; apresenta mensagens de erro, vínculo de dispositivo e `expiresAt`.
- Gera um identificador iOS estável baseado no IDFV, com SHA-256 truncado para 32 caracteres hexadecimais, sem solicitar IDFA.
- Não inclui overlay/menu de jogo, ESP, aimbot, offsets, patches, leitura/escrita de memória, hooks de jogo, ImGui ou dylib auxiliar.
- Uma chave válida apenas fecha o prompt e mostra a confirmação; nenhuma funcionalidade de jogo é ativada.
- A chave não é salva em `NSUserDefaults` nem copiada automaticamente da área de transferência.

`destroying.plist` mantém os mesmos identificadores de bundle configurados anteriormente. O tweak aguarda o app ficar ativo e a janela UIKit estar disponível antes de exibir o prompt. Como o serviço vincula chaves a um `deviceId`, uma chave já associada a outro aparelho pode ser recusada.

## Compilação

O build exige macOS, Theos e o SDK de iOS. O workflow `.github/workflows/build.yml` instala as dependências de build, executa `make package FINALPACKAGE=1` e publica o `.deb` como artefato.

Para compilar localmente:

```sh
export THEOS=/caminho/para/theos
./Make.sh
```

O pacote é arm64/rootless. O script apenas compila; não instala no dispositivo.
