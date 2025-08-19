#!/bin/bash

# 定义函数计算规则总数
count_rules() {
    cat "$1" | grep -Ev "\!|\[|\*" | wc -l
}

time=$(echo "$(TZ=UTC-8 date +'%Y-%m-%d %H:%M:%S')（北京时间）")
dnstotal=$(cat jiekouAD.txt | grep -E "^(\|\|)[^\/\^]+\^$" | wc -l)
echo -e "[Adblock Plus 2.0]\n! Title: 几十KB的轻量规则\n! Homepage: https://github.com/damengzhu/banad\n! by: ParkCR\n! Total Count: $dnstotal\n! Update Time:$time" >dnslist.txt
cat jiekouAD.txt | grep -E "^(\|\|)[^\/\^]+\^$" | sort -u >>dnslist.txt
sed -n '/^#Reserved area start/,/^#Reserved area end/p' hosts.txt >reservedHost.txt
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: HOSTCOUNT\n#Update Time: $time\n127.0.0.1 localhost\n::1 localhost" >hosts.txt
cat dnslist.txt | grep -Ev "\!|\[|\*" | sed -e 's/||/0.0.0.0 /g' -e "s/\^//g" | sort -u >>hosts.txt
cat reservedHost.txt >>hosts.txt && rm -f reservedHost.txt
hosttotal=$(cat hosts.txt | grep -E "^0\.0\.0\.0" | wc -l)
sed -i "s/HOSTCOUNT/$hosttotal/" hosts.txt
sed -i "s/! Update Time:.*/! Update Time: $time/g" jiekouAD.txt
total=$(cat jiekouAD.txt | grep -v "^!" | wc -l)
sed -i "s/! Total Count:.*/! Total Count: $total/g" jiekouAD.txt

# 生成 mybanad.txt 文件
mybanadtotal=$(count_rules dnslist.txt)
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: $mybanadtotal\n#Update Time: $time" >mybanad.txt
cat dnslist.txt | grep -Ev "\!|\[|\*" | sed -e 's/||//g' -e "s/\^/ = 0.0.0.0/g" | sort -u >>mybanad.txt

# 生成 Banad-RULE-SET.txt 文件
banadtotal=$(count_rules dnslist.txt)
echo -e "#Title: 几十KB的轻量规则\n#Homepage: https://github.com/damengzhu/banad\n#by: ParkCR\n#Total Count: $banadtotal\n#Update Time: $time" >Banad-RULE-SET.txt
cat dnslist.txt | grep -Ev "\!|\[|\*" | sed -e 's/||//g' -e "s/\^//g" | awk '{print "DOMAIN-SUFFIX," $0}' | sort -u >>Banad-RULE-SET.txt

exit 0
