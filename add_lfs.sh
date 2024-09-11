#!/bin/bash

# 设定文件大小限制 (2M)
LIMIT=$((2 * 1024 * 1024))

# 确保 .gitattributes 文件存在
touch .gitattributes

# 初始化一个数组用于存储已跟踪文件
tracked_files=()

echo "① 检查当前路径下的 .gitattributes 中已经跟踪的文件列表"
if [ -f ".gitattributes" ]; then
    # 从 .gitattributes 文件中提取已经跟踪的文件列表
    while IFS= read -r line; do
        file=$(echo "$line" | awk '{print $1}')
        # 检查是否存在被跟踪的文件
        if ! ls $file 1> /dev/null 2>&1; then
            echo "文件 $file 不存在，移除其 LFS 跟踪..."
            git lfs untrack "$file"
        else
            echo "文件 $file 存在，进行 LFS 跟踪检查"
            tracked_files+=("$file")
        fi
    done < .gitattributes
fi

echo "② 查找大于限制的文件并处理..."
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

# 检查已被 LFS 跟踪的文件是否存在，并移除不存在的文件
echo "③ 检查已被 LFS 跟踪的文件..."
git lfs ls-files | awk '{print $3}' | while read -r lfs_file; do
    if [ ! -f "$lfs_file" ]; then
        echo "LFS 文件 $lfs_file 已被删除，移除其 LFS 记录..."
        
        # 取消对该文件的 LFS 跟踪
        git lfs untrack "$lfs_file"
        
        # 从 LFS 仓库中删除该文件的记录
        git rm --cached "$lfs_file"
    fi
done

echo "🔚 LFS 跟踪检查完成。"

# 提交 .gitattributes 文件
git add .gitattributes
