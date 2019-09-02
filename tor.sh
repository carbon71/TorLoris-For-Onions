if [[ ! -d multitor ]]; then 
mkdir multitor;
fi
default_ins="1"
inst="${inst:-${default_inst}}"

let i=1
while [[ $i -le $inst ]]; do
port=$((9050+$i))
printf "SOCKSPort %s\nDataDirectory /var/lib/tor%s" $port $i > multitor/multitor$i 
printf "\e[1;92m[\e[0m\e[1;77m*\e[0m\e[1;92m] Starting Tor on port:\e[0m\e[1;77m 905%s\e[0m\n" $i 
tor -f multitor/multitor$i > /dev/null &
sleep 10
i=$((i+1))
done
