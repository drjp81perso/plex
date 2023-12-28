#!/bin/bash
docker-compose --compatibility pull && docker-compose --compatibility down && docker-compose --compatibility up -d
