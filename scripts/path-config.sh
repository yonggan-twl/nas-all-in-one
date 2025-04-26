#!/bin/bash
# 路径配置文件

# 交互式设置路径
if [ ! -f ~/.nas_paths ]; then
    read -p "请输入部署根目录 (默认: /opt/nas): " DEPLOY_ROOT
    DEPLOY_ROOT=${DEPLOY_ROOT:-/opt/nas}
    
    read -p "请输入媒体库路径 (默认: /mnt/media): " MEDIA_ROOT
    MEDIA_ROOT=${MEDIA_ROOT:-/mnt/media}
    
    echo "DEPLOY_ROOT=\"${DEPLOY_ROOT}\"" > ~/.nas_paths
    echo "MEDIA_ROOT=\"${MEDIA_ROOT}\"" >> ~/.nas_paths
else
    source ~/.nas_paths
fi