#!/bin/bash

service_name="Apache"
timestamp=$(date +"%Y-%m-%d %H:%M:%S")

	if systemctl is-active httpd; then
		echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: O serviço está online" >> "/mnt/efs/fernanda/httpd-online.txt"
	else
		echo "Data/Hora: $timestamp - $service_name - Serviço HTTPD - Status: O serviço está offline" >> "/mnt/efs/fernanda/httpd-offline.txt"
	fi
