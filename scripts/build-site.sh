#!/usr/bin/env bash
# 将仓库内容同步到 build/docs/ 并构建 MkDocs 站点
# 用法：scripts/build-site.sh [build|serve]
set -euo pipefail
cd "$(dirname "$0")/.."

ACTION="${1:-build}"

rm -rf build
mkdir -p build/docs

for item in README.md 党 团 班 活动 公示 工作交接 评奖评优 社工论文; do
  cp -R "$item" build/docs/
done

# MkDocs 以 index.md 作为目录页：重命名 README.md，并改写指向 README.md 的链接
mv build/docs/README.md build/docs/index.md
find build/docs -mindepth 2 -name README.md | while read -r f; do mv "$f" "${f%/*}/index.md"; done
find build/docs -name '*.md' | while read -r f; do
  sed -E -i.bak 's/\]\(([^)]*)README\.md\)/](\1index.md)/g' "$f" && rm -f "$f.bak"
done

# 为仍没有 index.md 的子目录自动生成目录列表页，使 "dir/" 形式的链接在站点上可用
# 注意：若父目录存在与该目录同名的 .md（如 活动/组织生活.md 与 活动/组织生活/），
# 则跳过——该 .md 页面的 URL 本身就是这个目录，生成列表页会将其覆盖
find build/docs -type d -not -path '*/image*' | while read -r dir; do
  if [ -f "${dir}.md" ]; then
    continue
  fi
  if [ ! -f "$dir/index.md" ] && ls "$dir"/* >/dev/null 2>&1; then
    {
      echo "# 目录：${dir#build/docs/}"
      echo
      ls "$dir" | while read -r f; do
        case "$f" in
          *.docx|*.pptx|*.xlsx) echo "- [$f]($f)（下载）" ;;
          *) echo "- [$f]($f)" ;;
        esac
      done
    } > "$dir/index.md"
  fi
done

if [ "$ACTION" = "serve" ]; then
  mkdocs serve -a 127.0.0.1:8000
else
  mkdocs build -d build/site
  echo "站点已构建至 build/site/"
fi
