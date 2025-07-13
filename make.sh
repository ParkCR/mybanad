#!/bin/bash

# 定义颜色变量用于输出美化
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

# 检查文件是否存在
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}错误: 文件 $1 不存在!${NC}" >&2
        exit 1
    fi
}

# 计算规则总数
count_rules() {
    check_file "$1"
    grep -Ev "\!|\[|\*" "$1" | wc -l
}

# 获取当前时间（北京时间）
current_time=$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')
formatted_time="${current_time}（北京时间）"

# 源文件检查
check_file "jiekouAD.txt"
check_file "hosts.txt"

# 处理DNS规则
echo -e "${YELLOW}正在处理DNS规则...${NC}"
dns_rules=$(grep -E "^(\|\|)[^\/\^]+\^$" jiekouAD.txt | sort -u)
dnstotal=$(echo "$dns_rules" | wc -l)

# 生成dnslist.txt
echo -e "[Adblock Plus 2.0]\n! Title: 几十KB的轻量规则\n! Homepage: https://github.com/damengzhu/banad\n! by: ParkCR\n! Total Count: $dnstotal\n! Update Time:$formatted_time" > dnslist.txt
echo "$dns_rules" >> dnslist.txt
echo -e "${GREEN}已生成dnslist.txt，共 $dnstotal 条规则${NC}"

# 处理hosts.txt
echo -e "${YELLOW}正在处理hosts.txt...${NC}"
sed -n '/^#Reserved area start/,/^#Reserved area end/p' hosts.txt > reservedHost.txt
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: HOSTCOUNT\n#Update Time: $formatted_time\n127.0.0.1 localhost\n::1 localhost" > hosts.txt
grep -Ev "\!|\[|\*" dnslist.txt | sed -e 's/||/0.0.0.0 /g' -e "s/\^//g" | sort -u >> hosts.txt
cat reservedHost.txt >> hosts.txt && rm -f reservedHost.txt
hosttotal=$(grep -E "^0\.0\.0\.0" hosts.txt | wc -l)
sed -i "s/HOSTCOUNT/$hosttotal/" hosts.txt
echo -e "${GREEN}已生成hosts.txt，共 $hosttotal 条规则${NC}"

# 更新源文件信息
echo -e "${YELLOW}正在更新源文件信息...${NC}"
sed -i "s/! Update Time:.*/! Update Time: $formatted_time/g" jiekouAD.txt
total=$(grep -v "^!" jiekouAD.txt | wc -l)
sed -i "s/! Total Count:.*/! Total Count: $total/g" jiekouAD.txt
echo -e "${GREEN}已更新jiekouAD.txt信息${NC}"

# 生成 mybanad.txt 文件
echo -e "${YELLOW}正在生成mybanad.txt...${NC}"
mybanad_rules=$(grep -Ev "\!|\[|\*" dnslist.txt)
mybanadtotal=$(echo "$mybanad_rules" | wc -l)
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: $mybanadtotal\n#Update Time: $formatted_time" > mybanad.txt
echo "$mybanad_rules" | sed -e 's/||//g' -e "s/\^/ = 0.0.0.0/g" | sort -u >> mybanad.txt
echo -e "${GREEN}已生成mybanad.txt，共 $mybanadtotal 条规则${NC}"

# 生成 Banad-RULE-SET.txt 文件 - 优化处理通配符规则
echo -e "${YELLOW}正在生成Banad-RULE-SET.txt...${NC}"
banad_rules=$(grep -Ev "\!|\[|\*" dnslist.txt)
banadtotal=$(echo "$banad_rules" | wc -l)
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: $banadtotal\n#Update Time: $formatted_time" > Banad-RULE-SET.txt

# 处理常规规则和通配符规则
echo "$banad_rules" | while IFS= read -r rule; do
    # 移除开头的||和结尾的^
    clean_rule=$(echo "$rule" | sed -e 's/||//g' -e 's/\^//g')
    
    # 检查是否包含通配符*
    if [[ "$clean_rule" == *\** ]]; then
        # 处理通配符规则，提取主域名
        domain=$(echo "$clean_rule" | sed -e 's/.*\*\.//')
        echo "DOMAIN-SUFFIX,$domain"
    else
        # 常规规则
        echo "DOMAIN,$clean_rule"
    fi
done | sort -u >> Banad-RULE-SET.txt

echo -e "${GREEN}已生成Banad-RULE-SET.txt，共 $banadtotal 条规则${NC}"

echo -e "${GREEN}所有规则文件生成完成！${NC}"
exit 0
