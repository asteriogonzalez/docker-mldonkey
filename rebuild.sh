rm -rf data/*
docker compose rm -f
docker compose build 
docker compose up
