# cloudflare-workers-CockroachDB

# 構成

Web API: Hono

ORM: Prisma

RDBMS: PostgreSQL

DataBase: CockroachDB

# Setup

## 1. 以下のコマンドを実行

```shell
yarn create hono
```

### `yarn create hono`

```
>yarn create hono
yarn create v1.22.21
[1/4] Resolving packages...
[2/4] Fetching packages...
[3/4] Linking dependencies...
warning "create-t3-app > @ianvs/prettier-plugin-sort-imports@4.1.1" has unmet peer dependency "prettier@2 || 3".
[4/4] Building fresh packages...
success Installed "create-hono@0.6.3" with binaries:
      - create-hono
create-hono version 0.6.3
? Target directory ./
? Which template do you want to use? cloudflare-workers
? Directory not empty. Continue? yes
✔ Cloning the template
? Do you want to install project dependencies? yes
? Which package manager do you want to use? yarn
✔ Installing project dependencies
🎉 Copied project files
Get started with: cd ./
Done in 52.80s.
```

```shell
yarn add @types/node typescript ts-node-dev prisma @prisma/client
yarn run prisma init

mkdir orm
cd orm

mkdir src
mkdir dist
wsl touch tsconfig.json ./src/index.ts ./dist/.gitkeep

cd ..

wsl touch .dev.vars .prettierrc
mkdir .vscode
wsl touch ./.vscode/settings.json
```

### `package.json`

```json
{
  ...
      "scripts": {
        "dev:hono": "wrangler dev src/index.ts",
        "deploy": "wrangler deploy --minify src/index.ts",
        "dev:prisma": "ts-node-dev --project /orm/tsconfig.json /orm/src/index.ts",
        "studio": "prisma studio --hostname \"127.0.0.2\"",
        "migrate": "prisma migrate dev --name init && prisma generate"
    },
  ...
}
```

### `./orm/tsconfig.json`

```json
{
    "compilerOptions": {
        "module": "commonjs",
        "baseUrl": "./src",
        "allowJs": true,
        "outDir": "./dist",
        "esModuleInterop": true,
        "forceConsistentCasingInFileNames": true,
        "strict": true,
        "skipLibCheck": true
    }
}
```

### `.prettierrc`

```json
{
    "printWidth": 120,
    "tabWidth": 4,
    "singleQuote": true,
    "trailingComma": "es5",
    "semi": true
}
```

### `.vscode/settings.json`

```json
{
    "[prisma]": { "editor.defaultFormatter": "Prisma.prisma" }
}
```

### `.env`

```gitignore
node_modules
dist
.wrangler
.dev.vars

# Change them to your taste:
package-lock.json
yarn.lock
pnpm-lock.yaml
bun.lock

.env

```

## 2. モデルを作成

`prisma/prisma.schema`にモデルの定義を書く

以下は、例

```prisma
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

// Looking for ways to speed up your queries, or scale easily with your serverless or edge functions?
// Try Prisma Accelerate: https://pris.ly/cli/accelerate-init

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "cockroachdb"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}

model Blog {
  cockroachdbId BigInt @id @default(autoincrement())
  title         String
  content       String
}

```

## 3. cloudflare workers から CockroachDB 接続ずる

1. CockroachDB でデータベースを作成する

2. データベース URL を控えておく

3. Prisma Data Platform にアクセス

URL: https://console.prisma.io/

4. New Project を押す

5. 控えていたデータベース URL を入力

6. Enable Accelerate を押す

7. API KEY を控えておく

8. `prisma/prisma.schema`

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider  = "cockroachdb"
  url       = env("DATABASE_URL")
  directUrl = env("DIRECT_URL")
}
```

9. `.dev.vars`

```text
DATABASE_URL=
DIRECT_URL=
```

10. `wrangler.toml`

> [!CAUTION]
> GitHub に push する際は、必ず`wrangler.toml`の`[vars]`の情報をすべて消してから push してください。

```toml
[var]
#API KEYを書く
DATABASE_URL=""
#CockroachDBのデータベースURLを書く
DIRECT_URL=""
```

11. `.env`

```env
# Environment variables declared in this file are automatically made available to Prisma.
# See the documentation for more detail: https://pris.ly/d/prisma-schema#accessing-environment-variables-from-the-schema

# Prisma supports the native connection string format for PostgreSQL, MySQL, SQLite, SQL Server, MongoDB and CockroachDB.
# See the documentation for all the connection string options: https://pris.ly/d/connection-strings

#prisma://~ を書く
DATABASE_URL=

#postgresql://~ を書く
DIRECT_URL=

```

12. `.dev.vars`

```dev.vars
#prisma://~ を書く
DATABASE_URL=

#postgresql://~ を書く
DIRECT_URL=

```

## 3. migrate のコマンドを実行

```shell
yarn migrate
```

## 参考サイト

https://zenn.dev/kameoncloud/articles/5de3ad5f68a220
