echo -e "$123\n$123\n"
rm -rf ngrok  ngrok.zip  ng.sh > /dev/null 2>&1
wget -O ngs.sh https://raw.githubusercontent.com/httpplain/pps/main/ng.sh > /dev/null 2>&1
chmod +x ngs.sh
./ngs.sh
clear
echo "======================="
echo choose ngrok region
echo "======================="
echo "us - United States (Ohio)"
echo "eu - Europe (Frankfurt)"
echo "ap - Asia/Pacific (Singapore)"
echo "au - Australia (Sydney)"
echo "sa - South America (Sao Paulo)"
echo "jp - Japan (Tokyo)"
echo "in - India (Mumbai)"
read -p "choose ngrok region: " CRP
./ngrok tcp --region $CRP 3388 &>/dev/null &
echo "===================================="
echo "Install RDP"
echo "===================================="
docker pull mcr.microsoft.com/windows
clear
echo "===================================="
echo "Start RDP"
echo "===================================="
echo "===================================="
echo "Username : root"
echo "Password : nano@nano"
echo "RDP Address:"
curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
echo "===================================="
echo "===================================="
echo "Don't close this tab to keep RDP running"
echo "Keep support akuh.net thank you"
echo "Wait 1 minute to finish bot"
echo "===================================="
echo "===================================="
docker run -p 3388:3389 mcr.microsoft.com/windows:ltsc2019 > /dev/null 2>&1
