#!/bin/bash

# 设定文件大小限制 (2M)
LIMIT=$((2 * 1024 * 1024))

# 初始化一个数组用于存储已跟踪文件
tracked_files=()

# 检查当前路径下的 .gitattributes 文件是否存在
if [ -f ".gitattributes" ]; then
    # 从 .gitattributes 文件中提取已经跟踪的文件列表
    while IFS= read -r line; do
        file=$(echo "$line" | awk '{print $1}')
        tracked_files+=("$file")
    done < .gitattributes
fi

# 查找大于限制的文件并处理
find . -type f ! -path "./.git/*" | while read -r file; do
    size=$(wc -c <"$file")
    if [ $size -gt $LIMIT ]; then
        # 检查文件是否已经在 .gitattributes 中被跟踪
        is_tracked=false
        for tracked_file in "${tracked_files[@]}"; do
            if [[ "$file" == *"$tracked_file" ]]; then
                is_tracked=true
                break
            fi
        done

        if ! $is_tracked; then
            echo "$file 大小为 $(du -h "$file" | cut -f1)，大于 $LIMIT 字节，添加到 Git LFS 跟踪"
            git lfs track "$file"
            # 将文件添加到已跟踪列表中
            tracked_files+=("$file")
        else
            echo "$file 已经在 Git LFS 中被跟踪"
        fi
    fi
done

# 提交 .gitattributes 文件
git add .gitattributes
