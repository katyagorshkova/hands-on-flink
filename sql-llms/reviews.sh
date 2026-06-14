#!/usr/bin/env bash
set -euo pipefail

KAFKA_CONTAINER="${KAFKA_CONTAINER:-kafka}"
BOOTSTRAP_SERVERS="${BOOTSTRAP_SERVERS:-localhost:9092}"
TOPIC="${TOPIC:-product_reviews}"

docker exec -i "$KAFKA_CONTAINER" kafka-console-producer \
  --bootstrap-server "$BOOTSTRAP_SERVERS" \
  --topic "$TOPIC" <<'EOF'
{"review_id":"R1","product_id":"P100","product_name":"SmartWatch Pro","rating":2,"review_text":"Battery life is poor. I have to charge it every day."}
{"review_id":"R2","product_id":"P100","product_name":"SmartWatch Pro","rating":1,"review_text":"Battery stopped working after two weeks."}
{"review_id":"R3","product_id":"P100","product_name":"SmartWatch Pro","rating":3,"review_text":"Nice design, but battery could be better."}
{"review_id":"R4","product_id":"P100","product_name":"SmartWatch Pro","rating":2,"review_text":"The watch looks nice, but the battery drains too quickly."}
{"review_id":"R5","product_id":"P100","product_name":"SmartWatch Pro","rating":4,"review_text":"Good display and smooth interface, but battery life could be improved."}

{"review_id":"R6","product_id":"P200","product_name":"NoiseCancel Headphones","rating":5,"review_text":"Excellent sound quality and very comfortable."}
{"review_id":"R7","product_id":"P200","product_name":"NoiseCancel Headphones","rating":4,"review_text":"Great noise cancellation, but the case is bulky."}
{"review_id":"R8","product_id":"P200","product_name":"NoiseCancel Headphones","rating":5,"review_text":"Battery lasts for days. Very happy with the purchase."}
{"review_id":"R9","product_id":"P200","product_name":"NoiseCancel Headphones","rating":3,"review_text":"Sound is good, but Bluetooth pairing was sometimes unstable."}
{"review_id":"R10","product_id":"P200","product_name":"NoiseCancel Headphones","rating":4,"review_text":"Comfortable for long calls, but the touch controls are too sensitive."}

{"review_id":"R11","product_id":"P300","product_name":"Home Espresso Mini","rating":2,"review_text":"Coffee tastes good, but the water tank is too small."}
{"review_id":"R12","product_id":"P300","product_name":"Home Espresso Mini","rating":1,"review_text":"The machine started leaking after one week."}
{"review_id":"R13","product_id":"P300","product_name":"Home Espresso Mini","rating":2,"review_text":"Compact design, but cleaning is difficult and messy."}
{"review_id":"R14","product_id":"P300","product_name":"Home Espresso Mini","rating":3,"review_text":"Makes decent espresso, but it is noisy."}
{"review_id":"R15","product_id":"P300","product_name":"Home Espresso Mini","rating":2,"review_text":"Small footprint is nice, but the build quality feels cheap."}
EOF