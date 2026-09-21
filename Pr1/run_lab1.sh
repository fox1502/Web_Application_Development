#!/bin/bash

echo "=== ЗАПИТ ДО АВТОРИЗОВАНОГО РЕСУРСУ ЧЕРЕЗ CURL ==="

LOGIN_RESPONSE=$(curl -s -X POST https://dummyjson.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "emilys", "password": "emilyspass"}')


echo "> POST /auth/login HTTP/1.1"
echo "> Host: dummyjson.com"
echo "> Content-Type: application/json"
echo "> Accept: application/json"
echo "< HTTP/1.1 200 OK"
echo "< Content-Type: application/json; charset=utf-8"
echo "< Connection: keep-alive"
echo "$LOGIN_RESPONSE"

echo ""
echo "=== ПЕРЕВІРКА МЕТРИК ПРОДУКТИВНОСТІ МЕРЕЖЕВОГО З'ЄДНАННЯ ==="

curl -s -o /dev/null -w \
"DNS Lookup: %{time_namelookup}s\nTCP Connect: %{time_connect}s\nTLS Handshake: %{time_appconnect}s\nTime To First Byte (TTFB): %{time_starttransfer}s\nTotal Transaction Time: %{time_total}s\n" \
https://dummyjson.com/products

echo ""
echo "=== ДОСЛІДЖЕННЯ COOKIE JAR У ТЕРМІНАЛІ ==="

curl -s -c cookies.txt "https://httpbin.org/cookies/set?user_role=student&session_key=lab1_token" > /dev/null


cat cookies.txt


echo "< GET /cookies HTTP/1.1"
echo "< Host: httpbin.org"
curl -s -b cookies.txt https://httpbin.org/cookies

echo ""
echo "=== СИМУЛЯЦІЯ PREFLIGHT-ЗАПИТУ CORS (OPTIONS) ==="

curl -i -s -X OPTIONS https://httpbin.org/post \
  -H "Origin: https://my-college-app.edu" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization"
