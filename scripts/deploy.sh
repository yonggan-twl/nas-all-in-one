#!/bin/bash
# 统一部署脚本 v1.2

# 颜色定义
RED='\033[31m'; GREEN='\033[32m'; YELLOW='\033[33m'; BLUE='\033[34m'; RESET='\033[0m'

# 仓库配置
REPO_URL="https://github.com/yourname/nas-all-in-one"
SERVICES_DIR="services"

# 路径配置
source ./scripts/path-config.sh

function init_deploy() {
    echo -e "${BLUE}>>> 路径初始化检查 ${RESET}"
    mkdir -p ${DEPLOY_ROOT} ${MEDIA_ROOT}
    chmod 777 ${DEPLOY_ROOT} ${MEDIA_ROOT}
}

function deploy_service() {
    local service_name=$1
    local service_num=$(echo $service_name | cut -d'-' -f1)
    
    echo -e "${YELLOW}[${service_num}] 正在部署 ${service_name#*-}...${RESET}"
    
    # 创建服务目录
    local target_dir="${DEPLOY_ROOT}/${service_name#*-}"
    mkdir -p "${target_dir}" || return 1

    # 下载配置文件
    curl -sSL "${REPO_URL}/raw/main/${SERVICES_DIR}/${service_name}/docker-compose.yml" \
        -o "${target_dir}/docker-compose.yml" || return 2

    # 路径替换
    sed -i \
        -e "s|/mnt/nas/media|${MEDIA_ROOT}|g" \
        -e "s|/opt/nas|${DEPLOY_ROOT}|g" \
        "${target_dir}/docker-compose.yml"

    # 启动容器
    docker compose -f "${target_dir}/docker-compose.yml" up -d && \
    echo -e "${GREEN}[√] ${service_name#*-} 部署成功!${RESET}" || \
    echo -e "${RED}[×] ${service_name#*-} 部署失败!${RESET}"
}

# 主菜单
function show_menu() {
    echo -e "${BLUE}=== 全功能NAS部署工具 ===${RESET}"
    echo "1. NASTools"
    echo "2. MoviePilot"
    echo "3. qBittorrent"
    echo "4. Jellyfin"
    echo "5. Emby"
    echo "6. Jackett"
    echo "7. NAV"
    echo "8. CookieCloud"
    echo "9. Transmission"
    echo "a. 全部部署"
    echo "q. 退出"
    echo -e "${BLUE}=========================${RESET}"
}

# 初始化检查
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误：Docker 未安装，请先安装Docker${RESET}"
        exit 1
    fi
}

# 主流程
check_docker
init_deploy

while true; do
    show_menu
    read -p "请输入选择 (1-9/a/q): " choice
    
    case $choice in
        1) deploy_service "01-nastools" ;;
        2) deploy_service "02-moviepilot" ;;
        3) deploy_service "03-qbittorrent" ;;
        4) deploy_service "04-jellyfin" ;;
        5) deploy_service "05-emby" ;;
        6) deploy_service "06-jackett" ;;
        7) deploy_service "07-nav" ;;
        8) deploy_service "08-cookiecloud" ;;
        9) deploy_service "09-transmission" ;;
        a) 
            for i in {01..09}; do
                deploy_service "${i}-*" 
            done
            ;;
        q) exit 0 ;;
        *) echo -e "${RED}无效选择!${RESET}" ;;
    esac
done
