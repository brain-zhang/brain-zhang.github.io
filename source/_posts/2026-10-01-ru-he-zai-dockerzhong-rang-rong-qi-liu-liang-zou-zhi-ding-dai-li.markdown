---
layout: post
title: "如何在Docker中让容器流量走指定代理"
date: 2026-10-01 16:27:34 +0800
comments: true
categories: linux, tools
---

我在一台机器上运行了多个docker容器，希望为每一个容器的流量指定一个代理服务器； 不仅仅是http等等流量，而是所有流量，同时还要排除局域网流量；

解决方法：

1. 为需要走代理的容器分配一个专属的 Docker Bridge 网络（例如固定子网 172.28.0.0/16）。

2. 在宿主机上运行一个透明代理客户端，监听本地重定向端口（例如 127.0.0.1:7892），或者局域网架设专门的代理服务或者网关

3. 使用宿主机的 iptables 规则，将所有来自该子网、目标为外部公网的 TCP 流量 REDIRECT 到代理服务器

这样的好处有很多:

1. 不需要容器做任何更改
2. 可以为不同的容器指定不同的代理
3. HOST的流量不受任何影响

<!-- more -->

#### 1. 用脚本建立Docker Bridge网络: docker-gateway-net.sh up

```
#!/usr/bin/env bash
# ==============================================================================
# Docker 容器专属透明网关网络管理脚本 (含入站 Web 服务端口回包修复)
# ==============================================================================

set -euo pipefail

# ---------------------------- 配置区域 ----------------------------
NETWORK_NAME="proxy_net"               # Docker 网络名称
SUBNET="172.28.0.0/16"                 # 专用子网网段
GATEWAY_IP="192.168.100.2"             # 你的透明网关 IP
ROUTE_TABLE="100"                      # 自定义路由表 ID
# ------------------------------------------------------------------

check_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[31m[错误] 此脚本必须使用 root 或 sudo 权限运行！\033[0m" >&2
    exit 1
  fi
}

enable_proxy() {
  check_root
  echo -e "\033[34m[+] 正在初始化透明网关路由网络环境...\033[0m"

  # 1. 开启宿主机 IPv4 数据包转发
  sysctl -w net.ipv4.ip_forward=1 >/dev/null
  echo "  ✔ 内核参数已配置 (ip_forward=1)"

  # 2. 检查并创建 Docker 网络
  if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
    echo "  ✔ Docker 网络 [${NETWORK_NAME}] 已存在"
  else
    docker network create \
      --driver bridge \
      --subnet "${SUBNET}" \
      "${NETWORK_NAME}" >/dev/null
    echo "  ✔ 成功创建 Docker 网络 [${NETWORK_NAME}] (${SUBNET})"
  fi

  # 3. 清理旧规则
  clean_routing_rules

  # 4. 配置策略路由
  # 关键修复 A: 目标是私网/局域网的包（比如外部访问容器 Web 服务的响应包），必须走主路由表原路返回！
  ip rule add to 10.0.0.0/8 lookup main priority 990
  ip rule add to 172.16.0.0/12 lookup main priority 991
  ip rule add to 192.168.0.0/16 lookup main priority 992

  # 关键修复 B: 自定义表指向网关
  ip route add default via "${GATEWAY_IP}" table "${ROUTE_TABLE}"
  # 剩余的出站公网流量，丢给透明网关
  ip rule add from "${SUBNET}" lookup "${ROUTE_TABLE}" priority 1000
  echo "  ✔ 策略路由已配置 (内网直连回包 + 公网流量导向 ${GATEWAY_IP})"

  # 5. 出口 SNAT 伪装
  if ! iptables -t nat -C POSTROUTING -s "${SUBNET}" -j MASQUERADE 2>/dev/null; then
    iptables -t nat -A POSTROUTING -s "${SUBNET}" -j MASQUERADE
  fi
  echo "  ✔ iptables MASQUERADE 出口伪装已配置"

  echo -e "\033[32m[✔] 透明网关网络已就绪！外部 Web 访问与代理出网已共存。\033[0m"
}

clean_routing_rules() {
  # 循环清理匹配的 ip rule 规则
  for prio in 990 991 992 1000; do
    while ip rule show | grep -q "prio ${prio}"; do
      ip rule del priority "${prio}" 2>/dev/null || break
    done
  done

  # 清空自定义路由表
  ip route flush table "${ROUTE_TABLE}" 2>/dev/null || true
}

disable_proxy() {
  check_root
  echo -e "\033[33m[-] 正在清理透明网关路由网络环境...\033[0m"

  clean_routing_rules
  echo "  ✔ 已清除策略路由规则及路由表"

  while iptables -t nat -C POSTROUTING -s "${SUBNET}" -j MASQUERADE 2>/dev/null; do
    iptables -t nat -D POSTROUTING -s "${SUBNET}" -j MASQUERADE
  done
  echo "  ✔ 已清除 iptables MASQUERADE 规则"

  if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
    local connected_containers
    connected_containers=$(docker network inspect -f '{{len .Containers}}' "${NETWORK_NAME}" 2>/dev/null || echo "0")
    if [ "${connected_containers}" -gt 0 ]; then
      echo -e "  \033[33m[!] 警告: 网络 [${NETWORK_NAME}] 中仍有容器连接，保留网络以防容器中断。\033[0m"
    else
      docker network rm "${NETWORK_NAME}" >/dev/null 2>&1
      echo "  ✔ 已删除 Docker 网络 [${NETWORK_NAME}]"
    fi
  fi

  echo -e "\033[32m[✔] 清理完成，网络环境已恢复原状。\033[0m"
}

status_proxy() {
  echo -e "\033[34m=== 透明网关网络运行状态 ===\033[0m"
  echo "内核转发参数 (ip_forward): $(sysctl -n net.ipv4.ip_forward 2>/dev/null || echo 0) (应为 1)"

  echo -n "策略路由规则 (ip rule): "
  if ip rule show | grep -q "lookup ${ROUTE_TABLE}"; then
    echo -e "\033[32m已激活\033[0m"
    echo "  路由详情: $(ip route show table "${ROUTE_TABLE}" | head -n 1)"
  else
    echo -e "\033[31m未生效\033[0m"
  fi

  echo -n "NAT 出口伪装 (MASQUERADE): "
  if iptables -t nat -C POSTROUTING -s "${SUBNET}" -j MASQUERADE 2>/dev/null; then
    echo -e "\033[32m已激活\033[0m"
  else
    echo -e "\033[31m未生效\033[0m"
  fi

  if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then
    echo "Docker 网络 [${NETWORK_NAME}]: 存在"
    local containers
    containers=$(docker network inspect -f '{{range $k, $v := .Containers}}{{$v.Name}} ({{$v.IPv4Address}}) {{end}}' "${NETWORK_NAME}")
    echo "当前挂载的容器: ${containers:-无}"
  else
    echo "Docker 网络 [${NETWORK_NAME}]: 不存在"
  fi
}

case "${1:-}" in
  up|start)
    enable_proxy
    ;;
  down|stop)
    disable_proxy
    ;;
  status)
    status_proxy
    ;;
  *)
    echo "用法: sudo $0 {up|down|status}"
    exit 1
    ;;
esac
```


#### 2. 如果是docker compose服务，在配置文件中指定网络:

```
services:
  your_service_name:  # 你的服务名称
    image: ...
    # 1. 挂载到 networks
    networks:
      - proxy_net
    # 2. DNS 顺便指到网关
    dns:
      - 192.168.100.2
      - 8.8.8.8

networks:
  proxy_net:
    # 核心：必须声明 external: true 和 name: proxy_net
    external: true
    name: proxy_net
```

#### 3. 如果是docker命令行启动

```
docker run -d \
  --name xxx \
  --restart unless-stopped \
  --init \
  --stop-timeout 30 \
  --security-opt no-new-privileges:true \
  --network proxy_net \
  --dns 192.168.100.2 \
  --dns 8.8.8.8 \
```

#### 不需要的时候，执行下面命令恢复原来的网络设置

```
docker-gateway-net.sh down
```
